import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../models/booking_form_state.dart';

class BookingFormViewModel extends Notifier<BookingFormState> {
  @override
  BookingFormState build() => const BookingFormState();

  Future<void> loadBookedDates(int homestayId) async {
    final ranges = await ref
        .read(bookingRepositoryProvider)
        .getBookedRanges(homestayId);
    state = state.copyWith(
      bookedDates: ranges
          .map(
            (range) => BookedDateRange(
              start: DateTime.parse(range['check_in']!),
              end: DateTime.parse(range['check_out']!),
            ),
          )
          .toList(),
    );
  }

  Future<bool> checkAvailability({
    required int homestayId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    state = state.copyWith(isCheckingAvailability: true, isDateAvailable: true);
    final available = await ref
        .read(bookingRepositoryProvider)
        .isAvailable(
          homestayId: homestayId,
          checkIn: checkIn.toIso8601String().split('T').first,
          checkOut: checkOut.toIso8601String().split('T').first,
        );
    state = state.copyWith(
      isCheckingAvailability: false,
      isDateAvailable: available,
    );
    return available;
  }
}

final bookingFormViewModelProvider =
    NotifierProvider<BookingFormViewModel, BookingFormState>(
      BookingFormViewModel.new,
    );
