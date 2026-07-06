import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';

class BookingState {
  final bool isLoading;
  final List<BookingModel> bookings;
  final String? error;
  final bool isSubmitting; // Dang gui yeu cau dat phong

  const BookingState({
    this.isLoading = false,
    this.bookings = const [],
    this.error,
    this.isSubmitting = false,
  });

  BookingState copyWith({
    bool? isLoading,
    List<BookingModel>? bookings,
    String? error,
    bool? isSubmitting,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      bookings: bookings ?? this.bookings,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

// ViewModel cho Customer xem lich su dat phong
class BookingViewModel extends StateNotifier<BookingState> {
  final BookingRepository _repo;

  BookingViewModel(this._repo) : super(const BookingState());

  Future<void> loadMyBookings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getMyBookings();
      state = state.copyWith(isLoading: false, bookings: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Dat phong moi — tra ve true neu thanh cong
  Future<bool> createBooking({
    required int homestayId,
    required String checkIn,
    required String checkOut,
    required double totalPrice,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final booking = await _repo.createBooking(
        homestayId: homestayId,
        checkIn: checkIn,
        checkOut: checkOut,
        totalPrice: totalPrice,
      );
      state = state.copyWith(
        isSubmitting: false,
        bookings: [booking, ...state.bookings],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

// ViewModel cho Host quan ly don dat phong
class HostBookingViewModel extends StateNotifier<BookingState> {
  final BookingRepository _repo;

  HostBookingViewModel(this._repo) : super(const BookingState());

  Future<void> loadHostRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getHostRequests();
      state = state.copyWith(isLoading: false, bookings: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Host duyet hoac huy don
  Future<void> updateStatus(int bookingId, String status) async {
    try {
      final updated = await _repo.updateStatus(bookingId, status);
      final updatedList = state.bookings.map((b) => b.id == bookingId ? updated : b).toList();
      state = state.copyWith(bookings: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Riverpod Providers
final bookingViewModelProvider = StateNotifierProvider<BookingViewModel, BookingState>(
  (ref) => BookingViewModel(BookingRepository()),
);

final hostBookingViewModelProvider = StateNotifierProvider<HostBookingViewModel, BookingState>(
  (ref) => HostBookingViewModel(BookingRepository()),
);
