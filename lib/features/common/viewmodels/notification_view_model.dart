import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../customer/viewmodels/cancellation_view_model.dart';

class NotificationViewModel extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() {
    final cancellationRequests = ref.watch(cancellationViewModelProvider);
    return _load(cancellationRequests);
  }

  Future<List<Map<String, dynamic>>> _load(
    List<CancellationWorkflowRequest> cancellationRequests,
  ) async {
    final notifications = await ref
        .read(notificationRepositoryProvider)
        .getAll();
    final profile = await ref.read(profileRepositoryProvider).getMine();
    final role = profile?['role']?.toString() ?? 'customer';
    notifications.addAll(
      _workflowNotifications(cancellationRequests, role: role),
    );
    notifications.sort(
      (a, b) => DateTime.parse(
        b['time'].toString(),
      ).compareTo(DateTime.parse(a['time'].toString())),
    );
    return notifications;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _load(ref.read(cancellationViewModelProvider)),
    );
  }

  void markAllRead() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final item in current) {...item, 'is_unread': false},
    ]);
  }

  List<Map<String, dynamic>> _workflowNotifications(
    List<CancellationWorkflowRequest> requests, {
    required String role,
  }) {
    return [
      for (final request in requests)
        if (role == 'host' && !request.hostAcknowledged)
          _note(
            'Khách yêu cầu hủy phòng',
            'Vui lòng xác nhận đã nhận yêu cầu hủy booking #${request.bookingId}.',
            request.requestedAt,
          )
        else if (role == 'host' &&
            request.adminNotifiedHost &&
            !request.hostCompleted)
          _note(
            'Xác nhận hủy cuối cùng',
            'Customer đã nhận tiền hoàn. Hãy xác nhận hủy để mở lịch phòng.',
            request.requestedAt,
          )
        else if (role == 'admin' && !request.adminApproved)
          _note(
            'Yêu cầu hủy mới',
            'Booking #${request.bookingId} đang chờ Admin xác nhận.',
            request.requestedAt,
          )
        else if (role == 'admin' &&
            request.customerReceived &&
            !request.adminNotifiedHost)
          _note(
            'Customer đã nhận tiền hoàn',
            'Hãy gửi thông báo cho Host xác nhận hủy booking #${request.bookingId}.',
            request.requestedAt,
          )
        else if (role == 'customer' &&
            request.refundSent &&
            !request.customerReceived)
          _note(
            'Xác nhận đã nhận tiền hoàn',
            'Admin đã báo hoàn tiền. Vui lòng xác nhận đã nhận.',
            request.requestedAt,
          ),
    ];
  }

  Map<String, dynamic> _note(String title, String description, DateTime time) =>
      {
        'title': title,
        'desc': description,
        'time': time.toIso8601String(),
        'type': 'booking_cancelled',
        'is_unread': true,
      };
}

final notificationViewModelProvider =
    AsyncNotifierProvider<NotificationViewModel, List<Map<String, dynamic>>>(
      NotificationViewModel.new,
    );
