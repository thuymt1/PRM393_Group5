import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../core/network/api_client.dart';

/// Repository cho Auth: dang nhap, dang ky (qua Supabase Auth)
/// va cap nhat profile/role (qua Spring Boot Backend)
class AuthRepository {
  final _supabase = Supabase.instance.client;
  final _api = ApiClient();

  /// Dang nhap bang email + password qua Supabase Auth
  /// Tra ve JWT va thong tin user
  Future<AuthResponse> login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Dang ky tai khoan moi qua Supabase Auth
  Future<AuthResponse> register(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Dang xuat
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  /// Lay profile cua user dang dang nhap tu Backend
  Future<ProfileModel?> getMyProfile() async {
    try {
      final json = await _api.get('/profiles/me');
      return ProfileModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Cap nhat role sau khi chon (Customer / Host / Author)
  Future<ProfileModel> updateRole(String role) async {
    final json = await _api.put('/profiles/me/role', {'role': role});
    return ProfileModel.fromJson(json);
  }

  /// Reset mat khau qua Supabase (gui email)
  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
