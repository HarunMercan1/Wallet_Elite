-- =====================================================
-- Supabase Migration: Budgets Table
-- Wallet Elite - Bütçe Limitleri
-- =====================================================

-- Bütçe tablosu
CREATE TABLE IF NOT EXISTS budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Bütçe detayları
    name TEXT NOT NULL,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    amount DECIMAL(15, 2) NOT NULL,
    
    -- Periyod
    period TEXT NOT NULL DEFAULT 'monthly' CHECK (period IN ('weekly', 'monthly', 'yearly')),
    
    -- Dönem başlangıcı (bütçe hangi günden başlıyor)
    start_day INT DEFAULT 1 CHECK (start_day >= 1 AND start_day <= 31),
    
    -- Durum
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Bildirim ayarları
    notify_at_percent INT DEFAULT 80 CHECK (notify_at_percent >= 0 AND notify_at_percent <= 100),
    notify_when_exceeded BOOLEAN DEFAULT true,
    
    -- Zaman damgaları
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- İndeksler
CREATE INDEX IF NOT EXISTS idx_budgets_user_id ON budgets(user_id);
CREATE INDEX IF NOT EXISTS idx_budgets_category_id ON budgets(category_id);
CREATE INDEX IF NOT EXISTS idx_budgets_is_active ON budgets(is_active);

-- RLS (Row Level Security) Politikaları
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;

-- Kullanıcılar sadece kendi bütçelerini görebilir
CREATE POLICY "Users can view their own budgets"
    ON budgets
    FOR SELECT
    USING (auth.uid() = user_id);

-- Kullanıcılar kendi bütçelerini oluşturabilir
CREATE POLICY "Users can create their own budgets"
    ON budgets
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Kullanıcılar kendi bütçelerini güncelleyebilir
CREATE POLICY "Users can update their own budgets"
    ON budgets
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Kullanıcılar kendi bütçelerini silebilir
CREATE POLICY "Users can delete their own budgets"
    ON budgets
    FOR DELETE
    USING (auth.uid() = user_id);

-- Updated_at trigger fonksiyonu (eğer yoksa)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Bütçe güncellendiğinde updated_at'i güncelle
DROP TRIGGER IF EXISTS update_budgets_updated_at ON budgets;
CREATE TRIGGER update_budgets_updated_at
    BEFORE UPDATE ON budgets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Örnek yorumlar
COMMENT ON TABLE budgets IS 'Kullanıcı bütçe limitleri';
COMMENT ON COLUMN budgets.period IS 'Bütçe periyodu: weekly, monthly, yearly';
COMMENT ON COLUMN budgets.start_day IS 'Aylık bütçe için dönem başlangıç günü';
COMMENT ON COLUMN budgets.notify_at_percent IS 'Yüzde kaçta uyarı verileceği';
