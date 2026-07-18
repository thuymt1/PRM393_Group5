import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_screen_project/features/customer/viewmodels/cancellation_view_model.dart';
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

  test('UI-only cancellation follows all role confirmations in order', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(cancellationViewModelProvider.notifier);

    final request = notifier.requestCancellation(
      booking: {
        'id': 10,
        'check_in': DateTime.now()
            .add(const Duration(days: 8))
            .toIso8601String(),
        'total_price': 1000000,
        'homestays': {'name': 'Test Homestay'},
      },
      reason: 'Đổi kế hoạch',
    );
    expect(request.refundPercent, 100);

    notifier.hostAcknowledge(10);
    notifier.adminApprove(10);
    notifier.adminMarkRefundSent(10);
    notifier.customerConfirmReceived(10);
    notifier.adminNotifyHost(10);
    notifier.hostCompleteCancellation(10);

    final completed = container.read(cancellationViewModelProvider).single;
    expect(completed.hostAcknowledged, isTrue);
    expect(completed.adminApproved, isTrue);
    expect(completed.refundSent, isTrue);
    expect(completed.customerReceived, isTrue);
    expect(completed.adminNotifiedHost, isTrue);
    expect(completed.hostCompleted, isTrue);
  });

  test('Host cannot complete before Customer and Admin confirmations', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(cancellationViewModelProvider.notifier);

    notifier.requestCancellation(
      booking: {
        'id': 20,
        'check_in': DateTime.now()
            .add(const Duration(days: 4))
            .toIso8601String(),
        'total_price': 1000000,
      },
      reason: 'Lý do khác',
    );
    notifier.hostAcknowledge(20);
    notifier.hostCompleteCancellation(20);

    expect(
      container.read(cancellationViewModelProvider).single.hostCompleted,
      isFalse,
    );
  });
}
