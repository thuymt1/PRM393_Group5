import 'package:flutter/material.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Định cấu hình số lượng Tab hiển thị (Sắp tới, Đã xong, Đã hủy)
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFAE7), // Sắc nền nhẹ (Surface color từ design system)
        appBar: AppBar(
          backgroundColor: Colors.white, // Nền trắng giúp phần thanh TabBar hiển thị tách biệt rõ ràng
          elevation: 0, // Loại bỏ hiệu ứng bóng đổ của thanh AppBar
          centerTitle: true,
          title: const Text(
            'Chuyến đi của tôi',
            style: TextStyle(
              color: Color(0xFF6D4C41),
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'BeVietnamPro', // Đảm bảo khai báo font tương ứng trong pubspec.yaml
            ),
          ),
          // Thanh Menu Tab phân chia trạng thái chuyến đi ghim ở đáy AppBar
          bottom: const TabBar(
            labelColor: Color(0xFFE07A5F), // Sắc cam cam thương hiệu cho nhãn Tab được chọn
            unselectedLabelColor: Colors.grey, // Sắc xám cho các nhãn Tab chưa được chọn
            indicatorColor: Color(0xFFE07A5F), // Màu đường gạch chân chỉ báo Tab đang hoạt động
            indicatorWeight: 3, // Độ dày của đường gạch chân chỉ báo
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: 'Sắp tới'),
              Tab(text: 'Đã xong'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        // Vùng nội dung thay đổi linh hoạt tương ứng khi người dùng vuốt hoặc click chọn các Tab
        body: TabBarView(
          children: [
            _buildBookingList(context, 'upcoming'),  // Danh sách chuyến đi sắp khởi hành
            _buildBookingList(context, 'completed'), // Danh sách chuyến đi đã hoàn thành lịch trình
            _buildBookingList(context, 'cancelled'), // Danh sách chuyến đi đã thực hiện hủy bỏ đơn
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(), // Thanh thực đơn điều hướng cố định dưới đáy màn hình
      ),
    );
  }

  // Hàm sinh dựng danh sách đơn đặt phòng dựa trên danh mục trạng thái truyền vào
  Widget _buildBookingList(BuildContext context, String category) {
    // Tạo lập danh sách dữ liệu giả lập (Mock data) tương ứng với từng điều kiện Tab
    final List<Map<String, dynamic>> bookings = category == 'upcoming'
        ? [
      {
        'name': 'The Pine Hill',
        'location': 'Phường 4, Đà Lạt',
        'date': '20/06 - 22/06/2026',
        'status': 'Đã xác nhận',
        'price': '2.550.000đ',
        'image': 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?q=80&w=1000',
      },
    ]
        : category == 'completed'
        ? [
      {
        'name': 'Ocean View Villa',
        'location': 'Sơn Trà, Đà Nẵng',
        'date': '10/05 - 12/05/2026',
        'status': 'Hoàn thành',
        'price': '4.800.000đ',
        'image': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=1000',
      },
    ]
        : [
      {
        'name': 'Vintage Garden',
        'location': 'Mai Anh Đào, Đà Lạt',
        'date': '01/04 - 03/04/2026',
        'status': 'Đã hủy',
        'price': '1.700.000đ',
        'image': 'https://images.unsplash.com/photo-1449156001437-3a1441df910b?q=80&w=1000',
      },
    ];

    // Trả về giao diện trống nếu danh sách mảng rỗng không có dữ liệu đơn phòng
    if (bookings.isEmpty) {
      return _buildEmptyState();
    }

    // Hiển thị danh sách cuộn dọc các thẻ hóa đơn đặt phòng
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(context, bookings[index]); // Vẽ cấu trúc chi tiết từng thẻ Card cụ thể
      },
    );
  }

  // Khối giao diện thông báo trạng thái trống khi không tìm thấy bất kỳ lịch trình đặt phòng nào
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_outlined, size: 80, color: Colors.grey.shade300), // Icon tờ ghi chú mờ lớn
          const SizedBox(height: 16),
          const Text(
            'Chưa có đơn đặt phòng nào',
            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Hàm thiết kế cấu trúc chi tiết thẻ Card hiển thị thông tin tóm tắt của chuyến đi
  Widget _buildBookingCard(BuildContext context, Map<String, dynamic> booking) {
    // Đổi màu sắc nhãn văn bản linh hoạt để đồng điệu với trạng thái đơn hàng hiện tại
    Color statusColor;
    switch (booking['status']) {
      case 'Đã xác nhận': statusColor = Colors.green; break;
      case 'Hoàn thành': statusColor = const Color(0xFF6D4C41); break; // Sắc nâu hệ thống cho đơn đã xong
      case 'Đã hủy': statusColor = Colors.red; break;
      default: statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Bo tròn 4 góc khung thẻ 24 đơn vị
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Đổ bóng mờ mịn siêu nhẹ tạo độ sâu bề mặt tinh tế
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Thực hiện điều phối điều hướng kết nối Navigator dẫn tới trang màn hình chi tiết đơn đặt chỗ
          print("Xem chi tiết đơn phòng căn: ${booking['name']}");
        },
        borderRadius: BorderRadius.circular(24), // Đảm bảo hiệu ứng sóng nước hiệu ứng gợn sóng (Ink Splash) bo khít góc thẻ
        child: Column(
          children: [
            // Khối hình ảnh phía trên cùng của Card (Sử dụng ClipRRect để cắt bo cong viền ảnh góc trên)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  Image.network(
                    booking['image'],
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover, // Cắt cúp tỉ lệ ảnh cân đối phủ kín khung ngang
                  ),
                  // Nhãn Badge hiển thị chuỗi chữ trạng thái đơn hàng đặt đè góc trên bên phải bức ảnh
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9), // Khung nền trắng đục mờ trong suốt 90%
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        booking['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Khối chứa các thành phần nội dung văn bản chi tiết (Tên biệt thự, giá tiền, thời hạn ngày thuê)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        booking['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF424242), // Sắc xám đen thẫm
                        ),
                      ),
                      Text(
                        booking['price'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE07A5F), // Sắc cam nổi bật hiển thị chi phí tổng thanh toán
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        booking['location'],
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const Divider(height: 24), // Đường kẻ vạch phân tách mảnh ngăn cách mốc thời gian lưu trú
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6D4C41)), // Biểu tượng lịch màu nâu
                      const SizedBox(width: 8),
                      Text(
                        booking['date'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Color(0xFF6D4C41),
                        ),
                      ),
                      const Spacer(), // Tự động đẩy cụm chữ liên kết điều hướng về sát mép phải hàng dọc
                      const Text(
                        'Chi tiết',
                        style: TextStyle(
                          color: Color(0xFFE07A5F),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18, color: Color(0xFFE07A5F)), // Mũi tên hướng đi tới màu cam
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thanh menu điều hướng chuyển đổi tab cố định ghim dưới chân mép đáy màn hình (Bottom Navigation Bar)
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Cố định kiến trúc tránh hiệu ứng nhảy dịch chuyển vị trí khi click chọn
      selectedItemColor: const Color(0xFFE07A5F), // Sắc cam làm nổi bần bật icon tab đang đứng hoạt động tích cực
      unselectedItemColor: Colors.grey, // Sắc màu xám nhẹ cho các danh mục tab còn lại chưa được lựa chọn
      currentIndex: 2, // Đánh chỉ mục vị trí hiện tại đang nằm cố định ở Tab thứ 2 ('Chuyến đi' của tôi)
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Khám phá'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Yêu thích'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Chuyến đi'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Hồ sơ'),
      ],
    );
  }
}