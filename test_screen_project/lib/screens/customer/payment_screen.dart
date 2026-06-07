import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0; // 0: MoMo, 1: ZaloPay, 2: Bank Transfer, 3: Credit Card

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Ví MoMo', 'icon': Icons.account_balance_wallet_outlined, 'color': Colors.pink},
    {'name': 'ZaloPay', 'icon': Icons.wallet_membership_outlined, 'color': Colors.blue},
    {'name': 'Chuyển khoản ngân hàng', 'icon': Icons.account_balance_outlined, 'color': const Color(0xFF6D4C41)},
    {'name': 'Thẻ tín dụng / Ghi nợ', 'icon': Icons.credit_card_outlined, 'color': const Color(0xFFE07A5F)},
  ];

  @override
  Widget build(BuildContext context) {
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
            _buildOrderSummary(),
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
            _buildPayButton(),
            const SizedBox(height: 24),
            _buildSecurityNotice(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              Text(
                '#BK982345',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6D4C41),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _summaryRow('Homestay', 'The Pine Hill Dalat'),
          const SizedBox(height: 12),
          _summaryRow('Thời gian', '20/06 - 22/06 (2 đêm)'),
          const SizedBox(height: 12),
          _summaryRow('Tổng thanh toán', '2.550.000đ', isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? const Color(0xFFE07A5F) : const Color(0xFF424242),
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
          onTap: () => setState(() => _selectedPaymentMethod = index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF7F4E1) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFFE07A5F) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: method['color'].withOpacity(0.1),
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
                      color: const Color(0xFF424242),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Color(0xFFE07A5F), size: 24)
                else
                  Icon(Icons.radio_button_off, color: Colors.grey.shade300, size: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed: () {
        print("Xác nhận thanh toán thành công bằng phương thức có index: $_selectedPaymentMethod");
        _showSuccessDialog(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
      ),
      child: const Text(
        'Xác nhận thanh toán',
        style: TextStyle(
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
      builder: (dialogContext) => Dialog(
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
                'Giao dịch của bạn đã được thực hiện an toàn. Bạn có thể kiểm tra thông tin đặt phòng trong Lịch sử chuyến đi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Đóng pop-up Dialog
                  Navigator.of(context).popUntil((route) => route.isFirst); // Quay lại trang chủ
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D4C41),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Đồng ý', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 14, color: Colors.grey),
        SizedBox(width: 8),
        Text(
          'Thanh toán an toàn & mã hóa SSL',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}