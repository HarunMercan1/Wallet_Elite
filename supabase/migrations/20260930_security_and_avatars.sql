-- Migration: Security hardening + avatars storage bucket
-- Created: 2026-09-30

-- ============================================================
-- 1. profiles: kullanıcı is_premium alanını kendisi değiştiremesin
-- ============================================================
-- RLS "kendi satırını güncelle" izni veriyor; sütun bazlı yetkiyle
-- yalnızca kullanıcıya ait ayar sütunları güncellenebilir.
REVOKE UPDATE ON public.profiles FROM authenticated, anon;
GRANT UPDATE (
  full_name,
  avatar_url,
  updated_at,
  onboarding_completed,
  preferred_language,
  preferred_theme,
  preferred_currency,
  is_dark_mode
) ON public.profiles TO authenticated;

-- ============================================================
-- 2. Başkasının cüzdanına / kategorisine kayıt bağlanamasın
-- ============================================================
CREATE OR REPLACE FUNCTION public.owns_account(p_account_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM accounts WHERE id = p_account_id AND user_id = auth.uid());
$$;

CREATE OR REPLACE FUNCTION public.owns_category_or_null(p_category_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT p_category_id IS NULL
      OR EXISTS (SELECT 1 FROM categories WHERE id = p_category_id AND user_id = auth.uid());
$$;

-- transactions
DROP POLICY IF EXISTS "İşlem Ekle" ON public.transactions;
DROP POLICY IF EXISTS "İşlem Düzenle" ON public.transactions;
CREATE POLICY "İşlem Ekle" ON public.transactions
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND public.owns_account(account_id)
    AND public.owns_category_or_null(category_id)
  );
CREATE POLICY "İşlem Düzenle" ON public.transactions
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (
    auth.uid() = user_id
    AND public.owns_account(account_id)
    AND public.owns_category_or_null(category_id)
  );

-- recurring_transactions (pg_cron RLS'i atlayarak bu kayıtlardan işlem oluşturur,
-- bu yüzden kaydın kendisi mutlaka kullanıcının cüzdanına bağlı olmalı)
DROP POLICY IF EXISTS "Users can insert their own recurring transactions" ON public.recurring_transactions;
DROP POLICY IF EXISTS "Users can update their own recurring transactions" ON public.recurring_transactions;
CREATE POLICY "Users can insert their own recurring transactions" ON public.recurring_transactions
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND public.owns_account(account_id)
    AND public.owns_category_or_null(category_id)
  );
CREATE POLICY "Users can update their own recurring transactions" ON public.recurring_transactions
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (
    auth.uid() = user_id
    AND public.owns_account(account_id)
    AND public.owns_category_or_null(category_id)
  );

-- budgets
DROP POLICY IF EXISTS "Users can create their own budgets" ON public.budgets;
DROP POLICY IF EXISTS "Users can update their own budgets" ON public.budgets;
CREATE POLICY "Users can create their own budgets" ON public.budgets
  FOR INSERT
  WITH CHECK (auth.uid() = user_id AND public.owns_category_or_null(category_id));
CREATE POLICY "Users can update their own budgets" ON public.budgets
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id AND public.owns_category_or_null(category_id));

-- Ek güvence: cron işleyicisi yalnızca kayıt sahibinin cüzdanına işlem yazsın
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
    SELECT rt.* FROM recurring_transactions rt
    JOIN accounts a ON a.id = rt.account_id AND a.user_id = rt.user_id
    WHERE rt.is_active
      AND rt.next_execution_date <= current_date
    FOR UPDATE OF rt SKIP LOCKED
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

-- ============================================================
-- 3. avatars bucket (profil fotoğrafları)
-- ============================================================
-- Dosya yolu: <user_id>/avatar_<timestamp>.jpg — herkes okuyabilir (public URL),
-- yalnızca sahibi kendi klasörüne yazabilir/silebilir. En fazla 2 MB, sadece resim.
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO UPDATE
SET public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Avatar upload own folder" ON storage.objects;
DROP POLICY IF EXISTS "Avatar update own folder" ON storage.objects;
DROP POLICY IF EXISTS "Avatar delete own folder" ON storage.objects;
DROP POLICY IF EXISTS "Avatar read own folder" ON storage.objects;

CREATE POLICY "Avatar upload own folder" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Avatar update own folder" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text)
  WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Avatar delete own folder" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Listeleme (eski avatarları temizlemek için) yalnızca kendi klasörü
CREATE POLICY "Avatar read own folder" ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
