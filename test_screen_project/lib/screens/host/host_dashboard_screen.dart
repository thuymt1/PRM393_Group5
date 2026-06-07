import 'package:flutter/material.dart';

// Màn hình bảng điều khiển chính dành cho luồng giao diện Chủ nhà (Host Dashboard)
class HostDashboardScreen extends StatelessWidget {
  const HostDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Sắc nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Làm trong suốt thanh AppBar phía trên
        elevation: 0, // Loại bỏ hiệu ứng bóng đổ của thanh AppBar
        title: const Text(
          'Host Dashboard',
          style: TextStyle(
            color: Color(0xFF6D4C41), // Tông màu nâu đậm chủ đạo cho văn bản tiêu đề
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro', // Đảm bảo khai báo font tương ứng trong pubspec.yaml
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF6D4C41)), // Chuông thông báo của chủ nhà
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: const CircleAvatar(
                radius: 18, // Ảnh đại diện thu nhỏ của chủ nhà góc trên bên phải AppBar
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=host_julian'),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20), // Tạo biên đệm 20 đơn vị bao quanh toàn bộ nội dung body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEarningsCard(), // Khối thẻ hiển thị tổng thu nhập tháng hiện tại (Màu nâu lớn)
            const SizedBox(height: 24),
            _buildStatsGrid(), // Khối lưới hiển thị 4 chỉ số vận hành (Lượt xem, Đặt phòng, Đánh giá, Phản hồi)
            const SizedBox(height: 32),
            _buildSectionHeader('Yêu cầu đặt phòng mới', () {
              Navigator.pushNamed(context, '/host-booking-requests');
            }),
            const SizedBox(height: 12),
            _buildBookingRequestItem(context), // Khối hiển thị thông tin chi tiết một lượt yêu cầu đặt chỗ mới
            const SizedBox(height: 32),
            _buildSectionHeader('Homestay của tôi', () {
              Navigator.pushNamed(context, '/homestay-list');
            }),
            const SizedBox(height: 12),
            _buildMyHomestayCard(context), // Khối hiển thị thẻ thông tin căn nhà đang cho thuê của chủ nhà
            const SizedBox(height: 100), // Khoảng trống đệm an toàn cuối dòng tránh bị che khuất bởi nút nổi FAB rộng
          ],
        ),
      ),
      // Nút bấm nổi mở rộng ghim cố định góc phải đáy màn hình để tạo mới bài đăng homestay
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-homestay-basic-info');
        },
        backgroundColor: const Color(0xFFE07A5F), // Sắc cam cam thương hiệu nổi bật hành động tạo mới
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Đăng tin mới',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context), // Thanh thực đơn điều hướng chuyển đổi tab ở đáy màn hình chủ nhà
    );
  }

  // Khối giao diện hiển thị tổng quan doanh thu tài chính thu nhập trong tháng
  Widget _buildEarningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF6D4C41), // Nền màu nâu thẫm đồng điệu định hướng phong cách thiết kế
        borderRadius: BorderRadius.circular(24), // Bo tròn góc thẻ 24 đơn vị
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4C41).withOpacity(0.2), // Đổ bóng mờ mịn mang sắc độ nâu nhạt
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng thu nhập tháng này',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '24.500.000đ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Nhãn Badge hiển thị phần trăm tăng trưởng so với kỳ trước (Trending Up Badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), // Nền trắng trong suốt 10% tạo độ sâu hài hòa
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min, // Thu nhỏ kích thước hàng vừa khít với nội dung nhãn
              children: [
                Icon(Icons.trending_up, color: Colors.greenAccent, size: 16), // Icon mũi tên tăng trưởng xanh
                SizedBox(width: 4),
                Text(
                  '+12% so với tháng trước',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Khối lưới hiển thị tổ hợp 4 chỉ số thống kê kinh doanh (Stats Grid)
  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true, // Cho phép GridView tự thu hẹp không gian vừa vặn số lượng ô con
      physics: const NeverScrollableScrollPhysics(), // Nhường quyền cuộn màn hình lại cho SingleChildScrollView body cha
      crossAxisCount: 2, // Phân chia dạng lưới đều đặn gồm 2 cột hàng dọc
      crossAxisSpacing: 16, // Khoảng hở đệm giữa hai cột kế hông nhau
      mainAxisSpacing: 16, // Khoảng hở đệm giữa hàng trên và hàng dưới
      childAspectRatio: 1.4, // Tỷ lệ cân đối giữa chiều rộng và chiều cao của ô thống kê nhỏ
      children: [
        _statItem('Lượt xem', '1.240', Icons.visibility_outlined),
        _statItem('Đặt phòng', '18', Icons.book_online_outlined),
        _statItem('Đánh giá', '4.9', Icons.star_outline),
        _statItem('Phản hồi', '98%', Icons.chat_bubble_outline),
      ],
    );
  }

  // Hàm thiết kế dùng chung cấu trúc cho từng ô vuông chỉ số thống kê nhỏ lẻ độc lập
  Widget _statItem(String label, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10), // Đổ bóng mờ siêu nhẹ 2%
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFE07A5F), size: 22), // Biểu tượng cam thương hiệu đặc trưng chỉ số
          const SizedBox(height: 8),
          Text(
            val,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Hàm thiết kế dùng chung cấu trúc thanh tiêu đề phân mục lớn kèm link văn bản "Xem tất cả"
  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text(
            'Xem tất cả',
            style: TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Khối giao diện hiển thị thông tin tóm tắt của một yêu cầu duyệt thuê chỗ ở mới từ khách hàng
  Widget _buildBookingRequestItem(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24, // Ảnh đại diện của vị khách hàng gửi đơn đặt phòng
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=user_an_nhien'),
          ),
          const SizedBox(width: 16),
          // Khối chữ hiển thị danh tính khách, số lượng đêm và ngày thuê phòng dự kiến
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trần An Nhiên',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  '2 đêm • 2 khách • 20/06 - 22/06',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          // Nút bấm xem chi tiết đơn phòng dạng phẳng phẳng mượt tiệp màu nền be nhạt
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/host-booking-requests');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF7F4E1), // Nền màu be nhạt nhẹ nhàng quý phái
              foregroundColor: const Color(0xFF6D4C41), // Sắc nâu thẫm cho chữ
              elevation: 0, // Khử đổ bóng mặc định để nút phẳng tinh tế
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Chi tiết', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Khối hiển thị thẻ Card tóm tắt hình ảnh và trạng thái hoạt động thực tế của Homestay sở hữu
  Widget _buildMyHomestayCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/homestay-status');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // Thiết lập bo cong tròn bốn góc thẻ Card 24 đơn vị
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Column(
          children: [
            // Phần hình ảnh thu nhỏ không gian homestay (Cắt bo góc tròn phía trên)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(
                'https://images.unsplash.com/photo-1510798831971-661eb04b3739?q=80&w=1000',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover, // Cắt cúp ảnh cân xứng lấp đầy khung ngang hình chữ nhật
              ),
            ),
            // Khối chữ hiển thị tên homestay và chấm tròn nhãn chỉ báo trạng thái 'Đang hoạt động' màu xanh lá
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'The Terracotta Nest',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.circle, color: Colors.green, size: 8), // Chấm tròn tín hiệu nhỏ màu xanh lá cây
                          const SizedBox(width: 6),
                          const Text(
                            'Đang hoạt động',
                            style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey), // Biểu tượng ba dấu chấm tùy chọn cấu hình nâng cao
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thanh điều hướng cố định ghim dưới chân đáy dành cho giao diện ứng dụng của Chủ nhà (Host Bottom Navigation Bar)
  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Cố định kiến trúc tránh hiệu ứng nhảy dịch vị trí khi chạm bấm
      selectedItemColor: const Color(0xFFE07A5F), // Sắc cam làm nổi bật icon tab đang đứng hoạt động tích cực
      unselectedItemColor: Colors.grey, // Sắc xám nhẹ cho các danh mục tab còn lại chưa được lựa chọn
      currentIndex: 0, // Thiết lập vị trí mặc định nằm tại trang tiên phong đầu tiên (Tab Dashboard)
      onTap: (index) {
        if (index == 1) {
          Navigator.pushNamed(context, '/host-booking-requests');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/homestay-list');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/profile');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Lịch'),
        BottomNavigationBarItem(icon: Icon(Icons.home_work_outlined), activeIcon: Icon(Icons.home_work), label: 'Nhà của tôi'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
      ],
    );
  }
}