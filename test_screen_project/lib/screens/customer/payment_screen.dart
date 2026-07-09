import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/booking_viewmodel.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? payload;
  const PaymentScreen({super.key, this.payload});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _selectedPaymentMethod = 0; 

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Ví MoMo', 'icon': Icons.account_balance_wallet_outlined, 'color': Colors.pink},
    {'name': 'ZaloPay', 'icon': Icons.wallet_membership_outlined, 'color': Colors.blue},
    {'name': 'Chuyển khoản ngân hàng', 'icon': Icons.account_balance_outlined, 'color': const Color(0xFF6D4C41)},
    {'name': 'Thẻ tín dụng / Ghi nợ', 'icon': Icons.credit_card_outlined, 'color': const Color(0xFFE07A5F)},
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.payload == null) {
      return const Scaffold(body: Center(child: Text('Lỗi: Không tìm thấy thông tin thanh toán')));
    }

    final payload = widget.payload!;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(payload),
            const SizedBox(height: 32),
            const Text(
              'Chọn phương thức thanh toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D4C41),
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodsList(),
            const SizedBox(height: 40),
            _buildPayButton(payload),
            const SizedBox(height: 24),
            _buildSecurityNotice(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(Map<String, dynamic> payload) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final homestayName = payload['homestayName'] as String? ?? 'Homestay';
    final totalPrice = payload['totalPrice'] as double? ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mã đơn hàng', style: TextStyle(color: Colors.grey)),
              const Text(
                'Đang tạo...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D4C41),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _summaryRow('Homestay', homestayName),
          const SizedBox(height: 12),
          _summaryRow('Tổng thanh toán', formatCurrency.format(totalPrice), isBold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 15),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 18 : 15,
              color: isBold ? const Color(0xFFE07A5F) : const Color(0xFF424242),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsList() {
    return Column(
      children: List.generate(_paymentMethods.length, (index) {
        final method = _paymentMethods[index];
        final isSelected = _selectedPaymentMethod == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6D4C41).withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF6D4C41) : Colors.grey.shade200,
                width: 1.5,
              ),
              boxShadow: [
                if (!isSelected)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (method['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(method['icon'], color: method['color'], size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    method['name'],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 16,
                      color: const Color(0xFF424242),
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF6D4C41) : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6D4C41),
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPayButton(Map<String, dynamic> payload) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final totalPrice = payload['totalPrice'] as double? ?? 0.0;
    final bookingState = ref.watch(bookingViewModelProvider);

    return ElevatedButton(
      onPressed: bookingState.isSubmitting ? null : () async {
        final homestayId = payload['homestayId'] as int;
        final checkIn = payload['checkIn'] as String;
        final checkOut = payload['checkOut'] as String;
        
        final success = await ref.read(bookingViewModelProvider.notifier).createBooking(
          homestayId: homestayId,
          checkIn: checkIn,
          checkOut: checkOut,
          totalPrice: totalPrice,
        );

        if (!mounted) return;

        if (success) {
          _showSuccessDialog(context);
        } else {
          final err = ref.read(bookingViewModelProvider).error;
          if (err != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
            ref.read(bookingViewModelProvider.notifier).clearError();
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE07A5F),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: const Color(0xFFE07A5F).withValues(alpha: 0.4),
      ),
      child: bookingState.isSubmitting 
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : Text(
            'Thanh toán ${formatCurrency.format(totalPrice)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thanh toán thành công!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Cảm ơn bạn đã sử dụng dịch vụ. Booking của bạn đang chờ chủ nhà xác nhận.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.go('/my-bookings'); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D4C41),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Xem danh sách phòng đã đặt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          'Thanh toán an toàn và bảo mật 100%',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}