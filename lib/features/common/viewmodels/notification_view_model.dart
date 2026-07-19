import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repository_providers.dart';

class NotificationViewModel extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() => _load();

  Future<List<Map<String, dynamic>>> _load() async {
    final notifications = await ref
        .read(notificationRepositoryProvider)
        .getAll();
    notifications.sort(
      (a, b) => DateTime.parse(
        b['time'].toString(),
      ).compareTo(DateTime.parse(a['time'].toString())),
    );
    return notifications;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
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
