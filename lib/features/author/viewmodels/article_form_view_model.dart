import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';

class ArticleFormViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(String title, String content) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(articleRepositoryProvider).create(title, content),
    );
    if (state.hasError) throw state.error!;
  }
}

final articleFormViewModelProvider =
    AsyncNotifierProvider<ArticleFormViewModel, void>(ArticleFormViewModel.new);
