// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;

    // Navigator.pushNamed(context, '/path', arguments: args); -> context.push('/path', extra: args);
    // Note: this regex is simple, might need tweaks.
    final pushNamedRegex = RegExp(r"Navigator\.pushNamed\s*\(\s*context\s*,\s*('[^']+')\s*(?:,\s*arguments\s*:\s*([^)]+))?\)");
    if (pushNamedRegex.hasMatch(content)) {
      content = content.replaceAllMapped(pushNamedRegex, (m) {
        final path = m.group(1);
        final args = m.group(2);
        if (args != null) {
          return "context.push($path, extra: $args)";
        }
        return "context.push($path)";
      });
      changed = true;
    }

    // Navigator.pushReplacementNamed(context, '/path') -> context.pushReplacement('/path')
    final pushRepRegex = RegExp(r"Navigator\.pushReplacementNamed\s*\(\s*context\s*,\s*('[^']+')\s*\)");
    if (pushRepRegex.hasMatch(content)) {
      content = content.replaceAllMapped(pushRepRegex, (m) {
        return "context.pushReplacement(${m.group(1)})";
      });
      changed = true;
    }
    
    // pushReplacementNamed with arguments or just routeName variable
    final pushRepRegex2 = RegExp(r"Navigator\.pushReplacementNamed\s*\(\s*context\s*,\s*([a-zA-Z0-9_]+)\s*\)");
    if (pushRepRegex2.hasMatch(content)) {
      content = content.replaceAllMapped(pushRepRegex2, (m) {
        return "context.pushReplacement(${m.group(1)})";
      });
      changed = true;
    }

    // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); -> context.go('/login');
    final pushRemRegex = RegExp(r"Navigator\.pushNamedAndRemoveUntil\s*\(\s*context\s*,\s*('[^']+')\s*,\s*\([^)]+\)\s*=>\s*false\s*\)");
    if (pushRemRegex.hasMatch(content)) {
      content = content.replaceAllMapped(pushRemRegex, (m) {
        return "context.go(${m.group(1)})";
      });
      changed = true;
    }

    // Navigator.popUntil(context, ModalRoute.withName('/host-dashboard')) -> context.go('/host-dashboard')
    final popUntilRegex = RegExp(r"Navigator\.popUntil\s*\(\s*context\s*,\s*ModalRoute\.withName\s*\(\s*('[^']+')\s*\)\s*\)");
    if (popUntilRegex.hasMatch(content)) {
      content = content.replaceAllMapped(popUntilRegex, (m) {
        return "context.go(${m.group(1)})";
      });
      changed = true;
    }

    // Navigator.pop(context) doesn't strictly need context.pop() but we can leave it or replace it.
    // go_router context.pop() works the same as Navigator.pop(context). Let's change it.
    final popRegex = RegExp(r"Navigator\.pop\s*\(\s*context\s*\)");
    if (popRegex.hasMatch(content)) {
      content = content.replaceAllMapped(popRegex, (m) {
        return "context.pop()";
      });
      changed = true;
    }

    if (changed) {
      if (!content.contains("import 'package:go_router/go_router.dart';")) {
        // Insert after first import, or at the top
        final firstImportIdx = content.indexOf('import');
        if (firstImportIdx != -1) {
          final endOfLine = content.indexOf(';', firstImportIdx) + 1;
          content = "${content.substring(0, endOfLine)}\nimport 'package:go_router/go_router.dart';${content.substring(endOfLine)}";
        } else {
          content = "import 'package:go_router/go_router.dart';\n$content";
        }
      }
      file.writeAsStringSync(content);
      print("Updated ${file.path}");
    }
  }
}
