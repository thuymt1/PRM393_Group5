import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_screen_project/data/repositories/booking_repository.dart';
import 'package:test_screen_project/data/repositories/repository_providers.dart';
import 'package:test_screen_project/features/customer/viewmodels/booking_form_view_model.dart';
import 'package:test_screen_project/features/customer/viewmodels/payment_view_model.dart';

void main() {
  test(
    'BookingFormViewModel loads booked dates and checks availability',
    () async {
      final repository = _FakeBookingRepository();
      final container = ProviderContainer(
        overrides: [bookingRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(bookingFormViewModelProvider.notifier);
      await notifier.loadBookedDates(10);
      expect(
        container.read(bookingFormViewModelProvider).bookedDates,
        hasLength(1),
      );

      final available = await notifier.checkAvailability(
        homestayId: 10,
        checkIn: DateTime(2026, 8, 1),
        checkOut: DateTime(2026, 8, 2),
      );
      expect(available, isTrue);
      expect(
        container.read(bookingFormViewModelProvider).isCheckingAvailability,
        isFalse,
      );
    },
  );

  test(
    'PaymentViewModel creates booking only when dates are available',
    () async {
      final repository = _FakeBookingRepository();
      final container = ProviderContainer(
        overrides: [bookingRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      await container.read(paymentViewModelProvider.future);

      final created = await container
          .read(paymentViewModelProvider.notifier)
          .createBooking(
            homestayId: 10,
            checkIn: '2026-08-01',
            checkOut: '2026-08-02',
            totalPrice: 500000,
          );

      expect(created, isTrue);
      expect(repository.createCalls, 1);
    },
  );
}

class _FakeBookingRepository implements BookingRepository {
  int createCalls = 0;

  @override
  Future<bool> isAvailable({
    required int homestayId,
    required String checkIn,
    required String checkOut,
  }) async => true;

  @override
  Future<List<Map<String, String>>> getBookedRanges(int homestayId) async => [
    {'check_in': '2026-08-10', 'check_out': '2026-08-12'},
  ];

  @override
  Future<void> create({
    required int homestayId,
    required String checkIn,
    required String checkOut,
    required double totalPrice,
  }) async {
    createCalls++;
  }

  @override
  Future<List<dynamic>> getHostRequests() async => [];
  @override
  Future<List<dynamic>> getMine() async => [];
  @override
  Future<void> updateStatus(int bookingId, String status) async {}
}
