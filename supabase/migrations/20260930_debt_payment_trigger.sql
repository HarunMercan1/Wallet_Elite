-- Migration: Apply debt payments to remaining_amount on the database side
-- Created: 2026-09-30
-- Description: Ödeme kaydı ile borcun kalan tutarı artık aynı veritabanı işlemi
-- içinde güncellenir (önceden istemci oku-hesapla-yaz yapıyordu; arada bağlantı
-- koparsa ödeme kaydolup kalan tutar düşmeyebiliyordu).

CREATE OR REPLACE FUNCTION public.apply_debt_payment()
RETURNS TRIGGER
LANGUAGE plpgsql
-- SECURITY INVOKER: debts güncellemesi RLS'e tabidir
SET search_path = public
AS $$
BEGIN
  UPDATE debts
  SET remaining_amount = GREATEST(remaining_amount - NEW.amount, 0),
      is_completed = (remaining_amount - NEW.amount) <= 0
  WHERE id = NEW.debt_id;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trigger_apply_debt_payment ON debt_payments;
CREATE TRIGGER trigger_apply_debt_payment
  AFTER INSERT ON debt_payments
  FOR EACH ROW
  EXECUTE FUNCTION public.apply_debt_payment();
