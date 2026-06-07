import 'package:flutter/material.dart';

class HomestayStatusScreen extends StatefulWidget {
  const HomestayStatusScreen({super.key});

  @override
  State<HomestayStatusScreen> createState() => _HomestayStatusScreenState();
}

class _AddHomestayStatusScreenState extends State<HomestayStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

class _HomestayStatusScreenState extends State<HomestayStatusScreen> {
  // Trạng thái điều khiển việc hiển thị công khai bài đăng (true: hiển thị, false: ẩn)
  bool _isPublic = true;

  // Chuỗi lưu trữ trạng thái phê duyệt hiện tại của bài đăng homestay trên hệ thống
  String _status = 'Đang hoạt động'; // Đang hoạt động, Chờ duyệt, Bị từ chối, Đã ẩn

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Sắc nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor: Colors.white, // Nền trắng giúp phần thanh công cụ phía trên hiển thị tách biệt rõ ràng
        elevation: 0, // Loại bỏ hiệu ứng bóng đổ của thanh AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)), // Nút bấm quay lại trang quản lý trước đó
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Trạng thái bài đăng',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'BeVietnamPro', // Đảm bảo khai báo font tương ứng trong pubspec.yaml
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF6D4C41)), // Nút xem lịch sử thay đổi trạng thái tin đăng
            onPressed: () {
              // Xử lý mở màn hình nhật ký lịch sử bài đăng
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24), // Tạo biên đệm 24 đơn vị bao quanh vùng quản lý
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPropertyPreview(), // Thẻ tóm tắt hiển thị nhanh thông tin ảnh, tên và giá của Homestay
            const SizedBox(height: 32),
            _buildStatusCard(), // Khối hộp màu cảnh báo hiển thị trạng thái kiểm duyệt hiện hành
            const SizedBox(height: 24),
            _buildManagementActions(), // Khối tổ hợp các nút chức năng quản lý nhanh (Sửa, Xem lịch, Xem thử)
            const SizedBox(height: 32),
            _buildVisibilityToggle(), // Thẻ bật tắt trạng thái Switch ẩn/hiện tin đăng công khai
            const SizedBox(height: 40),
            _buildDeleteSection(), // Khu vực giới hạn đặc biệt nguy hiểm dùng để gỡ bỏ bài đăng
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Khối giao diện hiển thị thẻ xem trước thông tin cơ bản của Homestay (Thumbnail Row)
  Widget _buildPropertyPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Đổ bóng mờ mịn nhẹ tạo hiệu ứng bề mặt
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Bo góc hình vuông thu nhỏ cho ảnh thu nhỏ đại diện (Thumbnail)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://images.unsplash.com/photo-1510798831971-661eb04b3739?q=80&w=1000',
              width: 80,
              height: 80,
              fit: BoxFit.cover, // Cắt và điều chỉnh ảnh lấp đầy khung vuông tỉ lệ
            ),
          ),
          const SizedBox(width: 16),
          // Khối văn bản hiển thị chi tiết tên căn hộ, địa danh và mức chi phí thuê phòng
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The Terracotta Nest',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF424242)),
                ),
                SizedBox(height: 4),
                Text(
                  'Đà Lạt, Lâm Đồng',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  '1.250.000đ / đêm',
                  style: TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Khối hộp hiển thị trạng thái phê duyệt của hệ thống (Đổi màu sắc linh hoạt theo State)
  Widget _buildStatusCard() {
    // Tự động gán mã màu sắc phù hợp tương ứng với từng trạng thái kiểm duyệt cụ thể
    Color statusColor = _status == 'Đang hoạt động' ? Colors.green : (_status == 'Chờ duyệt' ? Colors.orange : Colors.red);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05), // Phủ màu nền mờ nhạt tương đồng sắc màu trạng thái 5%
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.2)), // Đường viền bao quanh sắc độ nhạt 20%
      ),
      child: Column(
        children: [
          // Thay đổi Icon biểu tượng hiển thị tương ứng với trạng thái
          Icon(
            _status == 'Đang hoạt động' ? Icons.check_circle_outline : Icons.pending_actions,
            color: statusColor,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'Trạng thái: $_status',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: statusColor),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bài đăng của bạn hiện đang hiển thị công khai và có thể nhận đặt phòng.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  // Khối tập hợp các nút chức năng tương tác thao tác quản lý dữ liệu phòng ốc nhanh
  Widget _buildManagementActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quản lý nhanh',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6D4C41), fontSize: 16),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _actionButton(Icons.edit_outlined, 'Chỉnh sửa', () => print("Bấm nút Sửa"))),
            const SizedBox(width: 12),
            Expanded(child: _actionButton(Icons.calendar_today_outlined, 'Lịch trống', () => print("Bấm nút Lịch"))),
            const SizedBox(width: 12),
            Expanded(child: _actionButton(Icons.preview_outlined, 'Xem thử', () => print("Bấm nút Xem trước"))),
          ],
        ),
      ],
    );
  }

  // Hàm thiết kế dùng chung định dạng cho từng nút bấm vuông tính năng nhỏ lẻ
  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF6D4C41), size: 24),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // Khối thẻ chứa công tắc chuyển đổi (Switch) cấu hình ẩn tạm thời tin đăng bài
  Widget _buildVisibilityToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hiển thị bài đăng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  'Tắt để tạm thời ẩn homestay khỏi kết quả tìm kiếm.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPublic, // Gắn giá trị trạng thái ẩn hiện hiện thời của hệ thống
            onChanged: (val) {
              setState(() {
                _isPublic = val;
                // Cập nhật giả định chuỗi văn bản trạng thái hiển thị đi kèm linh hoạt
                _status = _isPublic ? 'Đang hoạt động' : 'Đã ẩn';
              });
            },
            activeColor: const Color(0xFFE07A5F), // Tông màu cam thương hiệu cho nút gạt khi kích hoạt bật
          ),
        ],
      ),
    );
  }

  // Khối hiển thị phân vùng khu vực cảnh báo nguy hiểm xóa bài đăng (Danger Zone)
  Widget _buildDeleteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05), // Phủ sắc nền hồng/đỏ nhạt mờ cảnh báo nguy hiểm
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Khu vực nguy hiểm',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Text(
            'Xóa bài đăng sẽ gỡ bỏ hoàn toàn homestay khỏi hệ thống. Hành động này có thể hoàn tác trong vòng 30 ngày.',
            style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),
          // Nút bấm viền Outlined màu đỏ nổi bật kích hoạt cơ chế xóa mềm bài đăng
          OutlinedButton.icon(
            onPressed: () => _confirmDelete(), // Gọi mở hàm hiển thị thông báo hộp thoại Dialog xác nhận gỡ tin bài
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Xóa bài đăng (Xóa mềm)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size(double.infinity, 48), // Kéo dãn full hàng ngang chiều rộng, chiều cao ô nút 48
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm sinh dựng và khởi động hộp thoại pop-up thông báo xác thực hành động xóa (Alert Dialog)
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa?'),
        content: const Text('Bạn có chắc chắn muốn ẩn bài đăng này? Khách hàng sẽ không thể tìm thấy hoặc đặt phòng nữa.'),
        actions: [
          // Nút chức năng hủy bỏ tác vụ đóng cửa sổ pop-up
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          // Nút bấm xác nhận xử lý hành động xóa bài đăng thực sự
          ElevatedButton(
            onPressed: () {
              setState(() {
                _status = 'Đã ẩn';
                _isPublic = false;
              });
              Navigator.pop(context); // Đóng hộp thoại AlertDialog
              print("Xử lý gọi API xóa mềm bài đăng Homestay hoàn tất!");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // Nền màu đỏ nổi bật hành động nguy hiểm
            child: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}