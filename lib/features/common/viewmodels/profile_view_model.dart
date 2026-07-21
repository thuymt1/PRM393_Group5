import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';

class ProfileViewModel extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() =>
      ref.read(profileRepositoryProvider).getMine();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(profileRepositoryProvider).getMine(),
    );
  }

  Future<void> uploadAvatar({
    required Uint8List bytes,
    required String ext,
  }) async {
    await ref
        .read(profileRepositoryProvider)
        .uploadAvatar(bytes: bytes, ext: ext);
    await refresh();
  }
}


final profileViewModelProvider =
    AsyncNotifierProvider<ProfileViewModel, Map<String, dynamic>?>(
      ProfileViewModel.new,
    );
