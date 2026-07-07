import 'dart:io';

void main() {
  final file = File('lib/screens/host/host_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    "final user = ref.watch(authViewModelProvider).user;",
    "final profile = ref.watch(authViewModelProvider).profile;"
  );
  content = content.replaceFirst(
    "final username = user?['username'] ?? 'Host';",
    "final username = profile?.fullName ?? 'Host';"
  );
  file.writeAsStringSync(content);
}
