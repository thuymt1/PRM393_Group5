import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://vsmlzmwgqyaduavrisme.supabase.co',
    'YOUR_ANON_KEY',
  );

  try {
    final res = await supabase
        .from('bookings')
        .select('*')
        .limit(1);

    final bookings = (res as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    for (final b in bookings) {
      b['profiles'] = {
        'full_name': 'Test Modifiability',
      };

      print('SUCCESS: ${b['profiles']}');
    }
  } catch (e, st) {
    print('ERROR: $e');
    print(st);
  }
}