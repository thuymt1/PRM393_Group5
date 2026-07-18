abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://vsmlzmwgqyaduavrisme.supabase.co',
  );

  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZzbWx6bXdncXlhZHVhdnJpc21lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2NTc0MTIsImV4cCI6MjA5NzIzMzQxMn0.MQqxeMaxp3i7uJXZ4kWN2UxyUmul3N5E7_XWZ2FIcfU',
  );
}
