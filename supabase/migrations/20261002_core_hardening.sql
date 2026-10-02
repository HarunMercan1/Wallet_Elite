-- Migration: Core schema hardening before release
-- Created: 2026-10-02

-- 1. Kullanıcıya göre sorgular için indeksler (önceden yalnızca birincil anahtarlar vardı)
CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON public.accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_categories_user_type ON public.categories(user_id, type);
CREATE INDEX IF NOT EXISTS idx_transactions_user_date ON public.transactions(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_account_id ON public.transactions(account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON public.transactions(category_id);

-- 2. Kullanılmış bir kategori silinince işlemler kategorisiz kalsın (önceden FK hatası)
ALTER TABLE public.transactions
  DROP CONSTRAINT IF EXISTS transactions_category_id_fkey;
ALTER TABLE public.transactions
  ADD CONSTRAINT transactions_category_id_fkey
  FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;

-- 3. Veri doğrulama (mevcut verinin hepsi geçerli olduğu doğrulandı)
DO $$ BEGIN
  ALTER TABLE public.transactions
    ADD CONSTRAINT transactions_amount_positive CHECK (amount > 0);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER TABLE public.transactions
    ADD CONSTRAINT transactions_type_check CHECK (type IN ('income', 'expense'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER TABLE public.categories
    ADD CONSTRAINT categories_type_check CHECK (type IN ('income', 'expense'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 4. Var olmayan 'ocean' teması yerine ücretsiz tema varsayılan olsun
ALTER TABLE public.profiles ALTER COLUMN preferred_theme SET DEFAULT 'midnight';

-- 5. SECURITY DEFINER fonksiyonda search_path sabitlenir (Supabase güvenlik önerisi)
ALTER FUNCTION public.handle_new_user() SET search_path = public;
ALTER FUNCTION public.delete_my_account() SET search_path = public;
