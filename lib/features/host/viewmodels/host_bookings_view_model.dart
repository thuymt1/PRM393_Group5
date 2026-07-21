import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'host_dashboard_view_model.dart';

enum HostBookingSort { newest, oldest, guestName, priceHigh }

class HostBookingsState {
  const HostBookingsState({
    this.query = '',
    this.statusFilter = 'all',
    this.sort = HostBookingSort.newest,
    this.updatingIds = const <int>{},
  });

  final String query;
  final String statusFilter;
  final HostBookingSort sort;
  final Set<int> updatingIds;

  HostBookingsState copyWith({
    String? query,
    String? statusFilter,
    HostBookingSort? sort,
    Set<int>? updatingIds,
  }) {
    return HostBookingsState(
      query: query ?? this.query,
      statusFilter: statusFilter ?? this.statusFilter,
      sort: sort ?? this.sort,
      updatingIds: updatingIds ?? this.updatingIds,
    );
  }

  List<Map<String, dynamic>> applyTo(List<Map<String, dynamic>> bookings) {
    final normalizedQuery = query.trim().toLowerCase();
    final filtered = bookings
        .where((booking) {
          final status = booking['status']?.toString() ?? '';
          final matchesStatus = switch (statusFilter) {
            'cancel' => const {
              'cancel_pending',
              'cancelled',
              'refunded',
            }.contains(status),
            'all' => true,
            _ => status == statusFilter,
          };
          if (!matchesStatus) return false;
          if (normalizedQuery.isEmpty) return true;

          final profile = booking['profiles'] is Map
              ? booking['profiles'] as Map
              : const <String, dynamic>{};
          final homestay = booking['homestays'] is Map
              ? booking['homestays'] as Map
              : const <String, dynamic>{};
          final searchableText = [
            booking['id'],
            profile['full_name'],
            profile['email'],
            homestay['name'],
            booking['check_in'],
            booking['check_out'],
          ].whereType<Object>().join(' ').toLowerCase();
          return searchableText.contains(normalizedQuery);
        })
        .toList(growable: false);

    final sorted = [...filtered];
    sorted.sort((left, right) {
      return switch (sort) {
        HostBookingSort.oldest => _compareCreatedAt(left, right),
        HostBookingSort.guestName => _guestNameOf(
          left,
        ).compareTo(_guestNameOf(right)),
        HostBookingSort.priceHigh => _priceOf(right).compareTo(_priceOf(left)),
        HostBookingSort.newest => _compareCreatedAt(right, left),
      };
    });
    return sorted;
  }

  static int _compareCreatedAt(
    Map<String, dynamic> left,
    Map<String, dynamic> right,
  ) {
    final leftDate = DateTime.tryParse(left['created_at']?.toString() ?? '');
    final rightDate = DateTime.tryParse(right['created_at']?.toString() ?? '');
    return (leftDate ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
      rightDate ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static double _priceOf(Map<String, dynamic> booking) {
    final price = booking['total_price'];
    return price is num
        ? price.toDouble()
        : double.tryParse(price?.toString() ?? '') ?? 0;
  }

  static String _guestNameOf(Map<String, dynamic> booking) {
    final profile = booking['profiles'];
    if (profile is! Map) return '';
    return profile['full_name']?.toString().toLowerCase() ?? '';
  }
}

class HostBookingsViewModel extends Notifier<HostBookingsState> {
  @override
  HostBookingsState build() => const HostBookingsState();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status);
  }

  void setSort(HostBookingSort sort) => state = state.copyWith(sort: sort);

  void resetFilters() =>
      state = HostBookingsState(updatingIds: state.updatingIds);

  Future<void> updateBooking(int bookingId, String status) async {
    if (state.updatingIds.contains(bookingId)) return;
    state = state.copyWith(updatingIds: {...state.updatingIds, bookingId});
    try {
      await ref
          .read(hostDashboardViewModelProvider.notifier)
          .updateBooking(bookingId, status);
    } finally {
      state = state.copyWith(
        updatingIds: {...state.updatingIds}..remove(bookingId),
      );
    }
  }
}

final hostBookingsViewModelProvider =
    NotifierProvider<HostBookingsViewModel, HostBookingsState>(
      HostBookingsViewModel.new,
    );
