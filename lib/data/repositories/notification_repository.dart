import 'package:supabase_flutter/supabase_flutter.dart';
import 'booking_repository.dart';
import 'profile_repository.dart';

abstract interface class NotificationRepository {
  Future<List<Map<String, dynamic>>> getAll();
  Future<void> markAllRead();
}

class AppNotificationRepository implements NotificationRepository {
  const AppNotificationRepository(
    this._client,
    this._profiles,
    this._bookings,
  );

  final SupabaseClient _client;
  final ProfileRepository _profiles;
  final BookingRepository _bookings;

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final user = _client.auth.currentUser;
    final notifications = <Map<String, dynamic>>[];

    // 1. Lấy từ bảng notifications trên Supabase nếu có dữ liệu của user
    if (user != null) {
      try {
        final rows = await _client
            .from('notifications')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);

        if (rows.isNotEmpty) {
          for (final row in rows) {
            notifications.add({
              'id': row['id'],
              'title': row['title'] ?? 'Thông báo',
              'desc': row['message'] ?? row['title'] ?? '',
              'time': row['created_at'] ?? DateTime.now().toIso8601String(),
              'type': row['type'] ?? 'general',
              'is_unread': !(row['is_read'] ?? false),
            });
          }
          return notifications;
        }
      } catch (_) {
        // Bỏ qua nếu lỗi query table Supabase, chuyển sang fallback bên dưới
      }
    }

    // 2. Fallback: Sinh thông báo tự động từ lịch sử đơn đặt phòng (Bookings)
    final profile = await _profiles.getMine();
    final isHost = profile?['role'] == 'host';
    final bookings = isHost
        ? await _bookings.getHostRequests()
        : await _bookings.getMine();

    for (final booking in bookings) {
      final status = booking['status'];
      final homeName = booking['homestays']?['name'] ?? 'homestay';
      if (status == 'pending') {
        notifications.add({
          'title': isHost ? 'Yêu cầu thanh toán mới' : 'Đang chờ xác nhận',
          'desc': isHost
              ? 'Có yêu cầu thanh toán mới tại $homeName.'
              : 'Bạn đã gửi yêu cầu thanh toán cho $homeName.',
          'time': booking['created_at'],
          'type': 'payment_pending',
          'is_unread': isHost,
        });
      } else if (status == 'confirmed') {
        notifications.add({
          'title': 'Đặt phòng đã xác nhận',
          'desc': 'Đơn đặt phòng tại $homeName đã được xác nhận.',
          'time': booking['created_at'],
          'type': 'payment_confirmed',
          'is_unread': !isHost,
        });
      } else if (!isHost && status == 'rejected') {
        notifications.add({
          'title': 'Đặt phòng thất bại',
          'desc': 'Yêu cầu đặt phòng tại $homeName đã bị từ chối.',
          'time': booking['created_at'],
          'type': 'payment_rejected',
          'is_unread': false,
        });
      }
    }

    notifications.sort(
      (a, b) => DateTime.parse(
        b['time'].toString(),
      ).compareTo(DateTime.parse(a['time'].toString())),
    );

    return notifications;
  }

  @override
  Future<void> markAllRead() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id);
    } catch (_) {}
  }
}
