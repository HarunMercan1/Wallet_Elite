// lib/core/constants/supabase_config.dart

/// Supabase bağlantı bilgileri
/// NOT: Anon key RLS politikaları ile korunuyor, public olarak kullanılabilir
class SupabaseConfig {
  // Supabase Project URL
  static const String url = 'https://udekdhskflduszcoknch.supabase.co';

  // Anon API Key (JWT format - Flutter client için gerekli)
  // Bu key güvenle client-side'da kullanılabilir çünkü RLS aktif
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkZWtkaHNrZmxkdXN6Y29rbmNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjczODQ4NDgsImV4cCI6MjA4Mjk2MDg0OH0.jWJk6srnoDHqXaWtprvDMRIE8rvEsENYEhxpBOteoc0';
}
