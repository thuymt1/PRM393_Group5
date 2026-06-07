import 'package:flutter/material.dart';

class HostBookingDetailScreen extends StatelessWidget {
  const HostBookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Sắc nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor: Colors.white, // Nền trắng giúp phần thanh công cụ phía trên hiển thị sạch sẽ
        elevation: 0, // Loại bỏ hiệu ứng bóng đổ của thanh AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)), // Nút quay lại trang trước đó
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết yêu cầu',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'BeVietnamPro', // Đảm bảo khai báo font tương ứng trong pubspec.yaml
          ),
        ),
        centerTitle: true, // Căn giữa tiêu đề của AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24), // Tạo biên đệm 24 đơn vị bao quanh vùng nội dung body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBanner(), // Khối biểu ngữ cảnh báo trạng thái chờ duyệt của đơn phòng
            const SizedBox(height: 24),
            _buildGuestInfoSection(), // Thẻ hiển thị thông tin chân dung khách hàng và nút chat nhanh
            const SizedBox(height: 24),
            _buildBookingSummarySection(), // Thẻ tóm tắt chi tiết lịch trình phòng ở, thời gian và số khách
            const SizedBox(height: 24),
            _buildPaymentSummarySection(), // Thẻ tóm tắt chi tiết hóa đơn chi phí doanh thu thu nhập
            const SizedBox(height: 32),
            _buildMessageFromGuest(), // Khối hiển thị thông điệp, lời nhắn gửi từ vị khách đặt phòng
            const SizedBox(height: 100), // Khoảng trống đệm an toàn cuối dòng tránh bị che bởi thanh BottomSheet
          ],
        ),
      ),
      bottomSheet: _buildActionButtons(context), // Cụm nút đôi tác vụ duyệt hoặc từ chối ghim cố định đáy màn hình
    );
  }

  // Khối giao diện hiển thị thanh biểu ngữ thông báo trạng thái chờ xử lý (Status Banner)
  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50, // Nền màu cam nhạt tạo tín hiệu lưu ý kiểm duyệt
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100), // Đường viền sắc cam nhạt
      ),
      child: const Row(
        children: [
          Icon(Icons.pending_actions, color: Colors.orange), // Icon biểu tượng chờ duyệt
          SizedBox(width: 12),
          Text(
            'Yêu cầu đang chờ bạn phê duyệt',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Khối giao diện hiển thị thẻ thông tin liên hệ và lý lịch cơ bản của khách hàng đặt phòng
  Widget _buildGuestInfoSection() {
    return _buildSectionCard(
      'Thông tin khách hàng',
      Row(
        children: [
          const CircleAvatar(
            radius: 30, // Bán kính vòng tròn ảnh chân dung vị khách
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=user1'),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trần An Nhiên',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
                ),
                Text(
                  'Khách hàng từ 2023 • 12 chuyến đi',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          // Nút bấm nhắn tin trò chuyện trao đổi trực tiếp với vị khách
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFFE07A5F)), // Điểm xuyết sắc cam thương hiệu cho nút chat
            onPressed: () {
              // Xử lý mở luồng màn hình hội thoại riêng biệt
            },
          ),
        ],
      ),
    );
  }

  // Khối giao diện tóm tắt chi tiết lịch trình phòng ốc lưu trú thông qua cấu trúc danh sách hàng dọc
  Widget _buildBookingSummarySection() {
    return _buildSectionCard(
      'Chi tiết đặt phòng',
      Column(
        children: [
          _buildInfoRow(Icons.home_work_outlined, 'Homestay', 'The Terracotta Nest'),
          const Divider(height: 32), // Đường vạch kẻ ngang phân tách mảnh tạo không gian thông thoáng
          _buildInfoRow(Icons.calendar_today_outlined, 'Thời gian', '20/06 - 22/06/2026 (2 đêm)'),
          const Divider(height: 32),
          _buildInfoRow(Icons.people_outline, 'Số khách', '2 Người lớn'),
        ],
      ),
    );
  }

  // Khối giao diện tóm tắt chi tiết hóa đơn tài chính dòng thu nhập dự tính thực nhận của chủ nhà
  Widget _buildPaymentSummarySection() {
    return _buildSectionCard(
      'Tóm tắt thanh toán',
      Column(
        children: [
          _buildDataRow('Giá phòng (2 đêm)', '2.500.000đ'),
          _buildDataRow('Phí dịch vụ', '50.000đ'),
          const Divider(height: 32),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng thu nhập của bạn',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
              ),
              Text(
                '2.550.000đ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE07A5F)), // Làm nổi bật số tiền thu nhập bằng sắc cam cam
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Khối văn bản hiển thị lời giới thiệu hoặc tâm thư nhắn nhủ ngắn gọn đi kèm từ vị khách đặt phòng
  Widget _buildMessageFromGuest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lời nhắn từ khách',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
        ),
        const SizedBox(height: 12),
        // Hộp Container nền màu be vàng nhạt nhã nhặn bao bọc văn bản lời nhắn chữ nghiêng
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F4E1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            '"Chào chủ nhà, mình và bạn muốn thuê phòng để kỷ niệm ngày kỷ niệm của tụi mình. Hy vọng bạn sẽ đồng ý yêu cầu nhé. Cảm ơn bạn!"',
            style: TextStyle(color: Color(0xFF424242), height: 1.5, fontStyle: FontStyle.italic), // Giãn cách dòng 1.5 kết hợp chữ in nghiêng tinh tế
          ),
        ),
      ],
    );
  }

  // Hàm thiết kế dùng chung cấu trúc một khối thẻ Card nền trắng bo góc mềm mại có đổ bóng mờ nhẹ
  Widget _buildSectionCard(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: content,
        ),
      ],
    );
  }

  // Hàm hỗ trợ vẽ một hàng thông tin gồm Icon sắc cam, nhãn xám mờ và giá trị in đậm phía dưới
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFE07A5F)), // Đặt màu sắc cam thương hiệu cho các biểu tượng đầu dòng
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  // Hàm hỗ trợ vẽ một hàng hóa đơn gồm nhãn văn bản bên trái và chi phí đối ứng hàng dọc bên phải
  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      ],
    );
  }

  // Thanh phím đôi tác vụ ("Từ chối" / "Phê duyệt") cố định dưới chân mép đáy màn hình thông qua cơ chế BottomSheet
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), // Chừa biên đệm dưới 32 đơn vị bảo toàn phần tai thỏ / thanh vuốt hệ thống
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)) // Hiệu ứng đổ bóng đổ ngược lên trên
        ],
      ),
      child: Row(
        children: [
          // Nút bấm tác vụ "Từ chối" dạng viền nét vẽ màu đỏ nổi bật tác vụ hủy bỏ đơn
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showRejectDialog(context), // Gọi bật mở cửa sổ pop-up hộp thoại lấy lý do từ chối
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red), // Viền đỏ bao quanh nút bấm
                minimumSize: const Size(0, 56), // Chiều cao hộp nút bấm chuẩn là 56 đơn vị
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16), // Khoảng trống phân tách giữa hai phím nút bấm
          // Nút bấm lớn màu nâu hệ thống thực hiện phê duyệt đồng ý tiếp nhận lịch đặt đơn phòng của khách
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Xử lý gọi kết nối API cập nhật trạng thái đơn phòng thành công và gửi thông báo cho khách
                print("Phê duyệt đơn đặt chỗ thành công!");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41), // Sắc màu nâu đậm chủ đạo hệ thống
                minimumSize: const Size(0, 56),
                elevation: 0, // Triệt tiêu đổ bóng mặc định giúp phím phẳng mượt tinh tế tiệp vào nền trắng BottomSheet
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Phê duyệt',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm tạo lập và mở cửa sổ pop-up hộp thoại tiếp nhận thông tin lý do khước từ đơn hàng (Alert Dialog)
  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Thiết lập bo cong góc hộp hội thoại 24 đơn vị
        title: const Text(
          'Lý do từ chối',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Thu hẹp chiều cao hộp thoại khít vừa số lượng phần tử con bên trong
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vui lòng cho khách biết lý do bạn không thể nhận đơn này.',
              style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4), // Giãn dòng 1.4 thông thoáng văn bản
            ),
            const SizedBox(height: 16),
            // Ô TextField tiếp nhận thông tin lý do giải trình gỡ đơn phòng từ phía chủ nhà
            TextField(
              maxLines: 3, // Giới hạn chiều cao ô hiển thị mặc định rộng 3 dòng chữ nhập
              decoration: InputDecoration(
                hintText: 'Nhập lý do...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade100, // Phủ lớp nền màu xám nhạt mịn màng sạch sẽ
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none, // Triệt tiêu đường viền mặc định của khung TextField
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Nút phím bấm chữ hỗ trợ thoát hủy bỏ tác vụ đóng cửa sổ pop-up
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          // Nút bấm lớn màu đỏ xác thực thực thi hành động hủy bỏ đơn hàng đặt phòng thực sự
          ElevatedButton(
            onPressed: () {
              // TODO: Triển khai gửi dữ liệu lý do từ chối lên Server/API hệ thống
              Navigator.pop(context); // Đóng cửa sổ pop-up hộp thoại Dialog
              print("Xác nhận gỡ bỏ từ chối đơn đặt phòng hoàn tất!");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Nền sắc đỏ nổi bật hành động gỡ bỏ
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Xác nhận từ chối',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}