import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import 'profile_view_model.dart';

class EditProfileViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> save({required String fullName, required String phone}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(profileRepositoryProvider)
          .update(fullName: fullName, phone: phone),
    );
    if (state.hasError) throw state.error!;
    ref.invalidate(profileViewModelProvider);
  }
}

final editProfileViewModelProvider =
    AsyncNotifierProvider<EditProfileViewModel, void>(EditProfileViewModel.new);
