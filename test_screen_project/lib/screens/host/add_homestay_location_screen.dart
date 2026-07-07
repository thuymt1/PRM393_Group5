import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddHomestayLocationScreen extends StatefulWidget {
  final Map<String, dynamic>? args;
  const AddHomestayLocationScreen({super.key, this.args});

  @override
  State<AddHomestayLocationScreen> createState() => _AddHomestayLocationScreenState();
}

class _AddHomestayLocationScreenState extends State<AddHomestayLocationScreen> {
  // Bộ điều khiển dữ liệu nhập vào cho các ô địa chỉ, thành phố và quận huyện
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Sắc nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor: Colors.white, // Màu nền trắng làm nổi bật thanh công cụ phía trên
        elevation: 0, // Loại bỏ hiệu ứng bóng đổ của thanh AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)), // Nút quay lại bước trước đó
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Đăng tin homestay mới',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'BeVietnamPro', // Đảm bảo khai báo font tương ứng trong pubspec.yaml
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProgressBar(), // Thanh trạng thái tiến độ trực quan đạt sát dưới AppBar
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24), // Tạo biên đệm 24 đơn vị bao quanh vùng nhập liệu
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vị trí homestay',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6D4C41),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Địa chỉ chính xác giúp khách hàng dễ dàng tìm thấy bạn.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  // Trường nhập địa chỉ cụ thể (Số nhà, tên đường...)
                  _buildInputField(
                    label: 'Địa chỉ cụ thể',
                    hint: 'Số nhà, tên đường...',
                    controller: _addressController,
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 24),
                  // Hàng ngang kết hợp song song hai trường Quận/Huyện và Tỉnh/Thành phố thông qua Expanded
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: 'Quận / Huyện',
                          hint: 'VD: Phường 4',
                          controller: _districtController,
                          icon: Icons.map_outlined,
                        ),
                      ),
                      const SizedBox(width: 16), // Khoảng hở đệm giữa hai ô nhập liệu
                      Expanded(
                        child: _buildInputField(
                          label: 'Thành phố / Tỉnh',
                          hint: 'VD: Đà Lạt',
                          controller: _cityController,
                          icon: Icons.location_city_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Chọn vị trí trên bản đồ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6D4C41),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMapPlaceholder(), // Khối hiển thị vùng bản đồ định vị giả lập
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomActions(), // Thanh điều phối hành động quay lại hoặc tiếp tục dưới đáy màn hình
        ],
      ),
    );
  }

  // Thanh hiển thị tiến trình hoàn thiện hồ sơ (Linear Progress Indicator)
  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: 0.50, // Thể hiện đang hoàn thành 50% chặng đường (Bước 2 của 4 bước)
      backgroundColor: Colors.grey.shade200,
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE07A5F)), // Sắc cam thương hiệu biểu thị tiến độ
      minHeight: 6, // Độ dày của thanh tiến trình
    );
  }

  // Hàm thiết kế dùng chung cấu trúc khối ô TextField bo góc tròn kèm nhãn tiêu đề phía trên
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), // Bo tròn góc hộp 16 đơn vị
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03), // Đổ bóng siêu nhẹ tạo cảm giác nổi tinh tế
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFFE07A5F), size: 22), // Biểu tượng đặc trưng đặt đầu ô
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none, // Ẩn đường viền mặc định để dùng thiết kế đổ bóng của Container
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  // Khối giao diện hộp đồ họa mô phỏng không gian bản đồ định vị
  Widget _buildMapPlaceholder() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4E1),
        borderRadius: BorderRadius.circular(24), // Bo tròn 4 góc của khung bản đồ
        border: Border.all(color: Colors.grey.shade200),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=1000&auto=format&fit=crop'), // Ảnh sơ đồ vệ tinh giả lập
          fit: BoxFit.cover, // Cắt cúp ảnh phủ kín không gian Container
          opacity: 0.6, // Làm mờ nhẹ hình nền để làm nổi bật hệ thống nút bấm tương tác bên trên
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Biểu tượng vòng tròn tâm ghim định vị màu cam trắng
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.my_location, color: Color(0xFFE07A5F), size: 28),
            ),
            const SizedBox(height: 12),
            // Nút bấm tương tác giả lập hành động ghim vị trí hiện tại
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6D4C41), // Nền màu nâu đậm chủ đạo
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Ghim vị trí hiện tại',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thanh điều khiển chức năng đặt cố định ở phần đáy màn hình (Bottom Bar Actions)
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), // Chừa biên đệm dưới 32 đơn vị bảo toàn phần tai thỏ hệ thống
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Đổ bóng mờ nhẹ ngược lên trên nhằm phân ranh giới rõ ràng với body
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút quay lại màn hình cấu hình Bước 1 trước đó
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Quay lại',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          // Nút bấm xác nhận chuyển tiếp sang Bước 3 (Đăng tải hình ảnh không gian)
          ElevatedButton(
            onPressed: () {
              if (_addressController.text.isEmpty || _cityController.text.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập địa chỉ và thành phố')));
                 return;
              }
              final args = widget.args ?? {};
              final newArgs = {
                ...args,
                'address': '${_addressController.text}, ${_districtController.text}',
                'city': _cityController.text,
              };
              context.push('/add-homestay-price-rules', extra: newArgs);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D4C41), // Sắc nâu đậm chủ đạo hệ thống
              minimumSize: const Size(140, 56), // Độ rộng tối thiểu 140 đơn vị và chiều cao nút bấm chuẩn là 56 đơn vị
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0, // Loại bỏ hiệu ứng bóng đổ phẳng mịn màng tiệp vào nền trắng của Bottom Bar
            ),
            child: const Text(
              'Tiếp theo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}