import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_screen_project/data/repositories/auth_repository.dart';
import 'package:test_screen_project/data/repositories/profile_repository.dart';
import 'package:test_screen_project/data/repositories/repository_providers.dart';
import 'package:test_screen_project/features/auth/viewmodels/auth_view_model.dart';

void main() {
  test(
    'AuthViewModel delegates sign out and role updates to repositories',
    () async {
      final auth = _FakeAuthRepository();
      final profiles = _FakeProfileRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authViewModelProvider.future);
      await container
          .read(authViewModelProvider.notifier)
          .updateRole('customer');
      await container.read(authViewModelProvider.notifier).signOut();

      expect(profiles.updatedRole, 'customer');
      expect(auth.didSignOut, isTrue);
      expect(container.read(authViewModelProvider), isA<AsyncData<void>>());
    },
  );
}

class _FakeAuthRepository implements AuthRepository {
  bool didSignOut = false;

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();
  @override
  Session? get currentSession => null;
  @override
  User? get currentUser => null;
  @override
  Future<AuthResponse> login(String email, String password) =>
      throw UnimplementedError();
  @override
  Future<AuthResponse> register(String email, String password) =>
      throw UnimplementedError();
  @override
  Future<void> sendPasswordReset(String email) => throw UnimplementedError();
  @override
  Future<void> updatePassword(String password) => throw UnimplementedError();
  @override
  Future<void> signOut() async => didSignOut = true;
}

class _FakeProfileRepository implements ProfileRepository {
  String? updatedRole;

  @override
  Future<void> create({
    required String id,
    required String email,
    required String fullName,
    required String phone,
  }) => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>?> getById(String id) =>
      throw UnimplementedError();
  @override
  Future<Map<String, dynamic>?> getMine() => throw UnimplementedError();
  @override
  Future<void> update({required String fullName, required String phone}) =>
      throw UnimplementedError();
  @override
  Future<void> updateRole(String role) async => updatedRole = role;

  @override
  Future<String> uploadAvatar({required Uint8List bytes, required String ext}) async => '';
}
