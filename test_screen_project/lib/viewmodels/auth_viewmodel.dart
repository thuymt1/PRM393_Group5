import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../repositories/auth_repository.dart';

/// State cua AuthViewModel
class AuthState {
  final bool isLoading;
  final ProfileModel? profile;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.profile,
    this.error,
  });

  AuthState copyWith({bool? isLoading, ProfileModel? profile, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

/// ViewModel xu ly logic dang nhap, dang ky, dang xuat
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthViewModel(this._repo) : super(const AuthState());

  /// Dang nhap — tra ve role de dieu huong
  Future<String?> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.login(email, password);
      final profile = await _repo.getMyProfile();
      state = state.copyWith(isLoading: false, profile: profile);
      return profile?.role; // 'customer' | 'host' | 'author' | null (chua chon role)
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Dang ky tai khoan moi
  Future<bool> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.register(email, password);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Dang xuat
  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  /// Chon role sau khi dang ky
  Future<void> updateRole(String role) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedProfile = await _repo.updateRole(role);
      state = state.copyWith(isLoading: false, profile: updatedProfile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

// Riverpod Provider
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(AuthRepository()),
);
