import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/host_application_model.dart';

abstract interface class HostApplicationRepository {
  Future<HostApplication?> getMine();
  Future<void> submit({
    required String fullName,
    required String phone,
    required String email,
    required String reason,
    required String experience,
  });
}

class SupabaseHostApplicationRepository implements HostApplicationRepository {
  const SupabaseHostApplicationRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<HostApplication?> getMine() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('host_applications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : HostApplication.fromJson(row);
  }

  @override
  Future<void> submit({
    required String fullName,
    required String phone,
    required String email,
    required String reason,
    required String experience,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Chưa đăng nhập');
    final existing = await _client
        .from('host_applications')
        .select('id')
        .eq('user_id', user.id)
        .eq('status', 'pending')
        .maybeSingle();
    if (existing != null) throw Exception('Bạn đã có đơn đang chờ xét duyệt');
    await _client.from('host_applications').insert({
      'user_id': user.id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'reason': reason,
      'experience': experience,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
    await _client
        .from('profiles')
        .update({'full_name': fullName, 'phone': phone})
        .eq('id', user.id);
  }
}
