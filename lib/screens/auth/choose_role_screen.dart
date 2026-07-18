import 'package:flutter/material.dart';
import '../../services/api_service.dart';

// Màn hình cho phép người dùng lựa chọn vai trò (Khách hàng / Chủ nhà)
class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _selectRole(String role, String routeName) async {
    setState(() => _isLoading = true);
    try {
      await _apiService.updateProfileRole(role);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật vai trò: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Điều hướng đến form đăng ký host (không kích hoạt ngay)
  void _goToHostRegistration() {
    if (_isLoading) return;
    Navigator.pushNamed(context, '/host-registration-form');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Màu nền nhẹ (Surface color từ design system)
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _buildLogo(), // Hiển thị biểu tượng Logo dạng vòng tròn đổ bóng
                  const SizedBox(height: 40),
                  _buildHeader(), // Hiển thị dòng tiêu đề hỏi vai trò người dùng
                  const SizedBox(height: 48),
                  _roleCard(
                    context,
                    Icons.person_outline,
                    'Khách hàng',
                    'Tìm kiếm và đặt phòng homestay mơ ước cho những chuyến đi của bạn.',
                    () => _selectRole('customer', '/customer-home'),
                  ),
                  const SizedBox(height: 16),
                  _roleCard(
                    context,
                    Icons.home_work_outlined,
                    'Chủ nhà',
                    'Gửi đơn đăng ký và chờ Admin phê duyệt để bắt đầu quản lý homestay.',
                    () => _goToHostRegistration(),
                  ),
                  const SizedBox(height: 24),
                  _buildFooter(), // Hiển thị dòng ghi chú lưu ý đổi vai trò
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFE07A5F),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Khối thiết kế biểu tượng thương hiệu (Logo đại diện)
  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle, // Định dạng khung hình tròn
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE07A5F).withOpacity(0.15), // Bóng đổ mang sắc cam nhạt
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: const Icon(
        Icons.home_work_rounded,
        size: 60,
        color: Color(0xFFE07A5F), // Màu sắc cam thương hiệu của icon
      ),
    );
  }

  // Khối văn bản tiêu đề giới thiệu chức năng màn hình
  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Bạn là ai?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41), // Tông màu nâu đậm chủ đạo
            fontFamily: 'BeVietnamPro', // Cần cấu hình font này trong file pubspec.yaml
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Chọn vai trò để chúng tôi tối ưu hóa trải nghiệm phù hợp nhất dành cho bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // Hàm tùy biến dùng chung để tạo thẻ lựa chọn vai trò (Card) dạng hàng ngang (Row)
  Widget _roleCard(
      BuildContext context,
      IconData icon,
      String title,
      String sub,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap, // Kích hoạt hành động chuyển màn hình khi bấm vào thẻ
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // Bo tròn góc thẻ 24 đơn vị
          border: Border.all(color: Colors.grey.shade100), // Đường viền xám siêu mảnh
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Đổ bóng nhẹ phía dưới tạo chiều sâu
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            // Khung vuông bo tròn chứa Icon đại diện vai trò
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4E1), // Nền màu be nhạt làm nổi bật Icon
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: const Color(0xFFE07A5F), size: 32),
            ),
            const SizedBox(width: 20),
            // Phần hiển thị nội dung Text (Tên vai trò & Mô tả chi tiết)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // Biểu tượng mũi tên chỉ hướng sang phải cuối thẻ
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFFBDBDBD),
            ),
          ],
        ),
      ),
    );
  }

  // Khối văn bản ghi chú nhỏ (Footer) đặt ở đáy màn hình
  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Đăng ký làm Chủ nhà cần được Admin xem xét và phê duyệt.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }
}
