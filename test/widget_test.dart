// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_screen_project/widgets/app_theme.dart';

void main() {
  testWidgets('applies the application theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.getTheme(AppTheme.accentOrange),
        home: const Scaffold(body: Text('Hearth & Horizon')),
      ),
    );

    expect(find.text('Hearth & Horizon'), findsOneWidget);
    expect(Theme.of(tester.element(find.text('Hearth & Horizon'))).brightness,
        Brightness.light);
  });
}
