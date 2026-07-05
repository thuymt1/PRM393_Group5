import 'package:supabase/supabase.dart';
void main() async {
  final supabase = SupabaseClient(
    'https://vsmlzmwgqyaduavrisme.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZzbWx6bXdncXlhZHVhdnJpc21lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2NTc0MTIsImV4cCI6MjA5NzIzMzQxMn0.MQqxeMaxp3i7uJXZ4kWN2UxyUmul3N5E7_XWZ2FIcfU',
  );
  try {
    final response = await supabase
        .from('bookings')
        .select('''
          *,
          profiles (full_name, email, avatar_url),
          homestays (name)
        ''')
        .limit(1);
    print('SUCCESS: $response');
  } catch (e) {
    print('ERROR: $e');
  }
}
