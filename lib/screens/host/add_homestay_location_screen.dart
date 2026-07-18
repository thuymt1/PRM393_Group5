import 'package:flutter/material.dart';

class AddHomestayLocationScreen extends StatefulWidget {
  const AddHomestayLocationScreen({super.key});

  @override
  State<AddHomestayLocationScreen> createState() =>
      _AddHomestayLocationScreenState();
}

class _AddHomestayLocationScreenState extends State<AddHomestayLocationScreen> {
  // Bộ điều khiển dữ liệu nhập vào cho các ô địa chỉ, thành phố và quận huyện
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  // Danh sách các thành phố phổ biến hỗ trợ tìm kiếm
  final List<String> _cities = [
    'Đà Lạt',
    'Đà Nẵng',
    'Hà Nội',
    'Phú Quốc',
    'Nha Trang',
    'Hội An',
  ];
  String? _selectedCity;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};

    return Scaffold(
      backgroundColor: const Color(
        0xFFFDFAE7,
      ), // Sắc nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor:
            Colors.white, // Màu nền trắng làm nổi bật thanh công cụ phía trên
        elevation: 0, // Loại bỏ hiệu ứng bóng đổ của thanh AppBar
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF6D4C41),
          ), // Nút quay lại bước trước đó
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đăng tin homestay mới',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily:
                'BeVietnamPro', // Đảm bảo khai báo font tương ứng trong pubspec.yaml
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProgressBar(), // Thanh trạng thái tiến độ trực quan đạt sát dưới AppBar
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                24,
              ), // Tạo biên đệm 24 đơn vị bao quanh vùng nhập liệu
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
                  // Dropdown chọn Thành phố
                  _buildCityDropdown(),
                  const SizedBox(height: 24),
                  // Trường nhập địa chỉ cụ thể (Số nhà, tên đường...)
                  _buildInputField(
                    label: 'Địa chỉ chi tiết (Số nhà, tên đường, ngõ...)',
                    hint: 'VD: 123 Đường Trần Phú',
                    controller: _addressController,
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 24),
                  // Trường nhập Quận / Huyện
                  _buildInputField(
                    label: 'Quận / Huyện / Phường / Xã',
                    hint: 'VD: Phường 4',
                    controller: _districtController,
                    icon: Icons.map_outlined,
                  ),
                ],
              ),
            ),
          ),
          _buildBottomActions(
            args,
          ), // Thanh điều phối hành động quay lại hoặc tiếp tục dưới đáy màn hình
        ],
      ),
    );
  }

  // Thanh hiển thị tiến trình hoàn thiện hồ sơ (Linear Progress Indicator)
  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value:
          0.50, // Thể hiện đang hoàn thành 50% chặng đường (Bước 2 của 4 bước)
      backgroundColor: Colors.grey.shade200,
      valueColor: const AlwaysStoppedAnimation<Color>(
        Color(0xFFE07A5F),
      ), // Sắc cam thương hiệu biểu thị tiến độ
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
            borderRadius: BorderRadius.circular(
              16,
            ), // Bo tròn góc hộp 16 đơn vị
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.03,
                ), // Đổ bóng siêu nhẹ tạo cảm giác nổi tinh tế
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
              prefixIcon: Icon(
                icon,
                color: const Color(0xFFE07A5F),
                size: 22,
              ), // Biểu tượng đặc trưng đặt đầu ô
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide
                    .none, // Ẩn đường viền mặc định để dùng thiết kế đổ bóng của Container
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Dropdown chọn khu vực/thành phố
  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thành phố / Tỉnh',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCity,
            icon: const Icon(Icons.expand_more, color: Color(0xFFE07A5F)),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.location_city_outlined,
                color: Color(0xFFE07A5F),
                size: 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
            hint: Text(
              'Chọn thành phố / tỉnh',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            items: _cities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city, style: const TextStyle(fontSize: 15)),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedCity = val;
              });
            },
          ),
        ),
      ],
    );
  }

  // Thanh điều khiển chức năng đặt cố định ở phần đáy màn hình (Bottom Bar Actions)
  Widget _buildBottomActions(Map<String, dynamic> args) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        24,
        16,
        24,
        32,
      ), // Chừa biên đệm dưới 32 đơn vị bảo toàn phần tai thỏ hệ thống
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.05,
            ), // Đổ bóng mờ nhẹ ngược lên trên nhằm phân ranh giới rõ ràng với body
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút quay lại màn hình cấu hình Bước 1 trước đó
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Quay lại',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          // Nút bấm xác nhận chuyển tiếp sang Bước 3 (Giá phòng & Quy định)
          ElevatedButton(
            onPressed: () {
              final address = _addressController.text.trim();
              final district = _districtController.text.trim();

              if (address.isEmpty ||
                  district.isEmpty ||
                  _selectedCity == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng điền đầy đủ thông tin địa điểm'),
                  ),
                );
                return;
              }

              Navigator.pushNamed(
                context,
                '/add-homestay-price-rules',
                arguments: {
                  ...args, // Truyền tiếp các thông tin từ Bước 1 bao gồm cả imageBytes và imageName
                  'address': '$address, $district',
                  'city': _selectedCity,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFF6D4C41,
              ), // Sắc nâu đậm chủ đạo hệ thống
              minimumSize: const Size(
                140,
                56,
              ), // Độ rộng tối thiểu 140 đơn vị và chiều cao nút bấm chuẩn là 56 đơn vị
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation:
                  0, // Loại bỏ hiệu ứng bóng đổ phẳng mịn màng tiệp vào nền trắng của Bottom Bar
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
