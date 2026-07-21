import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/homestay_model.dart';

enum HostHomestaySort { newest, nameAsc, nameDesc, priceLow, priceHigh }

class HostHomestaysState {
  const HostHomestaysState({
    this.query = '',
    this.statusFilter = 'all',
    this.sort = HostHomestaySort.newest,
  });

  final String query;
  final String statusFilter;
  final HostHomestaySort sort;

  HostHomestaysState copyWith({
    String? query,
    String? statusFilter,
    HostHomestaySort? sort,
  }) {
    return HostHomestaysState(
      query: query ?? this.query,
      statusFilter: statusFilter ?? this.statusFilter,
      sort: sort ?? this.sort,
    );
  }

  List<Homestay> applyTo(List<Homestay> homestays) {
    final normalizedQuery = query.trim().toLowerCase();
    final filtered = homestays
        .where((homestay) {
          final matchesStatus = switch (statusFilter) {
            'active' => homestay.status == 'active',
            'hidden' => homestay.status != 'active',
            _ => true,
          };
          if (!matchesStatus) return false;
          if (normalizedQuery.isEmpty) return true;

          return [
            homestay.name,
            homestay.address,
            homestay.city,
            homestay.category,
          ].join(' ').toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);

    final sorted = [...filtered];
    sorted.sort((left, right) {
      return switch (sort) {
        HostHomestaySort.nameAsc => left.name.toLowerCase().compareTo(
          right.name.toLowerCase(),
        ),
        HostHomestaySort.nameDesc => right.name.toLowerCase().compareTo(
          left.name.toLowerCase(),
        ),
        HostHomestaySort.priceLow => left.pricePerNight.compareTo(
          right.pricePerNight,
        ),
        HostHomestaySort.priceHigh => right.pricePerNight.compareTo(
          left.pricePerNight,
        ),
        HostHomestaySort.newest => right.id.compareTo(left.id),
      };
    });
    return sorted;
  }
}

class HostHomestaysViewModel extends Notifier<HostHomestaysState> {
  @override
  HostHomestaysState build() => const HostHomestaysState();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status);
  }

  void setSort(HostHomestaySort sort) => state = state.copyWith(sort: sort);

  void resetFilters() => state = const HostHomestaysState();
}

final hostHomestaysViewModelProvider =
    NotifierProvider<HostHomestaysViewModel, HostHomestaysState>(
      HostHomestaysViewModel.new,
    );
