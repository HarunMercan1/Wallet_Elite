-- Migration: Execute recurring transactions on the database side
-- Created: 2026-09-30
-- Description: Vadesi gelen tekrarlayan işlemler için gerçek işlemleri oluşturur.
-- - Kaçırılan her dönem için ayrı işlem oluşturur (ör. 3 ay açılmadıysa 3 maaş).
-- - FOR UPDATE SKIP LOCKED ile aynı kayıt iki kez işlenmez (çift cihaz/çift çağrı).
-- - pg_cron ile saat başı çalışır; uygulama açılışında da RPC olarak çağrılır.
-- - Bakiye, transactions üzerindeki trigger_apply_transaction_to_balance ile güncellenir.

-- Bir sonraki çalışma tarihini hesapla
CREATE OR REPLACE FUNCTION public.recurring_next_date(
  p_date date,
  p_frequency text,
  p_day_of_month int,
  p_start_date date
)
RETURNS date
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  target_day int;
  next_month date;
  last_day int;
BEGIN
  CASE p_frequency
    WHEN 'daily' THEN
      RETURN p_date + 1;
    WHEN 'weekly' THEN
      RETURN p_date + 7;
    WHEN 'monthly' THEN
      target_day := COALESCE(p_day_of_month, EXTRACT(DAY FROM p_start_date)::int);
      next_month := (date_trunc('month', p_date) + interval '1 month')::date;
      last_day := EXTRACT(DAY FROM (next_month + interval '1 month' - interval '1 day'))::int;
      RETURN next_month + (LEAST(target_day, last_day) - 1);
    WHEN 'yearly' THEN
      RETURN (p_date + interval '1 year')::date;
    ELSE
      RAISE EXCEPTION 'Unknown frequency: %', p_frequency;
  END CASE;
END;
$$;

-- Vadesi gelen işlemleri çalıştır.
-- SECURITY INVOKER: uygulamadan çağrıldığında RLS sayesinde yalnızca çağıran
-- kullanıcının kayıtları işlenir; pg_cron (postgres) tüm kullanıcıları işler.
CREATE OR REPLACE FUNCTION public.process_due_recurring_transactions()
RETURNS int
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  r recurring_transactions%ROWTYPE;
  d date;
  last_run date;
  created int := 0;
  guard int;
BEGIN
  FOR r IN
    SELECT * FROM recurring_transactions
    WHERE is_active
      AND next_execution_date <= current_date
    FOR UPDATE SKIP LOCKED
  LOOP
    d := r.next_execution_date;
    last_run := r.last_execution_date;
    guard := 0;

    WHILE d <= current_date
      AND (r.end_date IS NULL OR d <= r.end_date)
      AND guard < 1000
    LOOP
      INSERT INTO transactions (user_id, account_id, category_id, amount, type, description, date)
      VALUES (r.user_id, r.account_id, r.category_id, r.amount, r.type, r.description,
              d + time '12:00');
      created := created + 1;
      last_run := d;
      d := recurring_next_date(d, r.frequency, r.day_of_month, r.start_date);
      guard := guard + 1;
    END LOOP;

    UPDATE recurring_transactions
    SET next_execution_date = d,
        last_execution_date = last_run,
        is_active = (r.end_date IS NULL OR d <= r.end_date)
    WHERE id = r.id;
  END LOOP;

  RETURN created;
END;
$$;

REVOKE ALL ON FUNCTION public.process_due_recurring_transactions() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.process_due_recurring_transactions() TO authenticated;

-- Tek seferlik: özellik bugüne kadar hiç çalışmadığı için mevcut kayıtların
-- geçmiş dönemlerini toplu oluşturmak yerine sıradaki tarihi bugüne/ileriye al.
DO $$
DECLARE
  r recurring_transactions%ROWTYPE;
  d date;
BEGIN
  FOR r IN SELECT * FROM recurring_transactions WHERE is_active AND next_execution_date < current_date LOOP
    d := r.next_execution_date;
    WHILE d < current_date LOOP
      d := recurring_next_date(d, r.frequency, r.day_of_month, r.start_date);
    END LOOP;
    UPDATE recurring_transactions SET next_execution_date = d WHERE id = r.id;
  END LOOP;
END;
$$;

-- Saat başı çalıştır (uygulama açılmasa da işlemler oluşur)
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;
SELECT cron.schedule(
  'process-due-recurring-transactions',
  '0 * * * *',
  $$SELECT public.process_due_recurring_transactions();$$
);
