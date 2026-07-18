import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';

class NotificationViewModel extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() =>
      ref.read(notificationRepositoryProvider).getAll();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).getAll(),
    );
  }

  void markAllRead() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final item in current) {...item, 'is_unread': false},
    ]);
  }
}

final notificationViewModelProvider =
    AsyncNotifierProvider<NotificationViewModel, List<Map<String, dynamic>>>(
      NotificationViewModel.new,
    );
