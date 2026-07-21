import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ReviewRepository {
  Future<void> createReview({
    required int homestayId,
    required int rating,
    required String comment,
  });

  Future<List<dynamic>> getByHomestay(int homestayId);
}

class SupabaseReviewRepository implements ReviewRepository {
  const SupabaseReviewRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> createReview({
    required int homestayId,
    required int rating,
    required String comment,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Chưa đăng nhập');

    await _client.from('reviews').insert({
      'homestay_id': homestayId,
      'customer_id': user.id,
      'rating': rating,
      'comment': comment,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<dynamic>> getByHomestay(int homestayId) async {
    return _client
        .from('reviews')
        .select('*, profiles(full_name, avatar_url)')
        .eq('homestay_id', homestayId)
        .order('created_at', ascending: false);
  }
}
