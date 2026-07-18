import 'booking_repository.dart';
import 'profile_repository.dart';

abstract interface class NotificationRepository {
  Future<List<Map<String, dynamic>>> getAll();
}

class AppNotificationRepository implements NotificationRepository {
  const AppNotificationRepository(this._profiles, this._bookings);
  final ProfileRepository _profiles;
  final BookingRepository _bookings;

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final profile = await _profiles.getMine();
    final isHost = profile?['role'] == 'host';
    final bookings = isHost
        ? await _bookings.getHostRequests()
        : await _bookings.getMine();
    final notifications = <Map<String, dynamic>>[];
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
}
