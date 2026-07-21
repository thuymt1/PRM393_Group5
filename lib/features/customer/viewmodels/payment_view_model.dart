import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';

class PaymentViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> createBooking({
    required int homestayId,
    required String checkIn,
    required String checkOut,
    required double totalPrice,
  }) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(bookingRepositoryProvider);
      final available = await repository.isAvailable(
        homestayId: homestayId,
        checkIn: checkIn,
        checkOut: checkOut,
      );
      if (!available) {
        state = const AsyncData(null);
        return false;
      }
      await repository.create(
        homestayId: homestayId,
        checkIn: checkIn,
        checkOut: checkOut,
        totalPrice: totalPrice,
      );
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final paymentViewModelProvider = AsyncNotifierProvider<PaymentViewModel, void>(
  PaymentViewModel.new,
);
