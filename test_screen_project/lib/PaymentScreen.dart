import 'package:flutter/material.dart';

// Hàm main() - Điểm xuất phát khởi chạy ứng dụng Flutter
void main() {
  runApp(const MyApp());
}

// Lớp cấu hình MaterialApp dùng để bọc màn hình Thanh toán khi kiểm thử độc lập
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Test Thanh Toán',
      debugShowCheckedModeBanner: false, // Ẩn banner chữ DEBUG ở góc phải màn hình
      theme: ThemeData(
        primaryColor: const Color(0xFF6D4C41), // Thiết lập màu sắc nâu chủ đạo hệ thống
        useMaterial3: true, // Kích hoạt quy chuẩn giao diện Material 3 mới nhất
      ),
      home: const PaymentScreen(), // Đặt PaymentScreen làm màn hình hiển thị đầu tiên khi mở app
    );
  }
}

// Màn hình lựa chọn phương thức và xác nhận thanh toán đơn hàng
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Chỉ mục lưu trữ phương thức thanh toán đang được người dùng lựa chọn (Mặc định là 0: MoMo)
  int _selectedPaymentMethod = 0; // 0: MoMo, 1: ZaloPay, 2: Bank Transfer, 3: Credit Card

  // Danh sách cấu hình các phương thức thanh toán được hệ thống hỗ trợ
  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Ví MoMo', 'icon': Icons.account_balance_wallet_outlined, 'color': Colors.pink},
    {'name': 'ZaloPay', 'icon': Icons.wallet_membership_outlined, 'color': Colors.blue},
    {'name': 'Chuyển khoản ngân hàng', 'icon': Icons.account_balance_outlined, 'color': const Color(0xFF6D4C41)},
    {'name': 'Thẻ tín dụng / Ghi nợ', 'icon': Icons.credit_card_outlined, 'color': const Color(0xFFE07A5F)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Màu nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Làm trong suốt thanh AppBar phía trên
        elevation: 0, // Loại bỏ hiệu ứng bóng đổ của AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
          onPressed: () => Navigator.pop(context), // Quay trở lại màn hình trước đó khi bấm
        ),
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            color: Color(0xFF6D4C41), // Tông màu nâu đậm chủ đạo cho văn bản tiêu đề
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro', // Cần cấu hình font tương ứng trong pubspec.yaml để hiển thị chuẩn
          ),
        ),
        centerTitle: true, // Căn giữa tiêu đề trên thanh AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0), // Tạo khoảng cách đệm 24 đơn vị xung quanh nội dung body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(), // Khối hiển thị tóm tắt thông tin hóa đơn đơn đặt phòng
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
            _buildPaymentMethodsList(), // Khối danh sách các tùy chọn phương thức thanh toán (Radio list)
            const SizedBox(height: 40),
            _buildPayButton(), // Nút xác nhận thực hiện tiến trình thanh toán đơn hàng
            const SizedBox(height: 24),
            _buildSecurityNotice(), // Khối thông báo cam kết bảo mật mã hóa thông tin thanh toán
          ],
        ),
      ),
    );
  }

  // Khối giao diện tóm tắt thông tin chi tiết của đơn đặt phòng (Hóa đơn)
  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Thiết lập bo tròn góc thẻ hóa đơn 24 đơn vị
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Đổ bóng nhẹ phía dưới tạo hiệu ứng nổi bề mặt
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
          const Divider(height: 32), // Đường thẳng mảnh phân chia ranh giới giữa mã đơn và chi tiết hóa đơn
          _summaryRow('Homestay', 'The Pine Hill Dalat'),
          const SizedBox(height: 12),
          _summaryRow('Thời gian', '20/06 - 22/06 (2 đêm)'),
          const SizedBox(height: 12),
          _summaryRow('Tổng thanh toán', '2.550.000đ', isTotal: true), // Hàng hiển thị tổng số tiền cần trả
        ],
      ),
    );
  }

  // Hàm thiết kế dùng chung cấu trúc hiển thị thông tin từng dòng trong hóa đơn tóm tắt
  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 18 : 14, // Tăng kích thước phông chữ nếu là dòng tổng tiền
            color: isTotal ? const Color(0xFFE07A5F) : const Color(0xFF424242), // Điểm xuyết sắc cam cho tổng tiền
          ),
        ),
      ],
    );
  }

  // Khối danh sách tạo tự động các thẻ phương thức thanh toán có thể lựa chọn đổi trạng thái
  Widget _buildPaymentMethodsList() {
    return Column(
      children: List.generate(_paymentMethods.length, (index) {
        final method = _paymentMethods[index];
        final isSelected = _selectedPaymentMethod == index; // Kiểm tra xem phần tử hiện tại có đang được chọn không

        return GestureDetector(
          onTap: () => setState(() => _selectedPaymentMethod = index), // Cập nhật lại chỉ mục phương thức được chọn
          child: Container(
            margin: const EdgeInsets.only(bottom: 12), // Tạo khoảng trống ngăn cách giữa các dòng tùy chọn
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Đổi màu nền sang sắc vàng/be nhạt khi thẻ được tích chọn kích hoạt
              color: isSelected ? const Color(0xFFF7F4E1) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                // Thiết lập viền cam nổi bật bao quanh khung khi được lựa chọn
                color: isSelected ? const Color(0xFFE07A5F) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Khung tròn bao quanh Icon đại diện cho từng loại ví/hình thức thanh toán riêng biệt
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: method['color'].withOpacity(0.1), // Nền màu trong suốt 10% đồng điệu với icon
                    shape: BoxShape.circle,
                  ),
                  child: Icon(method['icon'], color: method['color'], size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    method['name'],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, // In đậm chữ nếu được chọn
                      color: const Color(0xFF424242),
                    ),
                  ),
                ),
                // Thay đổi hiển thị Icon trạng thái Radio button cuối hàng (Đã chọn / Chưa chọn)
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

  // Nút bấm lớn thực hiện hành động gửi thông tin và "Xác nhận thanh toán" đơn hàng
  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Thực hiện liên kết cổng thanh toán (App-to-App) hoặc xử lý API trừ tiền tại đây
        print("Xác nhận thanh toán thành công bằng phương thức có index: $_selectedPaymentMethod");
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41), // Thiết lập màu nâu chủ đạo cho nút bấm
        minimumSize: const Size(double.infinity, 60), // Chiều dài full hàng ngang, chiều cao ô nút là 60 đơn vị
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Bo tròn góc nút 16 đơn vị
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

  // Dòng chữ lưu ý nhỏ (Footer) chứng thực độ tin cậy và tính năng bảo mật bảo vệ tài khoản khách hàng
  Widget _buildSecurityNotice() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 14, color: Colors.grey), // Biểu tượng ổ khóa bảo mật mờ
        SizedBox(width: 8),
        Text(
          'Thanh toán an toàn & mã hóa SSL',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}