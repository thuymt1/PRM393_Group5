import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';

class HostRegistrationViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Map<String, dynamic>?> loadProfile() =>
      ref.read(profileRepositoryProvider).getMine();

  Future<void> submit({
    required String fullName,
    required String phone,
    required String email,
    required String reason,
    required String experience,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(hostApplicationRepositoryProvider)
          .submit(
            fullName: fullName,
            phone: phone,
            email: email,
            reason: reason,
            experience: experience,
          ),
    );
    if (state.hasError) throw state.error!;
  }
}

final hostRegistrationViewModelProvider =
    AsyncNotifierProvider<HostRegistrationViewModel, void>(
      HostRegistrationViewModel.new,
    );
