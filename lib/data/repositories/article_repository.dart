import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ArticleRepository {
  Future<List<dynamic>> getAll();
  Future<List<dynamic>> getMine();
  Future<void> create(String title, String content);
}

class SupabaseArticleRepository implements ArticleRepository {
  const SupabaseArticleRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<dynamic>> getAll() =>
      _client.from('articles').select().order('created_at', ascending: false);

  @override
  Future<List<dynamic>> getMine() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    return _client
        .from('articles')
        .select()
        .eq('author_id', user.id)
        .order('created_at', ascending: false);
  }

  @override
  Future<void> create(String title, String content) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Chưa đăng nhập');
    await _client.from('articles').insert({
      'title': title,
      'content': content,
      'author_id': user.id,
      'status': 'published',
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
