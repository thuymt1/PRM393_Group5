import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../models/homestay_model.dart';
import '../models/customer_home_state.dart';

class CustomerHomeViewModel extends AsyncNotifier<CustomerHomeState> {
  static const _pageSize = 10;

  @override
  Future<CustomerHomeState> build() async {
    final homes = await _loadHomes(page: 0, search: '', category: 'Tất cả');
    final favorites = await ref
        .read(homestayRepositoryProvider)
        .getFavoriteIds();
    final bookings = await ref.read(bookingRepositoryProvider).getMine();
    final profile = await ref.read(profileRepositoryProvider).getMine();
    return CustomerHomeState(
      homestays: homes,
      favoriteIds: favorites.toSet(),
      bookings: bookings,
      profile: profile,
      hasMore: homes.length >= _pageSize,
    );
  }

  Future<void> refresh() async {
    final previous = state.value ?? const CustomerHomeState();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final homes = await _loadHomes(
        page: 0,
        search: previous.searchQuery,
        category: previous.category,
      );
      final favorites = await ref
          .read(homestayRepositoryProvider)
          .getFavoriteIds();
      final bookings = await ref.read(bookingRepositoryProvider).getMine();
      final profile = await ref.read(profileRepositoryProvider).getMine();
      return previous.copyWith(
        homestays: homes,
        favoriteIds: favorites.toSet(),
        bookings: bookings,
        profile: profile,
        page: 0,
        hasMore: homes.length >= _pageSize,
      );
    });
  }

  Future<void> applyFilter({String? search, String? category}) async {
    final current = state.value ?? const CustomerHomeState();
    final nextSearch = search ?? current.searchQuery;
    final nextCategory = category ?? current.category;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final homes = await _loadHomes(
        page: 0,
        search: nextSearch,
        category: nextCategory,
      );
      return current.copyWith(
        homestays: homes,
        page: 0,
        hasMore: homes.length >= _pageSize,
        searchQuery: nextSearch,
        category: nextCategory,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.page + 1;
      final homes = await _loadHomes(
        page: nextPage,
        search: current.searchQuery,
        category: current.category,
      );
      state = AsyncData(
        current.copyWith(
          homestays: [...current.homestays, ...homes],
          page: nextPage,
          hasMore: homes.length >= _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> toggleFavorite(Homestay home) async {
    final current = state.value;
    if (current == null) return;
    final wasFavorite = current.favoriteIds.contains(home.id);
    final optimistic = {...current.favoriteIds};
    wasFavorite ? optimistic.remove(home.id) : optimistic.add(home.id);
    state = AsyncData(current.copyWith(favoriteIds: optimistic));
    try {
      final repository = ref.read(homestayRepositoryProvider);
      if (wasFavorite) {
        await repository.removeFavorite(home.id);
      } else {
        await repository.addFavorite(home.id);
      }
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(current);
      rethrow;
    }
  }

  Future<List<Homestay>> _loadHomes({
    required int page,
    required String search,
    required String category,
  }) {
    return ref
        .read(homestayRepositoryProvider)
        .getHomestays(
          page: page,
          pageSize: _pageSize,
          searchQuery: search.isEmpty ? null : search,
          category: category == 'Tất cả' ? null : category,
        );
  }
}

final customerHomeViewModelProvider =
    AsyncNotifierProvider<CustomerHomeViewModel, CustomerHomeState>(
      CustomerHomeViewModel.new,
    );
