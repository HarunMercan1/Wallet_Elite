import 'package:supabase/supabase.dart';

void main() async {
  print('Applying migration...');
  final supabase = SupabaseClient(
    'https://udekdhskflduszcoknch.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkZWtkaHNrZmxkdXN6Y29rbmNoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NzM4NDg0OCwiZXhwIjoyMDgyOTYwODQ4fQ.LvSQbu2XSGactOv_-wm15mwHSELMiC15ndWSMkM8vdE',
  );

  try {
    // We cannot run raw SQL easily with standard client.
    // But we can check if table exists and warn user.
    print('Checking if debt_payments table exists...');
    await supabase.from('debt_payments').select().limit(1);
    print('SUCCESS: Table exists.');
  } catch (e) {
    if (e.toString().contains('42P01')) {
      // Table undefined error usually
      print(
        'WARNING: Table debt_payments likely missing. Please run migration manually.',
      );
    } else {
      print('ERROR checking table: $e');
    }
  }
}
