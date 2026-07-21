import 'package:flutter_test/flutter_test.dart';
import 'package:test_screen_project/features/payments/models/refund_policy.dart';

void main() {
  group('RefundPolicy', () {
    const total = 1000000.0;
    final requestDate = DateTime(2026, 7, 19);

    test('uses the 100-70-30-0 boundaries', () {
      int percentFor(int days) => RefundPolicy.calculate(
        checkIn: requestDate.add(Duration(days: days)),
        totalPrice: total,
        requestedAt: requestDate,
      ).percent;

      expect(percentFor(7), 100);
      expect(percentFor(6), 70);
      expect(percentFor(3), 70);
      expect(percentFor(2), 30);
      expect(percentFor(1), 30);
      expect(percentFor(0), 0);
    });

    test('calculates the refund amount from the selected percentage', () {
      final quote = RefundPolicy.calculate(
        checkIn: requestDate.add(const Duration(days: 4)),
        totalPrice: total,
        requestedAt: requestDate,
      );

      expect(quote.percent, 70);
      expect(quote.amount, 700000);
    });
  });
}
