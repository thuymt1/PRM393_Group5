import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/host_application_model.dart';

abstract interface class AdminRepository {
  Future<List<HostApplication>> getApplications({String? status});
  Future<void> reviewApplication({
    required String applicationId,
    required String userId,
    required String status,
    String? adminNote,
  });
  Future<List<Map<String, dynamic>>> getUsers();
  Future<List<Map<String, dynamic>>> getHomestays();
  Future<void> updateHomestayStatus(int id, String status);
  Future<void> setUserLocked(String id, bool locked);
  Future<Map<String, int>> getStats();
}

class SupabaseAdminRepository implements AdminRepository {
  const SupabaseAdminRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<HostApplication>> getApplications({String? status}) async {
    var query = _client.from('host_applications').select();
    if (status != null) query = query.eq('status', status);
    final rows = await query.order('created_at', ascending: false);
    return (rows as List).map((row) => HostApplication.fromJson(row)).toList();
  }

  @override
  Future<void> reviewApplication({
    required String applicationId,
    required String userId,
    required String status,
    String? adminNote,
  }) async {
    final admin = _client.auth.currentUser;
    if (admin == null) throw const AuthException('Chưa đăng nhập');
    await _client
        .from('host_applications')
        .update({
          'status': status,
          'admin_note': adminNote,
          'reviewed_at': DateTime.now().toIso8601String(),
          'reviewed_by': admin.id,
        })
        .eq('id', applicationId);
    await _client
        .from('profiles')
        .update({'role': status == 'approved' ? 'host' : 'customer'})
        .eq('id', userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getUsers() async =>
      List<Map<String, dynamic>>.from(
        await _client
            .from('profiles')
            .select()
            .order('created_at', ascending: false),
      );

  @override
  Future<List<Map<String, dynamic>>> getHomestays() async =>
      List<Map<String, dynamic>>.from(
        await _client
            .from('homestays')
            .select('''
        *, homestay_images(url), categories(name),
        profiles!host_id(full_name, email)
      ''')
            .order('id', ascending: false),
      );

  @override
  Future<void> updateHomestayStatus(int id, String status) =>
      _client.from('homestays').update({'status': status}).eq('id', id);

  @override
  Future<void> setUserLocked(String id, bool locked) =>
      _client.from('profiles').update({'is_locked': locked}).eq('id', id);

  @override
  Future<Map<String, int>> getStats() async {
    final results = await Future.wait([
      _client.from('profiles').select('id').neq('role', 'admin'),
      _client.from('homestays').select('id').eq('status', 'active'),
      _client.from('homestays').select('id').neq('status', 'active'),
      _client.from('bookings').select('id'),
      _client.from('host_applications').select('id').eq('status', 'pending'),
    ]);
    return {
      'total_users': results[0].length,
      'active_homestays': results[1].length,
      'inactive_homestays': results[2].length,
      'total_bookings': results[3].length,
      'pending_applications': results[4].length,
    };
  }
}
