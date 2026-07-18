import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/customer/viewmodels/payment_view_model.dart';
import '../../models/homestay_model.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _selectedPaymentMethod =
      0; // 0: MoMo, 1: ZaloPay, 2: Bank Transfer, 3: Credit Card
  bool get _isLoading => ref.read(paymentViewModelProvider).isLoading;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Ví MoMo',
      'icon': Icons.account_balance_wallet_outlined,
      'color': Colors.pink,
    },
    {
      'name': 'ZaloPay',
      'icon': Icons.wallet_membership_outlined,
      'color': Colors.blue,
    },
    {
      'name': 'Chuyển khoản ngân hàng',
      'icon': Icons.account_balance_outlined,
      'color': const Color(0xFF6D4C41),
    },
    {
      'name': 'Thẻ tín dụng / Ghi nợ',
      'icon': Icons.credit_card_outlined,
      'color': const Color(0xFFE07A5F),
    },
  ];

  @override
  Widget build(BuildContext context) {
    ref.watch(paymentViewModelProvider);
    // Nhận thông tin đặt phòng truyền qua arguments
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Homestay homestay = args['homestay'] as Homestay;
    final DateTime checkIn = args['checkIn'] as DateTime;
    final DateTime checkOut = args['checkOut'] as DateTime;
    final double totalPrice = args['totalPrice'] as double;

    final int nights = checkOut.difference(checkIn).inDays;
    final String checkInStr = '${checkIn.day}/${checkIn.month}/${checkIn.year}';
    final String checkOutStr =
        '${checkOut.day}/${checkOut.month}/${checkOut.year}';

    final String totalPriceStr = totalPrice.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSummary(
                  homestay,
                  checkInStr,
                  checkOutStr,
                  nights,
                  totalPriceStr,
                ),
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
                _buildPayButton(
                  homestay.id,
                  checkIn.toIso8601String(),
                  checkOut.toIso8601String(),
                  totalPrice,
                ),
                const SizedBox(height: 24),
                _buildSecurityNotice(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(
    Homestay homestay,
    String checkIn,
    String checkOut,
    int nights,
    String totalPriceStr,
  ) {
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
                '#BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D4C41),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _summaryRow('Homestay', homestay.name),
          const SizedBox(height: 12),
          _summaryRow('Thời gian', '$checkIn - $checkOut ($nights đêm)'),
          const SizedBox(height: 12),
          _summaryRow('Tổng thanh toán', '${totalPriceStr}đ', isTotal: true),
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
                color: isSelected
                    ? const Color(0xFFE07A5F)
                    : Colors.transparent,
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: const Color(0xFF424242),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFE07A5F),
                    size: 24,
                  )
                else
                  Icon(
                    Icons.radio_button_off,
                    color: Colors.grey.shade300,
                    size: 24,
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPayButton(
    int homestayId,
    String checkIn,
    String checkOut,
    double totalPrice,
  ) {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () => _handlePayment(homestayId, checkIn, checkOut, totalPrice),
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

  void _handlePayment(
    int homestayId,
    String checkIn,
    String checkOut,
    double totalPrice,
  ) {
    if (_selectedPaymentMethod == 3) {
      // Thẻ tín dụng chưa hỗ trợ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tính năng thanh toán qua thẻ tín dụng đang được phát triển.',
          ),
        ),
      );
      return;
    }

    _showQRCodeDialog(homestayId, checkIn, checkOut, totalPrice);
  }

  void _showQRCodeDialog(
    int homestayId,
    String checkIn,
    String checkOut,
    double totalPrice,
  ) {
    final int amount = totalPrice.toInt();
    final String transferContent = 'ThanhToanBK$homestayId';
    // Ngân hàng MBBank (970422), STK: 0123456789
    final String vietQrUrl =
        'https://img.vietqr.io/image/970422-0123456789-compact2.jpg?amount=$amount&addInfo=$transferContent&accountName=NGUYEN%20VAN%20A';

    final bool isMoMo = _selectedPaymentMethod == 0;

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
              Text(
                isMoMo ? 'Quét mã MoMo để thanh toán' : 'Quét mã để thanh toán',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D4C41),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: isMoMo
                      ? Image.asset(
                          'assets/images/momo_qr.png',
                          height: 250,
                          width: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                                height: 250,
                                width: 250,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Thiếu file momo_qr.png',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        )
                      : Image.network(
                          vietQrUrl,
                          height: 250,
                          width: 250,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              height: 250,
                              width: 250,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFE07A5F),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                                height: 250,
                                width: 250,
                                child: Center(
                                  child: Icon(
                                    Icons.qr_code,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isMoMo
                    ? 'Vui lòng kiểm tra kỹ số tiền và tên người nhận.'
                    : 'Vui lòng giữ nguyên nội dung chuyển khoản để hệ thống duyệt tự động nhanh nhất.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Đóng pop-up QR
                  _confirmPaymentAndCreateBooking(
                    homestayId,
                    checkIn,
                    checkOut,
                    totalPrice,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D4C41),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tôi đã thanh toán',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmPaymentAndCreateBooking(
    int homestayId,
    String checkIn,
    String checkOut,
    double totalPrice,
  ) async {
    try {
      final isAvailable = await ref
          .read(paymentViewModelProvider.notifier)
          .createBooking(
            homestayId: homestayId,
            checkIn: checkIn,
            checkOut: checkOut,
            totalPrice: totalPrice,
          );
      if (!isAvailable) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Text(
                  'Hết phòng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              'Rất tiếc, homestay này đã có người đặt trong khoảng thời gian bạn chọn. Vui lòng quay lại và chọn ngày khác.',
              style: TextStyle(height: 1.5),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName('/booking-form'),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D4C41),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Chọn ngày khác',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
        return;
      }

      if (!mounted) return;
      _showSuccessDialog(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tạo đơn đặt phòng: ${e.toString()}')),
      );
    }
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D4C41),
                ),
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
                  // Quay trở lại trang chủ của khách hàng và nhảy thẳng vào tab index 2 (Chuyến đi)
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/customer-home',
                    (route) => false,
                    arguments: 2, // Mở thẳng tab Lịch trình/Đặt chỗ
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D4C41),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Đồng ý',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
