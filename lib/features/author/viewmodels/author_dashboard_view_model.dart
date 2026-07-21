import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';

class AuthorDashboardState {
  const AuthorDashboardState({required this.articles, required this.profile});
  final List<dynamic> articles;
  final Map<String, dynamic>? profile;
}

class AuthorDashboardViewModel extends AsyncNotifier<AuthorDashboardState> {
  @override
  Future<AuthorDashboardState> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<AuthorDashboardState> _load() async => AuthorDashboardState(
    articles: await ref.read(articleRepositoryProvider).getMine(),
    profile: await ref.read(profileRepositoryProvider).getMine(),
  );
}

final authorDashboardViewModelProvider =
    AsyncNotifierProvider<AuthorDashboardViewModel, AuthorDashboardState>(
      AuthorDashboardViewModel.new,
    );
