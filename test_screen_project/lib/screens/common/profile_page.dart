import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Màu nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Làm trong suốt thanh AppBar
        elevation: 0, // Loại bỏ hiệu ứng bóng đổ của thanh AppBar
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            color: Color(0xFF6D4C41), // Tông màu nâu đậm chủ đạo cho văn bản tiêu đề
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro', // Cần cấu hình font tương ứng trong pubspec.yaml để hiển thị chuẩn
          ),
        ),
        centerTitle: true, // Căn giữa tiêu đề của AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20), // Tạo khoảng cách đệm 20 đơn vị xung quanh nội dung
        child: Column(
          children: [
            _buildProfileHeader(), // Khối thông tin thẻ Avatar, Tên và Loại thành viên
            const SizedBox(height: 32),
            _buildStatsRow(), // Khối hiển thị các thông số (Số chuyến đi, Xếp hạng)
            const SizedBox(height: 32),
            _buildAccountSettingsSection(), // Khối danh sách các cài đặt tài khoản (ListTile)
            const SizedBox(height: 40),
            _buildLogoutButton(), // Nút bấm thực hiện hành động Đăng xuất khỏi hệ thống
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(), // Thanh điều hướng cố định ở đáy màn hình
    );
  }

  // Khối giao diện thông tin cá nhân cơ bản (Avatar và Tên thành viên)
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity, // Chiều rộng tối đa theo khung chứa
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Bo tròn góc thẻ hồ sơ 24 đơn vị
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Đổ bóng nhẹ tạo hiệu ứng nổi bề mặt
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Stack dùng để đè nút đổi ảnh (Icon camera) lên trên Avatar hình tròn
          Stack(
            children: [
              const CircleAvatar(
                radius: 60, // Bán kính vòng tròn ảnh đại diện
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alexandria'), // Tải ảnh mẫu từ Internet
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE07A5F), // Màu cam thương hiệu làm nền nút camera
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Alexandria Bennett',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
          ),
          const Text(
            'alexandria.b@homestay.com',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 12),
          // Khung nhãn hiển thị trạng thái phân hạng thành viên (Premium)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE07A5F).withOpacity(0.1), // Nền cam nhạt trong suốt 10%
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min, // Thu nhỏ kích thước hàng vừa khít với nội dung bên trong
              children: [
                Icon(Icons.verified, color: Color(0xFFE07A5F), size: 16),
                SizedBox(width: 8),
                Text(
                  'Thành viên Premium',
                  style: TextStyle(
                    color: Color(0xFFE07A5F),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Khối gom hai thẻ thông số thống kê lại theo chiều ngang
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('12', 'Chuyến đi')), // Thẻ thống kê số lượng chuyến đi
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('4.8', 'Xếp hạng')), // Thẻ thống kê điểm số đánh giá
      ],
    );
  }

  // Hàm tùy biến thiết kế thẻ hiển thị thông số số liệu (Stat Card)
  Widget _buildStatCard(String val, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            val,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE07A5F), // Sử dụng tông cam thương hiệu cho các con số nổi bật
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Khối danh sách các danh mục tùy chọn cài đặt tài khoản của người dùng
  Widget _buildAccountSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cài đặt tài khoản',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
              )
            ],
          ),
          child: Column(
            children: [
              _buildSettingItem(Icons.person_outline, 'Thông tin cá nhân', 'Tên pháp lý, chi tiết liên hệ'),
              const Divider(height: 1), // Đường kẻ phân chia mỏng ngăn cách giữa các mục
              _buildSettingItem(Icons.payment, 'Phương thức thanh toán', 'Visa •••• 4242, MoMo'),
              const Divider(height: 1),
              _buildSettingItem(Icons.star_outline, 'Nhận xét của tôi', '8 trải nghiệm đã chia sẻ'),
              const Divider(height: 1),
              _buildSettingItem(Icons.settings_outlined, 'Cài đặt hệ thống', 'Thông báo, ngôn ngữ'),
            ],
          ),
        ),
      ],
    );
  }

  // Hàm thiết kế từng dòng tùy chọn cài đặt sử dụng cấu trúc ListTile tiêu chuẩn
  Widget _buildSettingItem(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4E1), // Màu nền be nhạt bao quanh Icon
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF6D4C41), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20), // Biểu tượng mũi tên đi tới cuối dòng
      onTap: () {
        // TODO: Xử lý sự kiện khi click vào từng mục tùy chọn tại đây
        print("Bấm vào mục cài đặt: $title");
      },
    );
  }

  // Thiết kế cấu trúc nút Đăng xuất chứa cả Icon biểu tượng phía trước chữ
  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Xử lý xóa phiên đăng nhập (token/session) và chuyển hướng về màn hình Login tại đây
        print("Thực hiện đăng xuất tài khoản");
      },
      icon: const Icon(Icons.logout, color: Colors.white, size: 20), // Biểu tượng đăng xuất
      label: const Text(
        'Đăng xuất',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41), // Màu nền nâu của nút bấm
        minimumSize: const Size(double.infinity, 56), // Co giãn full chiều ngang, chiều cao ô nút 56 đơn vị
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Thiết lập bo tròn góc nút bấm
        elevation: 2,
        shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
      ),
    );
  }

  // Thanh menu điều hướng cố định dưới đáy màn hình ứng dụng (Bottom Navigation Bar)
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Cố định các thành phần không tạo hiệu ứng nhảy dịch chuyển vị trí
      selectedItemColor: const Color(0xFFE07A5F), // Màu sắc cam làm nổi bật icon đang được chọn kích hoạt
      unselectedItemColor: Colors.grey, // Màu sắc xám cho các icon còn lại chưa được chọn
      currentIndex: 3, // Thiết lập vị trí trang hiện tại là trang Hồ sơ (vị trí index thứ 3 trong mảng)
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Khám phá'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Yêu thích'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Đặt chỗ'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
      ],
    );
  }
}