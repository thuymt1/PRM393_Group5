import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/homestay_model.dart';

abstract interface class HomestayRepository {
  Future<List<Homestay>> getHomestays({
    int page = 0,
    int pageSize = 10,
    String? searchQuery,
    String? category,
  });
  Future<List<Homestay>> getMine();
  Future<List<dynamic>> getCategories();
  Future<String> uploadImage(Uint8List bytes, String fileName);
  Future<void> create(Map<String, dynamic> data, String imageUrl);
  Future<List<int>> getFavoriteIds();
  Future<void> addFavorite(int homestayId);
  Future<void> removeFavorite(int homestayId);
}

class SupabaseHomestayRepository implements HomestayRepository {
  const SupabaseHomestayRepository(this._client);
  final SupabaseClient _client;

  static const _selection = '''
    *,
    homestay_images(url),
    categories(name),
    profiles!host_id(full_name, avatar_url)
  ''';

  @override
  Future<List<Homestay>> getHomestays({
    int page = 0,
    int pageSize = 10,
    String? searchQuery,
    String? category,
  }) async {
    var query = _client
        .from('homestays')
        .select(_selection)
        .eq('status', 'active');
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or(
        'name.ilike.%$searchQuery%,city.ilike.%$searchQuery%,address.ilike.%$searchQuery%',
      );
    }
    if (category != null && category.isNotEmpty) {
      final categoryRow = await _client
          .from('categories')
          .select('id')
          .eq('name', category)
          .maybeSingle();
      if (categoryRow == null) return [];
      query = query.eq('category_id', categoryRow['id']);
    }
    final rows = await query
        .order('id', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);
    return (rows as List).map((row) => Homestay.fromJson(row)).toList();
  }

  @override
  Future<List<Homestay>> getMine() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final rows = await _client
        .from('homestays')
        .select(_selection)
        .eq('host_id', user.id)
        .order('id', ascending: false);
    return (rows as List).map((row) => Homestay.fromJson(row)).toList();
  }

  @override
  Future<List<dynamic>> getCategories() =>
      _client.from('categories').select().order('name');

  @override
  Future<String> uploadImage(Uint8List bytes, String fileName) async {
    final name = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage
        .from('homestays')
        .uploadBinary(
          name,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return _client.storage.from('homestays').getPublicUrl(name);
  }

  @override
  Future<void> create(Map<String, dynamic> data, String imageUrl) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Chưa đăng nhập');
    final row = await _client
        .from('homestays')
        .insert({...data, 'host_id': user.id, 'status': 'active'})
        .select('id')
        .single();
    await _client.from('homestay_images').insert({
      'homestay_id': row['id'],
      'url': imageUrl,
    });
  }

  @override
  Future<List<int>> getFavoriteIds() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final rows = await _client
        .from('favorites')
        .select('homestay_id')
        .eq('user_id', user.id);
    return (rows as List)
        .map((row) => int.tryParse(row['homestay_id'].toString()) ?? 0)
        .where((id) => id != 0)
        .toList();
  }

  @override
  Future<void> addFavorite(int homestayId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Chưa đăng nhập');
    await _client.from('favorites').upsert({
      'user_id': user.id,
      'homestay_id': homestayId,
    });
  }

  @override
  Future<void> removeFavorite(int homestayId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Chưa đăng nhập');
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('homestay_id', homestayId);
  }
}
