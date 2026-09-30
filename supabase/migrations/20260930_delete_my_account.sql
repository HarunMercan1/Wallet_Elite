-- Migration: In-app account deletion (Google Play requirement)
-- Created: 2026-09-30
-- Description: Giriş yapmış kullanıcının kendi hesabını ve tüm verisini silmesini sağlar.
-- auth.users silinince profiles (ON DELETE CASCADE) ve ona bağlı accounts,
-- transactions, categories, debts, debt_payments; auth.users'a bağlı budgets ve
-- recurring_transactions zincirleme olarak silinir.

CREATE OR REPLACE FUNCTION public.delete_my_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Yalnızca çağıran kullanıcının kendi kaydı silinir
  DELETE FROM auth.users WHERE id = uid;
END;
$$;

REVOKE ALL ON FUNCTION public.delete_my_account() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_my_account() TO authenticated;
