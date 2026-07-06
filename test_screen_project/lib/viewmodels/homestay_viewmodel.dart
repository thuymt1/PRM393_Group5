import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/homestay_model.dart';
import '../repositories/homestay_repository.dart';

class HomestayState {
  final bool isLoading;
  final List<Homestay> homestays;
  final String? error;
  final String searchQuery;

  const HomestayState({
    this.isLoading = false,
    this.homestays = const [],
    this.error,
    this.searchQuery = '',
  });

  HomestayState copyWith({
    bool? isLoading,
    List<Homestay>? homestays,
    String? error,
    String? searchQuery,
  }) {
    return HomestayState(
      isLoading: isLoading ?? this.isLoading,
      homestays: homestays ?? this.homestays,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HomestayViewModel extends StateNotifier<HomestayState> {
  final HomestayRepository _repo;

  HomestayViewModel(this._repo) : super(const HomestayState());

  Future<void> loadHomestays({String? search}) async {
    state = state.copyWith(isLoading: true, error: null, searchQuery: search ?? '');
    try {
      final list = await _repo.getHomestays(search: search);
      state = state.copyWith(isLoading: false, homestays: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> search(String query) => loadHomestays(search: query.isEmpty ? null : query);
}

// Provider — Host xem homestay cua minh
class HostHomestayViewModel extends StateNotifier<HomestayState> {
  final HomestayRepository _repo;

  HostHomestayViewModel(this._repo) : super(const HomestayState());

  Future<void> loadMyHomestays() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getMyHomestays();
      state = state.copyWith(isLoading: false, homestays: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createHomestay(Map<String, dynamic> data, String? imageUrl) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final homestay = await _repo.createHomestay(data, imageUrl);
      state = state.copyWith(isLoading: false, homestays: [homestay, ...state.homestays]);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

// Riverpod Providers
final homestayViewModelProvider = StateNotifierProvider<HomestayViewModel, HomestayState>(
  (ref) => HomestayViewModel(HomestayRepository()),
);

final hostHomestayViewModelProvider = StateNotifierProvider<HostHomestayViewModel, HomestayState>(
  (ref) => HostHomestayViewModel(HomestayRepository()),
);
