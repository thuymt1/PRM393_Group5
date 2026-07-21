import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../models/homestay_model.dart';

class HostDashboardState {
  const HostDashboardState({
    required this.bookings,
    required this.homestays,
    required this.profile,
    required this.accountEmail,
  });
  final List<Map<String, dynamic>> bookings;
  final List<Homestay> homestays;
  final Map<String, dynamic>? profile;
  final String? accountEmail;

  HostDashboardSummary get summary => HostDashboardSummary.fromDashboard(this);
}

class HostDashboardSummary {
  const HostDashboardSummary({
    required this.totalConfirmedEarnings,
    required this.confirmedBookings,
    required this.pendingBookings,
    required this.cancellationBookings,
    required this.highlightedBooking,
  });

  factory HostDashboardSummary.fromDashboard(HostDashboardState dashboard) {
    var totalConfirmedEarnings = 0.0;
    var confirmedBookings = 0;
    var pendingBookings = 0;
    var cancellationBookings = 0;

    for (final booking in dashboard.bookings) {
      switch (booking['status']) {
        case 'confirmed':
          final price = booking['total_price'];
          totalConfirmedEarnings += price is num
              ? price.toDouble()
              : double.tryParse(price?.toString() ?? '') ?? 0;
          confirmedBookings++;
        case 'pending':
          pendingBookings++;
        case 'cancel_pending':
          cancellationBookings++;
      }
    }

    final highlightedBooking = dashboard.bookings.firstWhere(
      (booking) => booking['status'] == 'pending',
      orElse: () => dashboard.bookings.isNotEmpty
          ? dashboard.bookings.first
          : <String, dynamic>{},
    );

    return HostDashboardSummary(
      totalConfirmedEarnings: totalConfirmedEarnings,
      confirmedBookings: confirmedBookings,
      pendingBookings: pendingBookings,
      cancellationBookings: cancellationBookings,
      highlightedBooking: highlightedBooking,
    );
  }

  final double totalConfirmedEarnings;
  final int confirmedBookings;
  final int pendingBookings;
  final int cancellationBookings;
  final Map<String, dynamic> highlightedBooking;
}

class HostDashboardViewModel extends AsyncNotifier<HostDashboardState> {
  @override
  Future<HostDashboardState> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> updateBooking(int id, String status) async {
    await ref.read(bookingRepositoryProvider).updateStatus(id, status);
    await refresh();
  }

  Future<HostDashboardState> _load() async {
    final (bookings, homestays, profile) = await (
      ref.read(bookingRepositoryProvider).getHostRequests(),
      ref.read(homestayRepositoryProvider).getMine(),
      ref.read(profileRepositoryProvider).getMine(),
    ).wait;

    return HostDashboardState(
      bookings: bookings
          .whereType<Map>()
          .map(Map<String, dynamic>.from)
          .toList(growable: false),
      homestays: homestays,
      profile: profile,
      accountEmail: ref.read(authRepositoryProvider).currentUser?.email,
    );
  }
}

final hostDashboardViewModelProvider =
    AsyncNotifierProvider<HostDashboardViewModel, HostDashboardState>(
      HostDashboardViewModel.new,
    );
