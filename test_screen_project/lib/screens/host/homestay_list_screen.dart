import 'package:flutter/material.dart';

class HomestayListScreen extends StatefulWidget {
  const HomestayListScreen({super.key});

  @override
  State<HomestayListScreen> createState() => _HomestayListScreenState();
}

class _HomestayListScreenState extends State<HomestayListScreen> {
  // Tập hợp danh sách dữ liệu mô phỏng thông tin các căn Homestay trên toàn hệ thống
  final List<Map<String, dynamic>> _homestays = [
    {
      'name': 'The Pine Hill',
      'location': 'Phường 4, Đà Lạt',
      'price': '1.200.000',
      'rating': 4.8,
      'image': 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'name': 'Minimalist Villa',
      'location': 'Hồ Tuyền Lâm',
      'price': '2.500.000',
      'rating': 4.9,
      'image': 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'name': 'Ocean Breeze Loft',
      'location': 'Sơn Trà, Đà Nẵng',
      'price': '1.850.000',
      'rating': 4.7,
      'image': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'name': 'Vintage Garden',
      'location': 'Mai Anh Đào, Đà Lạt',
      'price': '850.000',
      'rating': 4.6,
      'image': 'https://images.unsplash.com/photo-1449156001437-3a1441df910b?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'name': 'A-Frame Escape',
      'location': 'Trại Mát, Đà Lạt',
      'price': '1.550.000',
      'rating': 4.9,
      'image': 'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'name': 'Forest Cabin',
      'location': 'Sapa, Lào Cai',
      'price': '1.100.000',
      'rating': 4.5,
      'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1000&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Sắc nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor: Colors.white, // Nền trắng cho thanh công cụ phía trên nhằm làm nổi bật ô tìm kiếm phía dưới
        elevation: 0, // Khử bóng đổ của thanh AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
          onPressed: () => Navigator.pop(context), // Quay lại giao diện màn hình trước đó
        ),
        title: const Text(
          'Tất cả Homestay',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro', // Đảm bảo khai báo cấu hình font tương ứng trong pubspec.yaml
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF6D4C41)), // Nút cấu hình nhanh bộ lọc nâng cao
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(), // Khối chứa ô nhập tìm kiếm và thanh lựa chọn nhanh tiêu chí (Chips)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16), // Tạo biên đệm 16 đơn vị bao quanh vùng lưới ô cờ
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Thiết lập hiển thị cố định chia làm 2 cột hàng dọc
                crossAxisSpacing: 16, // Khoảng cách trống giữa các cột kế bên nhau
                mainAxisSpacing: 16, // Khoảng cách trống giữa các dòng phía trên và phía dưới
                childAspectRatio: 0.72, // Tỷ lệ vàng tương quan giữa chiều rộng và chiều cao của mỗi ô Card
              ),
              itemCount: _homestays.length, // Định số lượng thẻ cần vẽ dựa theo mảng dữ liệu đầu vào
              itemBuilder: (context, index) {
                return _buildHomestayCard(_homestays[index]); // Vẽ cấu trúc chi tiết từng thẻ ô cờ nhỏ
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Xử lý kích hoạt luồng bản đồ vị trí trực quan
          print("Mở chế độ hiển thị Bản đồ danh sách");
        },
        backgroundColor: const Color(0xFF6D4C41), // Màu sắc nâu chủ đạo cho nút bấm nổi
        icon: const Icon(Icons.map_outlined, color: Colors.white), // Biểu tượng bản đồ
        label: const Text('Bản đồ', style: TextStyle(color: Colors.white)), // Nhãn văn bản đi kèm nút rộng
      ),
    );
  }

  // Khối giao diện kết hợp ô tìm kiếm TextField và thanh bộ lọc nhanh dạng hàng ngang
  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white, // Phủ màu nền trắng đồng điệu liên mạch với AppBar phía trên
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4E1), // Sắc be nhạt tương phản nhẹ giúp làm nổi bật ô nhập dữ liệu
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm homestay...',
                  border: InputBorder.none, // Xóa bỏ viền gạch chân mặc định của TextField
                  icon: Icon(Icons.search, color: Color(0xFFE07A5F)), // Biểu tượng kính lúp sắc cam
                ),
              ),
            ),
          ),
          // Thanh danh mục bộ lọc nhanh hỗ trợ cuộn theo chiều ngang (Horizontal ListView)
          SizedBox(
            height: 40, // Giới hạn chiều cao an toàn bao quanh các nút Filter Chip
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('Gần đây', true), // Thẻ mặc định giả định được kích hoạt
                _buildFilterChip('Phổ biến', false),
                _buildFilterChip('Giá thấp', false),
                _buildFilterChip('Đánh giá cao', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm hỗ trợ thiết kế cấu trúc cho các nhãn lựa chọn nhanh tiêu chí lọc (Filter Chip)
  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8), // Tạo khoảng hở đệm giữa các nhãn kề nhau
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // Đổi màu nền sang sắc cam nếu thẻ đó được người dùng nhấn chọn kích hoạt
        color: isSelected ? const Color(0xFFE07A5F) : Colors.white,
        borderRadius: BorderRadius.circular(20), // Tạo hình dáng viên thuốc bo tròn mềm mại
        border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700, // Đổi màu chữ tương phản theo nền nhãn
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Hàm thiết kế cấu trúc chi tiết của từng ô vuông hiển thị thông tin Homestay gọn gàng
  Widget _buildHomestayCard(Map<String, dynamic> homestay) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Bo tròn bốn góc cho thẻ ô cờ 16 đơn vị
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Đổ bóng mờ nhẹ tạo cảm giác nổi tinh tế
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Khu vực hiển thị Hình ảnh (Chiếm trọn không gian trống phía trên của Card thông qua Expanded)
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), // Chỉ bo góc tròn phía trên của ảnh
                  child: Image.network(
                    homestay['image'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover, // Cắt cúp ảnh cân đối lấp đầy vùng chứa của ô lưới
                  ),
                ),
                // Nút bấm hình trái tim nhỏ ở góc phải bức ảnh tương tác lưu mục yêu thích
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.8), // Nền trắng mờ trong suốt
                    radius: 14, // Kích thước vòng tròn bao quanh icon thu nhỏ gọn gàng
                    child: const Icon(Icons.favorite_border, size: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          // Khu vực hiển thị thông tin bằng văn bản chi tiết bên dưới ảnh của Homestay
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng hiển thị Tên Homestay và Điểm số đánh giá trung bình
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        homestay['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis, // Xuất hiện dấu ba chấm ngắt quãng nếu tên quá rộng
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12), // Biểu tượng ngôi sao vàng đánh giá
                        Text(' ${homestay['rating']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Hiển thị thông tin địa phương/vị trí địa lý căn nhà
                Text(
                  homestay['location'],
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Giới hạn nội dung địa chỉ hiển thị khít trên duy nhất 1 dòng
                ),
                const SizedBox(height: 8),
                // Khối hiển thị chi phí giá thuê phòng phối trộn kích cỡ phông chữ linh hoạt
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${homestay['price']}đ',
                        style: const TextStyle(
                          color: Color(0xFFE07A5F), // Điểm xuyết sắc cam thương hiệu cho thông số giá cả
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const TextSpan(text: ' /đêm', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}