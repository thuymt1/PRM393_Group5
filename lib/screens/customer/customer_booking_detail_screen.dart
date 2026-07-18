import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/repository_providers.dart';
import 'cancel_booking_page.dart';

class CustomerBookingDetailScreen extends ConsumerWidget {
  const CustomerBookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Nhận dữ liệu booking từ argument
    final booking =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final homestay = booking['homestays'];

    final checkIn = DateTime.parse(booking['check_in']);
    final checkOut = DateTime.parse(booking['check_out']);
    final createdAt = DateTime.parse(booking['created_at']);
    final nights = checkOut.difference(checkIn).inDays;

    final double totalPrice = (booking['total_price'] ?? 0.0).toDouble();
    final String totalPriceStr =
        '${totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';

    String imageUrl =
        'https://images.unsplash.com/photo-1510798831971-661eb04b3739';
    if (homestay != null &&
        homestay['homestay_images'] != null &&
        (homestay['homestay_images'] as List).isNotEmpty) {
      imageUrl = homestay['homestay_images'][0]['url'];
    }

    Color statusColor = Colors.orange;
    String statusText = 'Đang xử lý';
    if (booking['status'] == 'confirmed') {
      statusColor = Colors.green;
      statusText = 'Đã xác nhận';
    } else if (booking['status'] == 'cancelled') {
      statusColor = Colors.red;
      statusText = 'Đã hủy';
    } else if (booking['status'] == 'rejected') {
      statusColor = Colors.red;
      statusText = 'Bị từ chối';
    }

    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết chuyến đi',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh homestay
            Image.network(
              imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trạng thái và Mã đơn
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        'Mã: #BK${booking['id']}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tên Homestay & Địa chỉ
                  Text(
                    homestay?['name'] ?? 'Homestay',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${homestay?['address'] ?? ''}, ${homestay?['city'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(),
                  ),

                  // Lịch trình
                  const Text(
                    'Lịch trình của bạn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6D4C41),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateInfo(
                          'Nhận phòng',
                          dateFormat.format(checkIn),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F4E1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$nights đêm',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE07A5F),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildDateInfo(
                          'Trả phòng',
                          dateFormat.format(checkOut),
                          isEnd: true,
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(),
                  ),

                  // Chi tiết thanh toán
                  const Text(
                    'Chi tiết thanh toán',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6D4C41),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentRow(
                    'Ngày đặt phòng',
                    dateFormat.format(createdAt),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentRow('Số lượng khách', 'Tiêu chuẩn'),
                  const SizedBox(height: 12),
                  _buildPaymentRow(
                    'Tổng tiền đã thanh toán',
                    totalPriceStr,
                    isTotal: true,
                  ),

                  const SizedBox(height: 40),

                  // Hành động của khách hàng
                  if (booking['status'] == 'pending' ||
                      booking['status'] == 'confirmed')
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _requestCancel(context, booking),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Yêu cầu hủy chuyến',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                  if (booking['status'] == 'refunded')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            _confirmRefundReceived(context, ref, booking['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Đã nhận được tiền hoàn',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _requestCancel(
    BuildContext context,
    Map<String, dynamic> booking,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CancelBookingPage(booking: booking),
      ),
    );
    if (result == true) {
      if (context.mounted) {
        Navigator.pop(context, true); // Quay về MyBookings và refresh
      }
    }
  }

  void _confirmRefundReceived(
    BuildContext context,
    WidgetRef ref,
    int bookingId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận nhận tiền'),
        content: const Text(
          'Bạn xác nhận đã nhận đủ tiền hoàn từ chủ nhà? Thao tác này sẽ kết thúc hoàn toàn chuyến đi này.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Chưa nhận',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(bookingRepositoryProvider)
                    .updateStatus(bookingId, 'cancelled');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xác nhận hoàn tiền thành công!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true); // Quay về và báo hiệu refresh
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              'Đã nhận đủ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String title, String date, {bool isEnd = false}) {
    return Column(
      crossAxisAlignment: isEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF424242),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? const Color(0xFF424242) : Colors.grey,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? const Color(0xFFE07A5F) : const Color(0xFF424242),
          ),
        ),
      ],
    );
  }
}
