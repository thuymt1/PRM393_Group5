import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRepository {
  User? get currentUser;
  Session? get currentSession;
  Stream<AuthState> get authStateChanges;

  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String email, String password);
  Future<void> sendPasswordReset(String email);
  Future<void> updatePassword(String password);
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<AuthResponse> login(String email, String password) =>
      _client.auth.signInWithPassword(email: email, password: password);

  @override
  Future<AuthResponse> register(String email, String password) =>
      _client.auth.signUp(email: email, password: password);

  @override
  Future<void> sendPasswordReset(String email) {
    final redirectTo = Uri.base.scheme.startsWith('http')
        ? '${Uri.base.origin}/?type=recovery'
        : 'io.supabase.test_screen_project://login-callback/?type=recovery';
    return _client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
  }

  @override
  Future<void> updatePassword(String password) async {
    await _client.auth.updateUser(UserAttributes(password: password));
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}
