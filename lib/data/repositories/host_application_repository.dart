import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/host_application_model.dart';

abstract interface class HostApplicationRepository {
  Future<HostApplication?> getMine();
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
}
