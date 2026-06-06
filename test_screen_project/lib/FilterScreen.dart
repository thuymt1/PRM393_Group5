import 'package:flutter/material.dart';

// Hàm main() - Điểm xuất phát khởi chạy ứng dụng Flutter
void main() {
  runApp(const MyApp());
}

// Lớp cấu hình MaterialApp dùng để bọc màn hình Bộ lọc khi kiểm thử độc lập
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hearth & Horizon - Bộ Lọc',
      debugShowCheckedModeBanner: false, // Ẩn biểu tượng chữ DEBUG ở góc phải màn hình
      theme: ThemeData(
        primaryColor: const Color(0xFF6D4C41), // Thiết lập tông màu nâu chủ đạo hệ thống
        useMaterial3: true, // Kích hoạt bộ quy chuẩn giao diện Material 3 mới nhất
      ),
      home: const FilterScreen(), // Đặt FilterScreen làm màn hình mặc định khi khởi động
    );
  }
}

// Màn hình cấu hình và tùy chọn bộ lọc tìm kiếm nâng cao
class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Trạng thái lưu trữ giá trị khoảng giá (Tối thiểu là 200k, Tối đa mặc định là 5 triệu)
  RangeValues _priceRange = const RangeValues(200000, 5000000);

  // Danh sách động lưu trữ các nhãn tiện nghi được người dùng tích chọn
  final List<String> _selectedAmenities = [];

  // Biến lưu số sao đánh giá tối thiểu được chọn (0: Chưa chọn lọc theo sao)
  int _selectedRating = 0;

  // Chuỗi lưu loại hình chỗ ở được lựa chọn
  String _selectedStayType = 'Toàn bộ nhà';

  // Danh mục cấu hình danh sách các tiện nghi đi kèm homestay hỗ trợ trên hệ thống
  final List<Map<String, dynamic>> _amenities = [
    {'icon': Icons.wifi, 'label': 'Wifi'},
    {'icon': Icons.ac_unit, 'label': 'Điều hòa'},
    {'icon': Icons.pool, 'label': 'Hồ bơi'},
    {'icon': Icons.kitchen, 'label': 'Bếp'},
    {'icon': Icons.tv, 'label': 'Tivi'},
    {'icon': Icons.local_parking, 'label': 'Bãi đỗ xe'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Sắc nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor: Colors.white, // Màu nền trắng làm nổi bật thanh công cụ cấu hình
        elevation: 0, // Loại bỏ bóng đổ của thanh AppBar
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF6D4C41)), // Icon dấu X đóng màn hình bộ lọc
          onPressed: () => Navigator.pop(context), // Thoát quay lại màn hình trước đó
        ),
        title: const Text(
          'Bộ lọc',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro', // Cần khai báo cấu hình font tương ứng trong pubspec.yaml
          ),
        ),
        centerTitle: true,
        actions: [
          // Nút xóa toàn bộ cấu hình lựa chọn, đưa các bộ lọc về trạng thái ban đầu
          TextButton(
            onPressed: () {
              setState(() {
                _priceRange = const RangeValues(200000, 5000000);
                _selectedAmenities.clear();
                _selectedRating = 0;
                _selectedStayType = 'Toàn bộ nhà';
              });
            },
            child: const Text(
              'Xóa tất cả',
              style: TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24), // Tạo biên đệm 24 đơn vị bao quanh toàn bộ nội dung bộ lọc
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Loại chỗ ở'),
            const SizedBox(height: 16),
            _buildStayTypeSelector(), // Khối nút lựa chọn nhanh mô hình chỗ ở (ChoiceChip)
            const Divider(height: 48), // Đường vạch kẻ phân tách ranh giới các phân mục lọc
            _buildSectionTitle('Khoảng giá (mỗi đêm)'),
            const SizedBox(height: 8),
            _buildPriceRangeSelector(), // Khối kéo thanh trượt khoảng giá tiền RangeSlider
            const Divider(height: 48),
            _buildSectionTitle('Tiện nghi'),
            const SizedBox(height: 16),
            _buildAmenitiesGrid(), // Khối lưới ô cờ đa lựa chọn các nhãn tiện nghi phòng ốc
            const Divider(height: 48),
            _buildSectionTitle('Đánh giá tối thiểu'),
            const SizedBox(height: 16),
            _buildRatingSelector(), // Khối nút bấm chọn mức xếp hạng sao ngôi sao (1đ -> 5đ)
            const SizedBox(height: 100), // Khoảng trống đệm an toàn cuối dòng tránh bị che khuất bởi BottomSheet
          ],
        ),
      ),
      bottomSheet: _buildApplyButton(), // Nút bấm "Áp dụng bộ lọc" cố định dưới chân màn hình
    );
  }

  // Hàm thiết kế dùng chung định dạng tiêu đề cho mỗi phân mục bộ lọc (Section Title)
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6D4C41),
      ),
    );
  }

  // Khối giao diện chọn loại hình lưu trú bọc trong Wrap để tự động xuống dòng nếu bị tràn hàng ngang
  Widget _buildStayTypeSelector() {
    final types = ['Toàn bộ nhà', 'Phòng riêng', 'Khách sạn'];
    return Wrap(
      spacing: 12, // Khoảng cách hở giữa các mảnh thẻ kề cạnh nhau trên cùng một hàng
      runSpacing: 8, // Khoảng cách hở giữa các hàng khi bị xuống dòng
      children: types.map((type) {
        bool isSelected = _selectedStayType == type; // Kiểm tra trạng thái hiện tại của thẻ
        return ChoiceChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (val) => setState(() => _selectedStayType = type), // Đổi trạng thái mô hình được chọn
          selectedColor: const Color(0xFFE07A5F), // Sắc cam cam thương hiệu nổi bật khi click kích hoạt
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6D4C41),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
          ),
        );
      }).toList(),
    );
  }

  // Khối giao diện kéo thanh chọn khoảng giá kết hợp hiển thị thông số chi tiết qua hộp ô chứa
  Widget _buildPriceRangeSelector() {
    return Column(
      children: [
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 10000000, // Định mức trượt tối đa lên tới 10 triệu đồng
          divisions: 20, // Chia thanh trượt thành 20 mốc ngắt quãng đều nhau để dễ điều chỉnh dữ liệu
          activeColor: const Color(0xFFE07A5F), // Tông màu cho dải khoảng giá được chọn
          inactiveColor: Colors.grey.shade300, // Tông màu cho dải còn lại bên ngoài
          labels: RangeLabels(
            '${_priceRange.start.round()}đ', // Nhãn bóng khí hiển thị số tiền mốc đầu khi kéo trượt
            '${_priceRange.end.round()}đ', // Nhãn bóng khí hiển thị số tiền mốc cuối khi kéo trượt
          ),
          onChanged: (val) => setState(() => _priceRange = val), // Làm mới trạng thái thông số khoảng giá
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _priceInputBox('Tối thiểu', '${_priceRange.start.round()}đ'), // Ô hiển thị mức sàn số tiền
            const Icon(Icons.horizontal_rule, size: 16, color: Colors.grey), // Dấu gạch nối giữa hai ô
            _priceInputBox('Tối đa', '${_priceRange.end.round()}đ'), // Ô hiển thị mức trần số tiền
          ],
        ),
      ],
    );
  }

  // Hàm hỗ trợ thiết kế hộp tĩnh hiển thị thông số mức giá tiền cụ thể
  Widget _priceInputBox(String label, String value) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.38, // Thiết lập chiều rộng co giãn theo tỷ lệ 38% màn hình thiết bị
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // Khối lưới hiển thị danh mục các icon tiện nghi phòng ốc hỗ trợ chọn lựa đồng thời đa danh mục
  Widget _buildAmenitiesGrid() {
    return GridView.builder(
      shrinkWrap: true, // Cho phép GridView tự thu hẹp vừa khít không gian các phần tử con
      physics: const NeverScrollableScrollPhysics(), // Chuyển giao quyền cuộn màn hình cho SingleChildScrollView cha bên ngoài
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Thiết lập phân chia dạng lưới gồm 3 cột hàng dọc đều đặn
        crossAxisSpacing: 12, // Khoảng hở cột
        mainAxisSpacing: 12, // Khoảng hở dòng
        childAspectRatio: 1, // Tỷ lệ vuông tỷ lệ 1:1 cho từng ô tiện nghi
      ),
      itemCount: _amenities.length,
      itemBuilder: (context, index) {
        final amenity = _amenities[index];
        bool isSelected = _selectedAmenities.contains(amenity['label']); // Kiểm tra xem tiện nghi này đã được chọn chưa

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedAmenities.remove(amenity['label']); // Loại bỏ khỏi mảng nếu nhấn lại vào thẻ đang chọn
              } else {
                _selectedAmenities.add(amenity['label']); // Bổ sung thêm vào danh sách nếu chọn mới
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              // Biến đổi sắc màu nền sang màu vàng/be nhạt nhẹ khi được chọn tích cực
              color: isSelected ? const Color(0xFFF7F4E1) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFFE07A5F) : Colors.grey.shade200, // Tô viền cam nổi bật
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  amenity['icon'] as IconData,
                  color: isSelected ? const Color(0xFFE07A5F) : const Color(0xFF6D4C41), // Thay đổi sắc màu Icon tương ứng
                ),
                const SizedBox(height: 8),
                Text(
                  amenity['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFFE07A5F) : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Khối giao diện hàng ngang chọn lựa mức sàn số sao đánh giá tối thiểu (1 sao -> 5 sao)
  Widget _buildRatingSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        int rating = index + 1; // Tạo giá trị số sao thực tế (1 đến 5)
        bool isSelected = _selectedRating == rating;

        return GestureDetector(
          onTap: () => setState(() => _selectedRating = rating), // Lưu mức sao lựa chọn vào State
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              // Đổi hẳn màu nền sang sắc nâu đậm khi nhãn sao này được nhấn kích hoạt
              color: isSelected ? const Color(0xFF6D4C41) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Text(
                  '$rating',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black, // Đổi màu chữ tương phản theo nền hộp
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.star, color: isSelected ? Colors.amber : Colors.grey, size: 14), // Ngôi sao vàng sáng rực khi chọn
              ],
            ),
          ),
        );
      }),
    );
  }

  // Thanh nút bấm "Áp dụng bộ lọc" ghim cố định ở đáy màn hình thông qua cơ chế BottomSheet
  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Tạo viền bóng đổ ngược lên phía trên tạo chiều sâu tách biệt với body
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            // In kết quả kiểm tra trạng thái bộ lọc cấu hình được chọn ra màn hình Log Console
            print("--- Cấu hình bộ lọc được áp dụng ---");
            print("Loại chỗ ở: $_selectedStayType");
            print("Giá từ: ${_priceRange.start.round()}đđ đến ${_priceRange.end.round()}đđ");
            print("Danh sách tiện nghi: $_selectedAmenities");
            print("Mức đánh giá tối thiểu: $_selectedRating sao");

            Navigator.pop(context); // Quay ngược lại màn hình kết quả tìm kiếm danh sách
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6D4C41), // Đặt màu nâu chủ đạo hệ thống cho nút nhấn
            minimumSize: const Size(double.infinity, 56), // Co giãn full chiều rộng ngang hàng, chiều cao hộp nút là 56 đơn vị
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Bo tròn góc nút bấm
            elevation: 2,
          ),
          child: const Text(
            'Áp dụng bộ lọc',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}