import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';
import '../utils/error_handler.dart';

class ProfileState {
  final bool isLoading;
  final ProfileModel? profile;
  final String? error;

  const ProfileState({this.isLoading = false, this.profile, this.error});

  ProfileState copyWith({bool? isLoading, ProfileModel? profile, String? error}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  final ProfileRepository _repo;

  ProfileViewModel(this._repo) : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repo.getMyProfile();
      state = state.copyWith(isLoading: false, profile: profile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorHandler.getMessage(e));
    }
  }

  Future<void> updateProfile({String? fullName, String? phone, String? avatarUrl}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _repo.updateProfile(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      state = state.copyWith(isLoading: false, profile: updated);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorHandler.getMessage(e));
    }
  }
}

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>(
  (ref) => ProfileViewModel(ProfileRepository()),
);

