import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Sắc nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor: Colors.white, // Nền trắng giúp phần thanh công cụ phía trên hiển thị sạch sẽ
        elevation: 0, // Loại bỏ hiệu ứng bóng đổ của thanh AppBar
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)), // Nút bấm quay lại trang trước đó
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'BeVietnamPro', // Đảm bảo khai báo font tương ứng trong pubspec.yaml
          ),
        ),
        actions: [
          // Nút hành động cho phép người dùng đánh dấu nhanh toàn bộ thông báo là đã đọc
          TextButton(
            onPressed: () {
              // TODO: Xử lý logic cập nhật trạng thái toàn bộ danh sách thông báo sang "Đã đọc"
              print("Đã nhấn: Đánh dấu đã đọc tất cả");
            },
            child: const Text(
              'Đánh dấu đã đọc',
              style: TextStyle(color: Color(0xFFE07A5F), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(), // Khối thanh danh mục bộ lọc nhanh dạng hàng ngang (Tất cả, Giao dịch...)
          Expanded(
            // Danh sách cuộn thông báo sử dụng ListView.separated để tự động chèn khoảng trống giữa các phần tử
            child: ListView.separated(
              padding: const EdgeInsets.all(16), // Biên đệm 16 đơn vị bao quanh vùng danh sách
              itemCount: 10, // Thiết lập số lượng phần tử giả lập hiển thị là 10 dòng
              separatorBuilder: (context, index) => const SizedBox(height: 12), // Khoảng trống cao 12 đơn vị giữa các item
              itemBuilder: (context, index) {
                // Giả lập luân phiên phân chia các loại thông báo dựa trên chỉ mục (Index)
                if (index % 3 == 0) {
                  return _buildNotificationItem(
                    title: 'Đặt phòng thành công!',
                    desc: 'Đơn đặt phòng BK123456 tại The Pine Hill đã được xác nhận.',
                    time: '2 giờ trước',
                    icon: Icons.receipt_long, // Icon hóa đơn đặt phòng
                    iconColor: const Color(0xFFE07A5F), // Sắc cam cam chủ đạo thương hiệu
                    isUnread: index == 0, // Giả định riêng phần tử đầu tiên (index 0) là chưa đọc
                  );
                } else if (index % 3 == 1) {
                  return _buildNotificationItem(
                    title: 'Thanh toán hoàn tất',
                    desc: 'Giao dịch chuyển khoản 3.450.000đ đã được hệ thống ghi nhận.',
                    time: '5 giờ trước',
                    icon: Icons.payment, // Icon thẻ thanh toán
                    iconColor: Colors.green, // Sắc xanh lá an toàn cho giao dịch thành công
                    isUnread: false,
                  );
                } else {
                  return _buildNotificationItem(
                    title: 'Ưu đãi mới dành cho bạn',
                    desc: 'Giảm ngay 20% cho chuyến đi tiếp theo tại Đà Lạt. Khám phá ngay!',
                    time: '1 ngày trước',
                    icon: Icons.local_offer_outlined, // Icon nhãn mác khuyến mãi
                    iconColor: Colors.orange, // Sắc cam sáng thu hút chú ý ưu đãi
                    isUnread: false,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Khối giao diện tạo thanh danh mục lọc trạng thái nhanh hàng ngang (Horizontal Scroll)
  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white, // Tiệp nền trắng liên mạch liền kề phía dưới AppBar
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Kích hoạt tính năng cuộn ngang danh mục bộ lọc
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _filterChip('Tất cả', true), // Thẻ mặc định giả định đang đứng hoạt động tích cực
            _filterChip('Giao dịch', false),
            _filterChip('Đặt phòng', false),
            _filterChip('Khuyến mãi', false),
          ],
        ),
      ),
    );
  }

  // Hàm thiết kế dùng chung cấu trúc nhãn viên thuốc lựa chọn tiêu chí phân loại nhanh (Chip)
  Widget _filterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12), // Khoảng cách hở đệm giữa các viên thuốc kề nhau
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // Biến đổi màu nền sang sắc cam thương hiệu nếu thẻ từ khóa đó được chọn
        color: isSelected ? const Color(0xFFE07A5F) : Colors.white,
        borderRadius: BorderRadius.circular(20), // Bo tròn dáng viên thuốc mềm mại 20 đơn vị
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700, // Đổi màu sắc văn bản tương phản theo nền thẻ
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Hàm thiết kế cấu trúc chi tiết cho từng ô thẻ hiển thị nội dung thông báo cụ thể
  Widget _buildNotificationItem({
    required String title,
    required String desc,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Đổi màu nền sang sắc vàng/be nhạt nhẹ 50% nếu thông báo đó ở trạng thái chưa đọc (Unread)
        color: isUnread ? const Color(0xFFF7F4E1).withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16), // Bo cong tròn bốn góc thẻ 16 đơn vị
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02), // Đổ bóng mờ siêu nhẹ tạo hiệu ứng nổi tinh tế
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn chỉnh các phần tử bám đỉnh hàng dọc
        children: [
          // Khung tròn bao quanh Icon đại diện loại loại hình thông báo chuyên biệt
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1), // Phủ màu nền trong suốt 10% đồng điệu sắc màu icon
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          // Khối văn bản chứa tiêu đề thông báo, nội dung mô tả chi tiết và mốc thời gian
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    // Thiết lập in đậm chữ sắc nét hơn nếu là thông báo mới chưa đọc
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                    fontSize: 15,
                    color: const Color(0xFF424242), // Sắc xám đen thẫm tinh tế
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.4, // Giãn dòng 1.4 thông thoáng văn bản dễ tiếp cận nội dung
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          // Điều kiện Render: Nếu thông báo chưa đọc, vẽ thêm một chấm tròn cam nhỏ báo hiệu ở góc phải (Unread Indicator)
          if (isUnread)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6, left: 8), // Đệm căn lề đẩy chấm tròn cân xứng tiêu đề dòng
              decoration: const BoxDecoration(
                color: Color(0xFFE07A5F), // Sắc cam cam chỉ báo tín hiệu chưa đọc nổi bật
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}