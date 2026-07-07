import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Sắc nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor: Colors.white, // Nền trắng giúp phần thanh công cụ phía trên hiển thị tách biệt rõ ràng
        elevation: 0, // Loại bỏ hiệu ứng bóng đổ của thanh AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)), // Nút quay lại trang trước đó
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Xác nhận đặt phòng',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'BeVietnamPro', // Đảm bảo khai báo font tương ứng trong pubspec.yaml
          ),
        ),
        centerTitle: true, // Căn giữa tiêu đề của AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24), // Tạo biên đệm 24 đơn vị bao quanh vùng nội dung
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepIndicator(), // Thanh hiển thị các bước tiến trình đặt phòng (Step Indicator)
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
            // Phân mục 1: Thông tin liên hệ của khách hàng đặt phòng
            _buildInfoSection(
              title: 'Thông tin khách hàng',
              icon: Icons.person_outline,
              children: [
                _buildInfoRow('Họ và tên', 'Alexandria Bennett'),
                _buildInfoRow('Email', 'alexandria.b@homestay.com'),
                _buildInfoRow('Số điện thoại', '+84 987 654 321'),
              ],
            ),
            const SizedBox(height: 24),
            // Phân mục 2: Chi tiết thông tin về homestay và thời gian lưu trú
            _buildInfoSection(
              title: 'Chi tiết chuyến đi',
              icon: Icons.card_travel_outlined,
              children: [
                _buildInfoRow('Homestay', 'The Terracotta Nest'),
                _buildInfoRow('Thời gian', '20/06 - 22/06/2026 (2 đêm)'),
                _buildInfoRow('Số khách', '2 người lớn'),
              ],
            ),
            const SizedBox(height: 24),
            // Phân mục 3: Hóa đơn tóm tắt các khoản chi phí và tổng tiền
            _buildInfoSection(
              title: 'Tóm tắt thanh toán',
              icon: Icons.payments_outlined,
              children: [
                _buildInfoRow('Giá phòng (2 đêm)', '2.500.000đ'),
                _buildInfoRow('Phí dịch vụ', '50.000đ'),
                const Divider(height: 32), // Đường gạch ngang phân chia phần tính tổng tiền
                _buildInfoRow(
                  'Tổng cộng',
                  '2.550.000đ',
                  isPrimary: true, // Kích hoạt làm nổi bật sắc cam cho thông số tổng tiền
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildActionButtons(context), // Khối chứa nút xác nhận thanh toán hoặc quay lại chỉnh sửa
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Khối giao diện sơ đồ thanh trạng thái các bước đặt phòng (Step Indicator)
  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepCircle('1', 'Thông tin', true), // Bước 1 đã hoàn tất
        _buildStepLine(true),                      // Đoạn nối sang bước 2 sáng đèn
        _buildStepCircle('2', 'Xác nhận', true),  // Bước 2 hiện tại đang đứng
        _buildStepLine(false),                     // Đoạn nối sang bước 3 hiển thị xám mờ
        _buildStepCircle('3', 'Thanh toán', false),// Bước 3 chưa kích hoạt
      ],
    );
  }

  // Hàm thiết kế nút tròn hiển thị số thứ tự bước kèm nhãn văn bản mô tả phía dưới
  Widget _buildStepCircle(String num, String label, bool isDone) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            // Đổi sang sắc cam nếu bước đó đã hoàn thiện hoặc đang hoạt động
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

  // Hàm tạo thanh nối ngang giữa các nút tròn chỉ mục tiến trình
  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 22), // Căn lề đệm đẩy thanh lên ngang tầm giữa của vòng tròn
        color: isActive ? const Color(0xFFE07A5F) : Colors.grey.shade300,
      ),
    );
  }

  // Hàm tùy biến cấu trúc một khối thông tin có đổ bóng mờ chứa danh sách hàng văn bản bên trong
  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hàng chứa icon đại diện và tiêu đề phân mục thông tin
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
        // Hộp Container trắng bo góc 20 đơn vị chứa nội dung tóm tắt chi tiết
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03), // Hiệu ứng đổ bóng mờ siêu nhẹ tạo chiều sâu nổi khối
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

  // Hàm thiết kế cấu trúc một dòng dữ liệu gồm nhãn mô tả bên trái và giá trị đối ứng bên phải
  Widget _buildInfoRow(String label, String value, {bool isPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
              color: isPrimary ? const Color(0xFFE07A5F) : const Color(0xFF424242), // Điểm sắc cam nếu là thông số tổng kết tiền
              fontSize: isPrimary ? 18 : 14, // Tăng kích thước phông chữ cho phần tổng tiền
            ),
          ),
        ],
      ),
    );
  }

  // Khối tổ hợp phím bấm thực thi tác vụ (Xác nhận chuyển màn hình hoặc quay lui chỉnh sửa)
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Nút bấm lớn màu nâu thực hiện tiến hành chuyển tiếp sang bước thanh toán hóa đơn
        ElevatedButton(
          onPressed: () {
            context.push('/payment');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6D4C41), // Màu sắc nâu đậm chủ đạo hệ thống
            minimumSize: const Size(double.infinity, 56), // Kéo dãn full chiều rộng hàng ngang, chiều cao ô nút là 56
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Bo tròn góc nút 16 đơn vị
            elevation: 2,
            shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
          ),
          child: const Text(
            'Xác nhận & Thanh toán',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        // Link văn bản hỗ trợ khách quay ngược lại để sửa đổi các thông tin lưu trú chưa chuẩn xác
        TextButton(
          onPressed: () => context.pop(), // Trở lại màn hình trước để thay đổi thông tin
          child: const Text(
            'Thay đổi thông tin',
            style: TextStyle(
              color: Color(0xFFE07A5F),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline, // Tạo hiệu ứng gạch chân định dạng liên kết
            ),
          ),
        ),
      ],
    );
  }
}