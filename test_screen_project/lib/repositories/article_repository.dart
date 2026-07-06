import '../models/article_model.dart';
import '../core/network/api_client.dart';

class ArticleRepository {
  final _api = ApiClient();

  Future<List<ArticleModel>> getAllArticles() async {
    final List<dynamic> json = await _api.get('/articles');
    return json.map((e) => ArticleModel.fromJson(e)).toList();
  }

  Future<List<ArticleModel>> getMyArticles() async {
    final List<dynamic> json = await _api.get('/articles/mine');
    return json.map((e) => ArticleModel.fromJson(e)).toList();
  }

  Future<ArticleModel> createArticle(String title, String content) async {
    final json = await _api.post('/articles', {'title': title, 'content': content});
    return ArticleModel.fromJson(json);
  }
}
