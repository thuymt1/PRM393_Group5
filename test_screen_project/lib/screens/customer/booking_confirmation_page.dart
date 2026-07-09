import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BookingConfirmationPage extends StatelessWidget {
  final Map<String, dynamic>? payload;
  const BookingConfirmationPage({super.key, this.payload});

  @override
  Widget build(BuildContext context) {
    if (payload == null) {
      return const Scaffold(body: Center(child: Text('Lỗi: Không tìm thấy thông tin đặt phòng')));
    }

    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final homestayName = payload!['homestayName'] as String? ?? 'Homestay';
    final checkIn = payload!['checkIn'] as String? ?? '';
    final checkOut = payload!['checkOut'] as String? ?? '';
    final guests = payload!['guests'] as int? ?? 1;
    final basePrice = payload!['basePrice'] as double? ?? 0.0;
    final serviceFee = payload!['serviceFee'] as double? ?? 0.0;
    final totalPrice = payload!['totalPrice'] as double? ?? 0.0;

    // Calculate nights from checkIn and checkOut
    int nights = 1;
    try {
      final start = DateTime.parse(checkIn);
      final end = DateTime.parse(checkOut);
      nights = end.difference(start).inDays;
      if (nights <= 0) nights = 1;
    } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Xác nhận đặt phòng',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'BeVietnamPro',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepIndicator(),
            const SizedBox(height: 32),
            const Text(
              'Kiểm tra thông tin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D4C41),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng rà soát kỹ các chi tiết bên dưới trước khi thanh toán.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildInfoSection(
              title: 'Chi tiết chuyến đi',
              icon: Icons.card_travel_outlined,
              children: [
                _buildInfoRow('Homestay', homestayName),
                _buildInfoRow('Thời gian', '$checkIn đến $checkOut ($nights đêm)'),
                _buildInfoRow('Số khách', '$guests người lớn'),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              title: 'Tóm tắt thanh toán',
              icon: Icons.payments_outlined,
              children: [
                _buildInfoRow('Giá phòng ($nights đêm)', formatCurrency.format(basePrice)),
                _buildInfoRow('Phí dịch vụ', formatCurrency.format(serviceFee)),
                const Divider(height: 32),
                _buildInfoRow(
                  'Tổng cộng',
                  formatCurrency.format(totalPrice),
                  isPrimary: true,
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildActionButtons(context, payload!),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepCircle('1', 'Thông tin', true),
        _buildStepLine(true),
        _buildStepCircle('2', 'Xác nhận', true),
        _buildStepLine(false),
        _buildStepCircle('3', 'Thanh toán', false),
      ],
    );
  }

  Widget _buildStepCircle(String num, String label, bool isDone) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFFE07A5F) : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDone ? const Color(0xFFE07A5F) : Colors.grey,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 22),
        color: isActive ? const Color(0xFFE07A5F) : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFFE07A5F)),
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
        const SizedBox(height: 12),
        Container(
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
              color: isPrimary ? const Color(0xFFE07A5F) : const Color(0xFF424242),
              fontSize: isPrimary ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> payload) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            context.push('/payment', extra: payload);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6D4C41),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
          ),
          child: const Text(
            'Chuyển đến Thanh toán',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text(
            'Thay đổi thông tin',
            style: TextStyle(
              color: Color(0xFFE07A5F),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}