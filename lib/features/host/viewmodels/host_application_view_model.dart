import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../models/host_application_model.dart';

class HostApplicationViewModel extends AsyncNotifier<HostApplication?> {
  @override
  Future<HostApplication?> build() =>
      ref.read(hostApplicationRepositoryProvider).getMine();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(hostApplicationRepositoryProvider).getMine(),
    );
  }
}

final hostApplicationViewModelProvider =
    AsyncNotifierProvider<HostApplicationViewModel, HostApplication?>(
      HostApplicationViewModel.new,
    );
