import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ProfileRepository {
  Future<void> create({
    required String id,
    required String email,
    required String fullName,
    required String phone,
  });
  Future<Map<String, dynamic>?> getById(String id);
  Future<Map<String, dynamic>?> getMine();
  Future<void> updateRole(String role);
  Future<void> update({required String fullName, required String phone});
}

class SupabaseProfileRepository implements ProfileRepository {
  const SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> create({
    required String id,
    required String email,
    required String fullName,
    required String phone,
  }) => _client.from('profiles').insert({
    'id': id,
    'email': email,
    'full_name': fullName,
    'phone': phone,
    'created_at': DateTime.now().toIso8601String(),
  });

  @override
  Future<Map<String, dynamic>?> getById(String id) =>
      _client.from('profiles').select().eq('id', id).maybeSingle();

  @override
  Future<Map<String, dynamic>?> getMine() async {
    final user = _client.auth.currentUser;
    return user == null ? null : getById(user.id);
  }

  @override
  Future<void> updateRole(String role) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Chưa đăng nhập');
    final rows = await _client
        .from('profiles')
        .update({'role': role})
        .eq('id', user.id)
        .select();
    if (rows.isEmpty) throw Exception('Không thể cập nhật vai trò');
  }

  @override
  Future<void> update({required String fullName, required String phone}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Chưa đăng nhập');
    await _client
        .from('profiles')
        .update({'full_name': fullName, 'phone': phone})
        .eq('id', user.id);
  }
}
