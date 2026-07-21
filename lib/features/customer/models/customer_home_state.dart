import '../../../models/homestay_model.dart';

class CustomerHomeState {
  const CustomerHomeState({
    this.homestays = const [],
    this.favoriteIds = const {},
    this.bookings = const [],
    this.profile,
    this.page = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.searchQuery = '',
    this.category = 'Tất cả',
  });

  final List<Homestay> homestays;
  final Set<int> favoriteIds;
  final List<dynamic> bookings;
  final Map<String, dynamic>? profile;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchQuery;
  final String category;

  List<Homestay> get favoriteHomestays =>
      homestays.where((home) => favoriteIds.contains(home.id)).toList();

  CustomerHomeState copyWith({
    List<Homestay>? homestays,
    Set<int>? favoriteIds,
    List<dynamic>? bookings,
    Map<String, dynamic>? profile,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    String? category,
  }) {
    return CustomerHomeState(
      homestays: homestays ?? this.homestays,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      bookings: bookings ?? this.bookings,
      profile: profile ?? this.profile,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
    );
  }
}
