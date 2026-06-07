import 'package:flutter/material.dart';

class CreateReviewPage extends StatefulWidget {
  const CreateReviewPage({super.key});

  @override
  State<CreateReviewPage> createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends State<CreateReviewPage> {
  // Biến lưu số sao người dùng chọn (Mặc định là 0: Chưa chọn xếp hạng)
  int _rating = 0;

  // Bộ điều khiển nội dung văn bản cho ô nhập nhận xét chi tiết
  final TextEditingController _reviewController = TextEditingController();

  // Danh sách động lưu trữ các nhãn ấn tượng nhanh được người dùng tích chọn
  final List<String> _selectedTags = [];

  // Danh sách các thẻ từ khóa gợi ý nhanh để khách dễ dàng click lựa chọn
  final List<String> _quickTags = [
    'Sạch sẽ',
    'Chủ nhà thân thiện',
    'Vị trí đẹp',
    'Tiện nghi đầy đủ',
    'Yên tĩnh',
    'Giá hợp lý',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Sắc nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor: Colors.white, // Nền trắng giúp phần thanh công cụ phía trên hiển thị tách biệt rõ ràng
        elevation: 0, // Loại bỏ hiệu ứng bóng đổ của thanh AppBar
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF6D4C41)), // Icon dấu X đóng màn hình đánh giá
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đánh giá trải nghiệm',
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
          crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa các phần tử theo chiều ngang
          children: [
            _buildHomestayHeader(), // Khối hiển thị tóm tắt thông tin căn nhà vừa rời đi
            const SizedBox(height: 32),
            const Text(
              'Kỳ nghỉ của bạn thế nào?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D4C41),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Xếp hạng của bạn sẽ giúp chủ nhà cải thiện dịch vụ và giúp khách hàng khác có lựa chọn tốt hơn.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5), // Giãn dòng 1.5 thông thoáng văn bản
            ),
            const SizedBox(height: 32),
            _buildStarRating(), // Khối hàng ngang hiển thị 5 ngôi sao tương tác chọn điểm xếp hạng
            const SizedBox(height: 40),
            _buildQuickTagsSection(), // Khối lựa chọn nhanh các từ khóa ấn tượng nổi bật (Wrap Chips)
            const SizedBox(height: 32),
            _buildReviewInput(), // Ô nhập đoạn văn bản cảm nhận tự do đa dòng
            const SizedBox(height: 40),
            _buildSubmitButton(), // Nút xác nhận gửi thông tin đánh giá lên hệ thống
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Khối giao diện hiển thị thẻ tóm tắt nhanh thông tin homestay và ngày checkout
  Widget _buildHomestayHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
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
          // Cắt bo góc hình vuông cho ảnh thu nhỏ căn biệt thự (Thumbnail)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://images.unsplash.com/photo-1518780664697-55e3ad937233?q=80&w=1000',
              width: 60,
              height: 60,
              fit: BoxFit.cover, // Cắt cúp ảnh lấp đầy vừa vặn khung vuông
            ),
          ),
          const SizedBox(width: 16),
          // Khối văn bản hiển thị tên biệt thự và mốc thời gian rời đi
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The Pine Hill Dalat',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Đã rời đi vào 22/06/2026',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Khối hàng ngang hiển thị 5 ngôi sao lớn màu vàng cho phép click tương tác cập nhật điểm số
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        // Biến cục bộ xác định điểm số thực tế tại vị trí ngôi sao này (Từ 1 đến 5)
        int starValue = index + 1;
        bool isFilled = starValue <= _rating; // Kiểm tra xem ngôi sao này có nằm trong vùng điểm được chọn không

        return GestureDetector(
          onTap: () => setState(() => _rating = starValue), // Lưu số điểm sao được chọn vào State ứng dụng
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded, // Thay đổi trạng thái icon (Sao đặc / Sao rỗng)
              color: isFilled ? Colors.amber : Colors.grey.shade300, // Đổi sang màu vàng hổ phách rực rỡ khi được chọn
              size: 48, // Kích thước ngôi sao lớn giúp khách dễ chạm bấm chính xác trên điện thoại
            ),
          ),
        );
      }),
    );
  }

  // Khối danh sách các bộ tag ấn tượng nhanh bọc trong Wrap tự động xuống hàng thông minh chống tràn
  Widget _buildQuickTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bạn ấn tượng nhất điều gì?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6D4C41), fontSize: 16),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10, // Khoảng hở ngang giữa các thẻ tag kề cạnh nhau
          runSpacing: 10, // Khoảng hở dọc giữa các hàng khi bị tự động đẩy xuống dòng
          children: _quickTags.map((tag) {
            bool isSelected = _selectedTags.contains(tag); // Đối chiếu kiểm tra trạng thái tích chọn của thẻ từ khóa
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag); // Loại bỏ khỏi danh sách mảng nếu nhấn lại vào thẻ đang bật
                  } else {
                    _selectedTags.add(tag); // Bổ sung thêm vào mảng nếu nhấn chọn mới tích cực
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  // Đổi hẳn màu nền sang sắc cam thương hiệu khi thẻ tag được chọn kích hoạt
                  color: isSelected ? const Color(0xFFE07A5F) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6D4C41), // Thay màu chữ tương phản theo nền
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Khối ô TextField nhập liệu văn bản nhận xét chi tiết đa dòng
  Widget _buildReviewInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chia sẻ thêm chi tiết',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6D4C41), fontSize: 16),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _reviewController,
          maxLines: 5, // Cấu hình chiều cao hộp nhập liệu mở rộng sẵn 5 dòng văn bản thông thoáng
          decoration: InputDecoration(
            hintText: 'Nhập cảm nhận của bạn về không gian, chủ nhà hoặc những kỷ niệm đáng nhớ...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white, // Màu nền trắng giúp ô nổi bật trên nền Scaffold
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
              borderSide: const BorderSide(color: Color(0xFFE07A5F)), // Đổi sang viền cam khi click tiêu điểm nhập liệu
            ),
            contentPadding: const EdgeInsets.all(16), // Khoảng cách biên đệm an toàn chữ bên trong ô
          ),
        ),
      ],
    );
  }

  // Nút bấm lớn thực hiện tác vụ kiểm tra dữ liệu và gửi thông tin nhận xét (Bị khóa tạm thời nếu số sao _rating bằng 0)
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _rating == 0 ? null : () {
        // Tiến hành in log kiểm thử thông số State trước khi kích hoạt hiển thị Dialog thành công
        print("--- Dữ liệu gửi Đánh Giá ---");
        print("Xếp hạng: $_rating sao");
        print("Nhãn lựa chọn: $_selectedTags");
        print("Nội dung cảm nhận: ${_reviewController.text}");

        _showSuccessDialog(); // Khởi chạy hiển thị cửa sổ thông báo pop-up cảm ơn thành công
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41), // Sắc nâu đậm thương hiệu chủ đạo hệ thống
        minimumSize: const Size(double.infinity, 56), // Kéo dãn tối đa chiều rộng hàng ngang, chiều cao ô nút 56 đơn vị
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Thiết lập bo tròn góc phím nút bấm
        elevation: 2,
        shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
        disabledBackgroundColor: Colors.grey.shade300, // Đổi hẳn sang màu xám mờ đục khi nút bị tắt tính năng khóa bấm
      ),
      child: const Text(
        'Gửi đánh giá',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // Hàm sinh dựng và kích hoạt hộp thoại pop-up thông báo ghi nhận nhận xét thành công mỹ mãn (Alert Dialog)
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc người dùng click phím Đóng bên dưới để đóng tab, không cho bấm khoảng trống ra ngoài
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Thiết lập bo góc hộp hội thoại 24 đơn vị
        content: Column(
          mainAxisSize: MainAxisSize.min, // Thu hẹp chiều cao khung vừa khít ôm khít theo số lượng widget con bên trong
          children: [
            const SizedBox(height: 20),
            // Biểu tượng trái tim màu trắng lồng ghép tinh tế nằm trong vòng tròn cam lớn
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE07A5F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cảm ơn bạn!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Đánh giá của bạn đã được ghi nhận. Chúc bạn có những hành trình tuyệt vời tiếp theo!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            // Nút bấm gỡ bỏ ngăn xếp đóng cửa sổ pop-up để quay ngược về luồng giao diện trước đó
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Đóng pop-up hội thoại thành công Dialog
                Navigator.pop(context); // Đóng luôn màn hình CreateReviewPage để quay về danh sách đơn phòng trước đó
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41),
                minimumSize: const Size(double.infinity, 50), // Chiều rộng full ô, độ cao nút chuẩn 50 đơn vị
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Đóng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}