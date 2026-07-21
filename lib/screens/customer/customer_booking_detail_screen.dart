import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'cancel_booking_page.dart';

class CustomerBookingDetailScreen extends ConsumerWidget {
  const CustomerBookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    if (rawArgs == null || rawArgs is! Map) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDFAE7),
        appBar: AppBar(
          backgroundColor: Colors.white,
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
        body: const Center(
          child: Text(
            'Không tìm thấy thông tin đơn đặt phòng.',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      );
    }

    final booking = Map<String, dynamic>.from(rawArgs as Map);
    final homestay = booking['homestays'] as Map?;

    final checkIn = DateTime.tryParse(booking['check_in']?.toString() ?? '') ??
        DateTime.now();
    final checkOut =
        DateTime.tryParse(booking['check_out']?.toString() ?? '') ??
            DateTime.now().add(const Duration(days: 1));
    final createdAt =
        DateTime.tryParse(booking['created_at']?.toString() ?? '') ??
            DateTime.now();
    final nights = checkOut.difference(checkIn).inDays;

    final double totalPrice = (booking['total_price'] ?? 0.0).toDouble();
    final String totalPriceStr =
        '${totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';

    // Số lượng khách thực tế từ dữ liệu booking
    final int guestsCount = (booking['guests'] ??
            booking['guest_count'] ??
            booking['guests_count'] ??
            2) as int;

    String imageUrl =
        'https://images.unsplash.com/photo-1510798831971-661eb04b3739';
    if (homestay != null &&
        homestay['homestay_images'] != null &&
        (homestay['homestay_images'] as List).isNotEmpty) {
      imageUrl = homestay['homestay_images'][0]['url'];
    }

    Color statusColor = Colors.orange;
    String statusText = 'Đang xử lý';
    IconData statusIcon = Icons.hourglass_top_rounded;

    if (booking['status'] == 'payment_pending') {
      statusColor = Colors.orange;
      statusText = 'Chờ Admin xác minh';
      statusIcon = Icons.pending_actions_rounded;
    } else if (booking['status'] == 'pending') {
      statusColor = Colors.blue;
      statusText = 'Chờ xác nhận';
      statusIcon = Icons.schedule_rounded;
    } else if (booking['status'] == 'confirmed') {
      statusColor = const Color(0xFF2E7D32);
      statusText = 'Đã xác nhận';
      statusIcon = Icons.check_circle_rounded;
    } else if (booking['status'] == 'cancelled') {
      statusColor = Colors.red;
      statusText = 'Đã hủy';
      statusIcon = Icons.cancel_rounded;
    } else if (booking['status'] == 'rejected') {
      statusColor = Colors.red;
      statusText = 'Bị từ chối';
      statusIcon = Icons.error_rounded;
    } else if (booking['status'] == 'cancel_pending') {
      statusColor = Colors.deepOrange;
      statusText = 'Chờ hoàn tiền';
      statusIcon = Icons.autorenew_rounded;
    } else if (booking['status'] == 'refunded') {
      statusColor = Colors.indigo;
      statusText = 'Đã hoàn tiền';
      statusIcon = Icons.assignment_return_rounded;
    }

    final dateFormat = DateFormat('dd/MM/yyyy');
    final addressText =
        '${homestay?['address'] ?? ''}, ${homestay?['city'] ?? ''}';

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Image Banner với Badge mã đơn ──
            Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 240,
                    color: const Color(0xFFF7F4E1),
                    child: const Icon(
                      Icons.home_outlined,
                      color: Color(0xFF6D4C41),
                      size: 64,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Mã đơn: #BK${booking['id']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 2. Header Info & Trạng thái ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          homestay?['name'] ?? 'Homestay',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF424242),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, color: statusColor, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFE07A5F),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          addressText,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── 3. Lịch trình chuyến đi (Schedule Card) ──
                  _buildSectionContainer(
                    title: 'Lịch trình chuyến đi',
                    icon: Icons.calendar_month_outlined,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDateColumn(
                              'Nhận phòng',
                              dateFormat.format(checkIn),
                              '14:00',
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE07A5F),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$nights đêm',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            _buildDateColumn(
                              'Trả phòng',
                              dateFormat.format(checkOut),
                              '12:00',
                              isRight: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── 4. Placeholder Bản đồ vị trí (Map Placeholder with Arrow Pointer) ──
                  _buildMapPlaceholder(context, addressText),

                  const SizedBox(height: 20),

                  // ── 5. Chi tiết thanh toán & Khách hàng ──
                  _buildSectionContainer(
                    title: 'Chi tiết thanh toán',
                    icon: Icons.receipt_long_outlined,
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Mã đặt phòng',
                          '#BK${booking['id']}',
                        ),
                        const Divider(height: 20),
                        _buildDetailRow(
                          'Ngày đặt phòng',
                          dateFormat.format(createdAt),
                        ),
                        const Divider(height: 20),
                        _buildDetailRow(
                          'Số lượng khách',
                          '$guestsCount người', // Đã tự động cập nhật số khách thực tế
                        ),
                        const Divider(height: 20),
                        _buildDetailRow(
                          'Tổng tiền đã thanh toán',
                          totalPriceStr,
                          isHighlight: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── 6. Nút hành động (Hủy phòng / Đánh giá) ──
                  if (booking['status'] == 'pending' ||
                      (booking['status'] == 'confirmed' &&
                          checkOut.isAfter(DateTime.now())))
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _requestCancel(context, booking),
                        icon: const Icon(Icons.cancel_outlined,
                            color: Colors.red),
                        label: const Text(
                          'Yêu cầu hủy chuyến',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                  if (booking['status'] == 'confirmed' &&
                      checkOut.isBefore(DateTime.now()))
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/create-review',
                          arguments: booking,
                        ),
                        icon: const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 22,
                        ),
                        label: const Text(
                          'Đánh giá trải nghiệm',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF6D4C41),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
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

  // ── Helper Container Card ──
  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6D4C41), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D4C41),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ── Helper Date Column ──
  Widget _buildDateColumn(
    String label,
    String date,
    String time, {
    bool isRight = false,
  }) {
    return Column(
      crossAxisAlignment:
          isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF424242),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'từ $time',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  // ── Helper Detail Row ──
  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isHighlight ? const Color(0xFF424242) : Colors.grey.shade700,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            fontSize: isHighlight ? 15 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isHighlight ? 17 : 14,
            color:
                isHighlight ? const Color(0xFFE07A5F) : const Color(0xFF424242),
          ),
        ),
      ],
    );
  }

  // ── 4. Placeholder Bản đồ vị trí mô phỏng GPS (Map Placeholder với mũi tên định vị) ──
  Widget _buildMapPlaceholder(BuildContext context, String address) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(Icons.map_outlined, color: Color(0xFF6D4C41), size: 20),
                SizedBox(width: 8),
                Text(
                  'Vị trí trên bản đồ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6D4C41),
                  ),
                ),
              ],
            ),
          ),
          // Khung mô phỏng Map giao diện đẹp
          Container(
            height: 160,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE8F5E9), // Xanh lá cây nhạt như vùng bản đồ công viên
                  Color(0xFFE0F2F1), // Xanh lam mờ địa hình
                  Color(0xFFFFF3E0), // Vàng cát mịn
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Stack(
              children: [
                // Đường vẽ giả lập ô lưới giao thông tuyến đường Map (Grid / Roads)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapRoadsPainter(),
                  ),
                ),
                // Vòng tròn sóng định vị vị trí Homestay
                Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE07A5F).withValues(alpha: 0.2),
                    ),
                  ),
                ),
                // Mũi tên chỉ hướng + Pin đính kèm trên bản đồ
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mũi tên chỉ hướng định vị GPS xoay nghiêng
                      Transform.rotate(
                        angle: -0.5,
                        child: const Icon(
                          Icons.navigation_rounded,
                          color: Color(0xFFE07A5F),
                          size: 36,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6D4C41),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Vị trí Homestay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Huy hiệu chỉ dẫn góc dưới
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.my_location,
                          size: 12,
                          color: Color(0xFF6D4C41),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Bản đồ mô phỏng',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6D4C41),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đang mở ứng dụng Bản đồ định vị...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.directions,
                    size: 16,
                    color: Color(0xFFE07A5F),
                  ),
                  label: const Text(
                    'Chỉ đường',
                    style: TextStyle(
                      color: Color(0xFFE07A5F),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
}

// ── Painter vẽ các nét đường giao thông mờ mờ trên bản đồ Placeholder ──
class _MapRoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Đường ngang chính
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.45),
      paint,
    );
    // Đường chéo
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.8, size.height),
      paint,
    );
    // Đường cong phụ
    final path = Path()
      ..moveTo(size.width * 0.5, 0)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.7,
        size.width,
        size.height * 0.8,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
