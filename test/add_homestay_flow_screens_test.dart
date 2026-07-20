import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_screen_project/screens/host/add_homestay_basic_info_screen.dart';
import 'package:test_screen_project/screens/host/add_homestay_location_screen.dart';
import 'package:test_screen_project/screens/host/add_homestay_price_rules_screen.dart';

void main() {
  testWidgets('basic info screen fits a narrow mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: AddHomestayBasicInfoScreen()),
    );

    expect(find.text('Thông tin cơ bản'), findsOneWidget);
    expect(find.text('Bước 1/3'), findsOneWidget);
    expect(find.text('Chọn ảnh đại diện'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('location screen previews the composed address', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AddHomestayLocationScreen()),
    );

    await tester.tap(find.text('Đà Lạt').last);
    await tester.enterText(find.byType(TextFormField).at(0), '123 Trần Phú');
    await tester.enterText(find.byType(TextFormField).at(1), 'Phường 4');
    await tester.pump();

    expect(find.text('123 Trần Phú, Phường 4, Đà Lạt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('price screen formats currency and shows publish summary', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          settings: RouteSettings(
            arguments: {
              'name': 'Nhà Gỗ Đà Lạt',
              'description': 'Không gian nghỉ dưỡng giữa rừng thông.',
              'address': '123 Trần Phú, Phường 4',
              'city': 'Đà Lạt',
              'stayType': 'Toàn bộ nhà',
              'imageBytes': Uint8List.fromList([1, 2, 3]),
              'imageName': 'homestay.jpg',
            },
          ),
          builder: (_) => const AddHomestayPriceRulesScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, '1500000');
    await tester.pump();

    expect(find.text('1.500.000'), findsOneWidget);
    expect(find.text('Xem lại trước khi đăng'), findsOneWidget);
    expect(find.text('Nhà Gỗ Đà Lạt'), findsOneWidget);
    expect(find.text('Đăng homestay'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
