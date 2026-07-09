import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article_model.dart';
import '../repositories/article_repository.dart';
import '../utils/error_handler.dart';

class ArticleState {
  final bool isLoading;
  final List<ArticleModel> articles;
  final String? error;

  const ArticleState({
    this.isLoading = false,
    this.articles = const [],
    this.error,
  });

  ArticleState copyWith({
    bool? isLoading,
    List<ArticleModel>? articles,
    String? error,
  }) {
    return ArticleState(
      isLoading: isLoading ?? this.isLoading,
      articles: articles ?? this.articles,
      error: error,
    );
  }
}

class AuthorArticleViewModel extends StateNotifier<ArticleState> {
  final ArticleRepository _repo;

  AuthorArticleViewModel(this._repo) : super(const ArticleState());

  Future<void> loadMyArticles() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getMyArticles();
      state = state.copyWith(isLoading: false, articles: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorHandler.getMessage(e));
    }
  }

  Future<bool> createArticle(String title, String content) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final article = await _repo.createArticle(title, content);
      state = state.copyWith(isLoading: false, articles: [article, ...state.articles]);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorHandler.getMessage(e));
      return false;
    }
  }
}

final authorArticleViewModelProvider = StateNotifierProvider<AuthorArticleViewModel, ArticleState>(
  (ref) => AuthorArticleViewModel(ArticleRepository()),
);

