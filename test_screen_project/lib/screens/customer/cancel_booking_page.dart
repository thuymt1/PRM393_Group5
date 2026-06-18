import 'package:flutter/material.dart';

class CancelBookingPage extends StatefulWidget {
  const CancelBookingPage({super.key});

  @override
  State<CancelBookingPage> createState() => _CancelBookingPageState();
}

class _CancelBookingPageState extends State<CancelBookingPage> {
  // Biến lưu trữ lý do hủy phòng đang được tích chọn (Null nếu chưa chọn mục nào)
  String? _selectedReason;

  // Bộ điều khiển dữ liệu nhập vào cho ô nhập chi tiết khi chọn lý do "Khác"
  final TextEditingController _otherReasonController = TextEditingController();

  // Danh sách các lý do hủy phòng mẫu được hệ thống định nghĩa sẵn
  final List<String> _reasons = [
    'Thay đổi kế hoạch du lịch',
    'Tìm thấy lựa chọn khác tốt hơn',
    'Gặp vấn đề cá nhân/sức khỏe',
    'Lý do khách quan (Thời tiết, chuyến bay...)',
    'Nhầm lẫn khi đặt phòng',
    'Khác',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Sắc nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor: Colors.white, // Nền trắng giúp phần thanh công cụ phía trên hiển thị tách biệt rõ ràng
        elevation: 0, // Loại bỏ hiệu ứng bóng đổ của thanh AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)), // Nút quay lại trang trước đó
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hủy đặt phòng',
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
        padding: const EdgeInsets.all(24), // Tạo biên đệm 24 đơn vị bao quanh vùng nội dung
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingBrief(), // Khối hiển thị tóm tắt thông tin căn homestay đang yêu cầu hủy
            const SizedBox(height: 32),
            _buildRefundPolicyNotice(), // Khối hộp màu hiển thị chi tiết chính sách hoàn tiền của hệ thống
            const SizedBox(height: 32),
            const Text(
              'Lý do hủy phòng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D4C41),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng cho chúng tôi biết lý do bạn muốn hủy để cải thiện dịch vụ.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _buildReasonList(), // Khối danh sách các tùy chọn lý do dạng Radio nút bấm tròn

            // Điều kiện Render: Nếu chọn lý do "Khác", tự động hiển thị thêm ô nhập liệu đa dòng chi tiết
            if (_selectedReason == 'Khác') ...[
              const SizedBox(height: 16),
              _buildOtherReasonInput(), // Ô nhập đoạn văn bản lý do chi tiết cụ thể
            ],
            const SizedBox(height: 40),
            _buildActionButtons(), // Khối tổ hợp phím bấm chức năng xác nhận hủy hoặc giữ lại phòng
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Khối giao diện hiển thị thẻ tóm tắt thông tin cơ bản của đơn đặt phòng hiện hành
  Widget _buildBookingBrief() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Đổ bóng mờ mịn siêu nhẹ tạo chiều sâu nổi khối
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Bo góc hình vuông cho ảnh thu nhỏ đại diện (Thumbnail)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://images.unsplash.com/photo-1518780664697-55e3ad937233?q=80&w=1000',
              width: 70,
              height: 70,
              fit: BoxFit.cover, // Điều chỉnh ảnh vừa vặn khít khung chứa
            ),
          ),
          const SizedBox(width: 16),
          // Khối văn bản hiển thị tên biệt thự, mốc thời gian lưu trú và chi phí tổng
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The Pine Hill Dalat',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '20/06 - 22/06/2026 • 2 khách',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '2.550.000đ',
                  style: TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Khối hộp thông tin hiển thị quy định và quyền lợi chính sách hoàn tiền của khách hàng
  Widget _buildRefundPolicyNotice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4E1), // Sắc nền be vàng nhạt nhã nhặn phù hợp khối thông tin lưu ý
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE07A5F).withOpacity(0.1)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF6D4C41), size: 20), // Biểu tượng dấu chấm hỏi thông tin mờ
              const SizedBox(width: 12),
              Text(
                'Chính sách hoàn tiền',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Hủy miễn phí trước 24h kể từ ngày nhận phòng. Bạn sẽ được hoàn trả 100% số tiền đã thanh toán (khoảng 2.550.000đ) vào ví hoặc tài khoản gốc.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6D4C41), height: 1.5), // Giãn dòng 1.5 thông thoáng văn bản
          ),
        ],
      ),
    );
  }

  // Khối tạo tự động danh sách các hộp chứa lý do hủy kèm RadioButton đổi trạng thái
  Widget _buildReasonList() {
    return Column(
      children: _reasons.map((reason) {
        bool isSelected = _selectedReason == reason; // Kiểm tra xem mục hiện hành có khớp trạng thái State không
        return GestureDetector(
          onTap: () => setState(() => _selectedReason = reason), // Cập nhật lý do được tick chọn vào State
          child: Container(
            margin: const EdgeInsets.only(bottom: 12), // Tạo khoảng trống ngăn cách hàng dọc các thẻ lý do
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              // Đổi sang màu hồng nhạt nhẹ 5% sắc cam nếu thẻ lý do này được chọn kích hoạt
              color: isSelected ? const Color(0xFFE07A5F).withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFFE07A5F) : Colors.grey.shade200, // Tô viền cam nổi bật
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    reason,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // In đậm chữ khi được chọn
                      color: isSelected ? const Color(0xFFE07A5F) : const Color(0xFF424242),
                    ),
                  ),
                ),
                // Thay đổi Icon hình thái vòng tròn nút bấm Radio (Đã chọn / Chưa chọn)
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? const Color(0xFFE07A5F) : Colors.grey.shade300,
                  size: 22,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Khối ô TextField nhập liệu văn bản tự do đa dòng dành cho lý do riêng biệt khác
  Widget _buildOtherReasonInput() {
    return TextField(
      controller: _otherReasonController,
      maxLines: 3, // Giới hạn chiều cao ô hiển thị mặc định 3 dòng
      decoration: InputDecoration(
        hintText: 'Nhập lý do chi tiết của bạn...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white, // Phủ màu nền trắng cho ô nhập liệu tách biệt nền Scaffold
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE07A5F)), // Bo viền cam khi click trỏ chuột tiêu điểm vào ô nhập
        ),
      ),
    );
  }

  // Khối tổ hợp các phím bấm thực hiện tác vụ gửi đơn hủy phòng hoặc quay lui hủy bỏ hành động
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Nút bấm lớn màu nâu xác nhận hành động gỡ và hủy phòng (Vô hiệu hóa tạm thời nếu chưa tích chọn lý do)
        ElevatedButton(
          onPressed: _selectedReason == null ? null : () {
            // Thực thi tiến trình gọi hàm hiển thị cửa sổ hộp thoại Dialog thông báo thành công
            _showSuccessDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6D4C41), // Sắc nâu đậm thương hiệu hệ thống
            minimumSize: const Size(double.infinity, 56), // Kéo dãn tối đa chiều ngang, chiều cao ô nút bấm 56 đơn vị
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
            disabledBackgroundColor: Colors.grey.shade300, // Đổi màu sắc xám mờ nút khi bị khóa tính năng
          ),
          child: const Text(
            'Xác nhận hủy phòng',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        // Nút bấm văn bản hỗ trợ khách quay ngược về màn hình quản lý lịch trình, giữ lại phòng lưu trú
        TextButton(
          onPressed: () => Navigator.pop(context), // Thoát đóng giao diện gỡ bỏ tiến trình
          child: const Text(
            'Giữ lại đặt phòng này',
            style: TextStyle(
              color: Color(0xFFE07A5F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Hàm sinh dựng và khởi động hộp thoại pop-up thông báo gỡ đơn phòng thành công mĩ mãn (Alert Dialog)
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Khóa tính năng bấm ra vùng khoảng không bên ngoài để đóng hội thoại, bắt buộc click nút điều phối bên dưới
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Thiết lập bo tròn góc hộp hội thoại 24 đơn vị
        content: Column(
          mainAxisSize: MainAxisSize.min, // Thu gọn chiều cao hộp thoại vừa vặn ôm khít theo số lượng widget con
          children: [
            const SizedBox(height: 20),
            // Biểu tượng dấu tích kiểm V xác thực thành công màu trắng nằm trong vòng tròn cam lớn
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE07A5F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Đã hủy thành công',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Chúng tôi đã ghi nhận yêu cầu hủy phòng của bạn. Số tiền hoàn lại sẽ được xử lý trong vòng 3-5 ngày làm việc.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            // Nút bấm lớn giúp điều hướng khách gỡ bỏ hoàn toàn ngăn xếp màn hình để về thẳng trang chủ ứng dụng
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), // Gỡ bỏ toàn bộ ngăn xếp đưa ứng dụng về trang màn hình chính tiên phong
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41),
                minimumSize: const Size(double.infinity, 50), // Chiều rộng full khối, độ cao nút chuẩn 50 đơn vị
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Về trang chủ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}