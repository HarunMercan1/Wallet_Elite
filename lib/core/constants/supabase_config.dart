// lib/core/constants/supabase_config.dart

/// Supabase bağlantı bilgileri
/// NOT: Publishable key RLS politikaları ile korunuyor, public olarak kullanılabilir
class SupabaseConfig {
  // Supabase Project URL
  static const String url = 'https://udekdhskflduszcoknch.supabase.co';

  // Yeni Publishable API Key (eski anon key'in yerine geçti)
  // Bu key güvenle client-side'da kullanılabilir çünkü RLS aktif
  static const String anonKey =
      'sb_publishable_iUxetHgqsdyb1HXu2KWGkA__k-7WKDX';
}
