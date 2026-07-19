import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repository_providers.dart';
import '../../features/payments/models/refund_policy.dart';

class CancelBookingPage extends ConsumerStatefulWidget {
  const CancelBookingPage({super.key, required this.booking});

  final Map<String, dynamic> booking;

  @override
  ConsumerState<CancelBookingPage> createState() => _CancelBookingPageState();
}

class _CancelBookingPageState extends ConsumerState<CancelBookingPage> {
  final _otherReasonController = TextEditingController();
  String? _selectedReason;
  late final DateTime _checkIn;
  late final DateTime _checkOut;
  late final RefundQuote _quote;

  static const _reasons = [
    'Thay đổi kế hoạch du lịch',
    'Tìm thấy lựa chọn khác phù hợp hơn',
    'Vấn đề cá nhân hoặc sức khỏe',
    'Thời tiết, chuyến bay hoặc lý do khách quan',
    'Nhầm lẫn khi đặt phòng',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _checkIn = DateTime.parse(widget.booking['check_in'].toString());
    _checkOut = DateTime.parse(widget.booking['check_out'].toString());
    _quote = RefundPolicy.calculate(
      checkIn: _checkIn,
      totalPrice: (widget.booking['total_price'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  String _formatMoney(num value) => value.toInt().toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );

  String get _reason {
    if (_selectedReason != 'Khác') return _selectedReason ?? '';
    return _otherReasonController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
        ),
        title: const Text(
          'Hủy đặt phòng',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingCard(),
            const SizedBox(height: 24),
            _buildRefundCard(),
            const SizedBox(height: 28),
            const Text(
              'Lý do hủy phòng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D4C41),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Host sẽ được thông báo và lịch phòng được mở lại ngay sau khi bạn xác nhận.',
              style: TextStyle(color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 16),
            for (final reason in _reasons) _buildReason(reason),
            if (_selectedReason == 'Khác') ...[
              const SizedBox(height: 4),
              TextField(
                controller: _otherReasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập lý do cụ thể',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _selectedReason == null ? null : _confirmCancellation,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: const Color(0xFF6D4C41),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Xác nhận hủy và yêu cầu hoàn tiền',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Giữ lại đặt phòng này'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard() {
    final homestay = widget.booking['homestays'] as Map?;
    final name = homestay?['name']?.toString() ?? 'Homestay';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                '${_checkIn.day}/${_checkIn.month}/${_checkIn.year} – '
                '${_checkOut.day}/${_checkOut.month}/${_checkOut.year}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRefundCard() {
    final percentColor = _quote.percent == 0 ? Colors.red : Colors.green;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4E1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE07A5F).withValues(alpha: .3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chính sách hoàn tiền',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6D4C41),
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow(
            'Thời gian còn lại',
            '${_quote.daysUntilCheckIn.clamp(0, 9999)} ngày',
          ),
          _summaryRow(
            'Tổng đã thanh toán',
            '${_formatMoney(_quote.totalPrice)}đ',
          ),
          _summaryRow(
            'Mức hoàn',
            '${_quote.percent}%',
            valueColor: percentColor,
          ),
          const Divider(height: 24),
          _summaryRow(
            'Số tiền dự kiến hoàn',
            '${_formatMoney(_quote.amount)}đ',
            valueColor: percentColor,
            bold: true,
          ),
          const SizedBox(height: 12),
          const Text(
            'Số tiền chính thức được tính lại trên hệ thống khi gửi yêu cầu. Admin chuyển tiền bên ngoài ứng dụng; bạn phải xác nhận sau khi nhận đủ.',
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool bold = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF424242),
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _buildReason(String reason) {
    final selected = _selectedReason == reason;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _selectedReason = reason),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? const Color(0xFFE07A5F) : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: Text(reason)),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? const Color(0xFFE07A5F)
                    : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmCancellation() async {
    if (_selectedReason == 'Khác' && _reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập lý do hủy phòng.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận hủy phòng'),
        content: Text(
          'Mức hoàn: ${_quote.percent}%\n'
          'Dự kiến nhận lại: ${_formatMoney(_quote.amount)}đ\n\n'
          'Host và Admin sẽ nhận được yêu cầu xác nhận hủy. '
          'Bạn có chắc muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Quay lại'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Xác nhận hủy',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final nextStatus = _quote.requiresTransfer
          ? 'cancel_pending'
          : 'cancelled';
      await ref
          .read(bookingRepositoryProvider)
          .updateStatus((widget.booking['id'] as num).toInt(), nextStatus);
      if (mounted) _showSuccess(_quote);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể hủy phòng: $error')));
    }
  }

  void _showSuccess(RefundQuote refund) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 52),
        title: const Text('Đã hủy đặt phòng'),
        content: Text(
          refund.amount > 0
              ? 'Yêu cầu đã được gửi cho Admin. '
                    'Admin sẽ xử lý hoàn ${_formatMoney(refund.amount)}đ. '
              : 'Đơn đã được hủy. Theo chính sách hiện tại, '
                    'đơn này không có khoản hoàn tiền.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context, true);
            },
            child: const Text('Hoàn tất'),
          ),
        ],
      ),
    );
  }
}
