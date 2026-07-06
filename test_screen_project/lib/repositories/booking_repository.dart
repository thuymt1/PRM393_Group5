import '../models/booking_model.dart';
import '../core/network/api_client.dart';

class BookingRepository {
  final _api = ApiClient();

  Future<List<BookingModel>> getMyBookings() async {
    final List<dynamic> json = await _api.get('/bookings/my');
    return json.map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<List<BookingModel>> getHostRequests() async {
    final List<dynamic> json = await _api.get('/bookings/host-requests');
    return json.map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<BookingModel> createBooking({
    required int homestayId,
    required String checkIn,
    required String checkOut,
    required double totalPrice,
  }) async {
    final json = await _api.post('/bookings', {
      'homestay_id': homestayId,
      'check_in': checkIn,
      'check_out': checkOut,
      'total_price': totalPrice,
    });
    return BookingModel.fromJson(json);
  }

  Future<BookingModel> updateStatus(int bookingId, String status) async {
    final json = await _api.patch('/bookings/$bookingId/status', {'status': status});
    return BookingModel.fromJson(json);
  }

  Future<List<Map<String, String>>> getBookedDates(int homestayId) async {
    final List<dynamic> json = await _api.get('/bookings/homestay/$homestayId/booked-dates');
    return json.map((e) => Map<String, String>.from(e)).toList();
  }
}
