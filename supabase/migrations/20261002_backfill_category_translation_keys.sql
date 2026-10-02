-- Migration: Backfill translation keys for default categories
-- Created: 2026-10-02
-- Description: Çeviri anahtarı eklenmeden önce oluşturulan varsayılan
-- kategoriler her dilde Türkçe adla görünüyordu. Bilinen varsayılan adlara
-- translation_key atanır; kullanıcının kendi oluşturduğu kategoriler özel
-- (is_custom) olarak işaretlenir. "Giyim" yanlışlıkla cat_shopping almıştı.

UPDATE categories c
SET translation_key = m.key,
    is_custom = false
FROM (VALUES
  ('Maaş', 'income', 'cat_salary'),
  ('Freelance', 'income', 'cat_freelance'),
  ('Yatırım', 'income', 'cat_investment'),
  ('Hediye', 'income', 'cat_gift'),
  ('Diğer Gelir', 'income', 'cat_other'),
  ('Market', 'expense', 'cat_groceries'),
  ('Ulaşım', 'expense', 'cat_transport'),
  ('Faturalar', 'expense', 'cat_bills'),
  ('Eğlence', 'expense', 'cat_entertainment'),
  ('Yemek', 'expense', 'cat_food'),
  ('Sağlık', 'expense', 'cat_health'),
  ('Giyim', 'expense', 'cat_clothing'),
  ('Eğitim', 'expense', 'cat_education'),
  ('Diğer Gider', 'expense', 'cat_other')
) AS m(name, type, key)
WHERE c.name = m.name
  AND c.type = m.type
  AND (c.translation_key IS NULL
       OR (c.name = 'Giyim' AND c.translation_key = 'cat_shopping'));

-- Varsayılan adlardan biri olmayan ve anahtarı olmayan kategoriler kullanıcıya ait
UPDATE categories
SET is_custom = true
WHERE translation_key IS NULL
  AND is_custom IS DISTINCT FROM true;
