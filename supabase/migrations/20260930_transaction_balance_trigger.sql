-- Migration: Keep account balances in sync with transactions on the database side
-- Created: 2026-09-30
-- Description: Bakiye artık istemcide oku-hesapla-yaz ile değil, işlem eklenince/
-- güncellenince/silinince aynı veritabanı işlemi içinde atomik olarak güncellenir.

CREATE OR REPLACE FUNCTION public.apply_transaction_to_balance()
RETURNS TRIGGER
LANGUAGE plpgsql
-- SECURITY INVOKER (varsayılan): accounts güncellemesi RLS'e tabidir, böylece
-- bir kullanıcı başkasının account_id'sini vererek onun bakiyesini değiştiremez.
SET search_path = public
AS $$
BEGIN
  IF TG_OP IN ('UPDATE', 'DELETE') THEN
    UPDATE accounts
    SET balance = balance - CASE OLD.type
      WHEN 'income' THEN OLD.amount
      WHEN 'expense' THEN -OLD.amount
      ELSE 0
    END
    WHERE id = OLD.account_id;
  END IF;

  IF TG_OP IN ('INSERT', 'UPDATE') THEN
    UPDATE accounts
    SET balance = balance + CASE NEW.type
      WHEN 'income' THEN NEW.amount
      WHEN 'expense' THEN -NEW.amount
      ELSE 0
    END
    WHERE id = NEW.account_id;
  END IF;

  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trigger_apply_transaction_to_balance ON transactions;
CREATE TRIGGER trigger_apply_transaction_to_balance
  AFTER INSERT OR DELETE OR UPDATE OF amount, type, account_id ON transactions
  FOR EACH ROW
  EXECUTE FUNCTION public.apply_transaction_to_balance();
