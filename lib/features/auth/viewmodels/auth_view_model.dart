import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/repository_providers.dart';

class RegistrationResult {
  const RegistrationResult({required this.requiresEmailConfirmation});

  final bool requiresEmailConfirmation;
}

class AuthViewModel extends AsyncNotifier<void> {
  late final AuthRepository _auth;
  late final ProfileRepository _profiles;

  @override
  Future<void> build() async {
    _auth = ref.read(authRepositoryProvider);
    _profiles = ref.read(profileRepositoryProvider);
  }

  Future<String> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _auth.login(email, password);
      final profile = await _profiles.getMine();
      state = const AsyncData(null);
      if (profile == null) return '/choose-role';
      final role = profile['role'];
      if (role == 'admin') return '/admin-dashboard';
      if (role == 'host') return '/host-dashboard';
      if (role == 'author') return '/author-dashboard';
      if (role == 'pending_host') return '/host-pending';
      if (role == 'customer') {
        final application = await ref
            .read(hostApplicationRepositoryProvider)
            .getMine();
        if (application != null &&
            (application.status == 'pending' ||
                application.status == 'rejected')) {
          return '/host-pending';
        }
        return '/customer-home';
      }
      return '/choose-role';
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<RegistrationResult> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _auth.register(email, password);
      final user = response.user;
      if (user == null) throw Exception('Không nhận được thông tin người dùng');
      await _profiles.create(
        id: user.id,
        email: email,
        fullName: fullName,
        phone: phone,
      );
      state = const AsyncData(null);
      return RegistrationResult(
        requiresEmailConfirmation: response.session == null,
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateRole(String role) =>
      _run(() => _profiles.updateRole(role));

  Future<void> sendPasswordReset(String email) =>
      _run(() => _auth.sendPasswordReset(email));

  Future<void> updatePassword(String password) =>
      _run(() => _auth.updatePassword(password));

  Future<void> signOut() => _run(_auth.signOut);

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, void>(
  AuthViewModel.new,
);
