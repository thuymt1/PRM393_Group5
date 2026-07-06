class BookingModel {
  final int id;
  final int homestayId;
  final String? homestayName;
  final String customerId;
  final String? customerName;
  final String checkIn;
  final String checkOut;
  final double totalPrice;
  final String status;
  final String createdAt;

  const BookingModel({
    required this.id,
    required this.homestayId,
    this.homestayName,
    required this.customerId,
    this.customerName,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      homestayId: json['homestay_id'] ?? 0,
      homestayName: json['homestay_name'],
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'],
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
    );
  }
}
