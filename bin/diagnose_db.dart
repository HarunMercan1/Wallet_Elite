import 'package:supabase/supabase.dart';

void main() async {
  print('Initializing Supabase...');
  // Initialize with the Project URL and Service Role Key provided by the user
  final supabase = SupabaseClient(
    'https://udekdhskflduszcoknch.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkZWtkaHNrZmxkdXN6Y29rbmNoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NzM4NDg0OCwiZXhwIjoyMDgyOTYwODQ4fQ.LvSQbu2XSGactOv_-wm15mwHSELMiC15ndWSMkM8vdE',
  );

  try {
    print('Checking if debts table exists...');
    final data = await supabase.from('debts').select().limit(1);
    print('SUCCESS: Table exists. Data: $data');
  } catch (e) {
    print('ERROR: $e');
  }
}
