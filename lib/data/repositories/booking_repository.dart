import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BookingRepository {
  Future<bool> isAvailable({
    required int homestayId,
    required String checkIn,
    required String checkOut,
  });
  Future<List<Map<String, String>>> getBookedRanges(int homestayId);
  Future<void> create({
    required int homestayId,
    required String checkIn,
    required String checkOut,
    required double totalPrice,
  });
  Future<List<dynamic>> getMine();
  Future<List<dynamic>> getHostRequests();
  Future<List<dynamic>> getAdminRequests();
  Future<void> updateStatus(int bookingId, String status);
}

class SupabaseBookingRepository implements BookingRepository {
  const SupabaseBookingRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<bool> isAvailable({
    required int homestayId,
    required String checkIn,
    required String checkOut,
  }) async {
    final rows = await _client
        .from('bookings')
        .select('id')
        .eq('homestay_id', homestayId)
        .not('status', 'in', '(cancelled,rejected,refunded)')
        .lt('check_in', checkOut)
        .gt('check_out', checkIn);
    return (rows as List).isEmpty;
  }

  @override
  Future<List<Map<String, String>>> getBookedRanges(int homestayId) async {
    final rows = await _client
        .from('bookings')
        .select('check_in, check_out')
        .eq('homestay_id', homestayId)
        .not('status', 'in', '(cancelled,rejected,refunded)');
    return (rows as List)
        .map(
          (row) => {
            'check_in': row['check_in'] as String,
            'check_out': row['check_out'] as String,
          },
        )
        .toList();
  }

  @override
  Future<void> create({
    required int homestayId,
    required String checkIn,
    required String checkOut,
    required double totalPrice,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Chưa đăng nhập');
    if (!await isAvailable(
      homestayId: homestayId,
      checkIn: checkIn,
      checkOut: checkOut,
    )) {
      throw Exception('Homestay đã có người đặt trong thời gian này');
    }
    await _client.from('bookings').insert({
      'customer_id': user.id,
      'homestay_id': homestayId,
      'check_in': checkIn,
      'check_out': checkOut,
      'total_price': totalPrice,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<dynamic>> getMine() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    return _client
        .from('bookings')
        .select('*, homestays(*, homestay_images(url))')
        .eq('customer_id', user.id)
        .order('created_at', ascending: false);
  }

  @override
  Future<List<dynamic>> getHostRequests() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final homes = await _client
        .from('homestays')
        .select('id')
        .eq('host_id', user.id);
    final ids = (homes as List)
        .map((row) => int.tryParse(row['id'].toString()))
        .whereType<int>()
        .toList();
    if (ids.isEmpty) return [];

    final rows = await _client
        .from('bookings')
        .select('*, homestays(*, homestay_images(url))')
        .inFilter('homestay_id', ids)
        .neq('status', 'payment_pending')
        .order('created_at', ascending: false);
    return _attachCustomerProfiles(rows as List);
  }

  @override
  Future<List<dynamic>> getAdminRequests() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final rows = await _client
        .from('bookings')
        .select('*, homestays(*, homestay_images(url))')
        .order('created_at', ascending: false);
    return _attachCustomerProfiles(rows as List);
  }

  @override
  Future<void> updateStatus(int bookingId, String status) async {
    final rows = await _client
        .from('bookings')
        .update({'status': status})
        .eq('id', bookingId)
        .select();
    if ((rows as List).isEmpty) {
      throw Exception(
        'Không thể cập nhật đơn. Hãy kiểm tra quyền RLS của tài khoản.',
      );
    }
  }

  Future<List<dynamic>> _attachCustomerProfiles(List<dynamic> rawRows) async {
    final bookings = rawRows
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
    final customerIds = bookings
        .map((booking) => booking['customer_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();
    if (customerIds.isEmpty) return bookings;

    final profileRows = await _client
        .from('profiles')
        .select('id, full_name, email, avatar_url')
        .inFilter('id', customerIds);
    final profilesById = <String, Map<String, dynamic>>{
      for (final row in profileRows as List)
        row['id'].toString(): Map<String, dynamic>.from(row as Map),
    };
    for (final booking in bookings) {
      booking['profiles'] = profilesById[booking['customer_id']?.toString()];
    }
    return bookings;
  }
}
