import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/homestay_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/homestay_model.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  // Chỉ mục lưu trữ Tab đang được lựa chọn trên BottomNavigationBar (Mặc định là 0: Khám phá)
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homestayViewModelProvider.notifier).loadHomestays();
      ref.read(profileViewModelProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Màu nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Làm trong suốt thanh công cụ phía trên
        elevation: 0, // Xóa bỏ hiệu ứng đổ bóng của thanh AppBar
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF6D4C41)), // Nút mở menu tùy chọn bên hông (Drawer)
          onPressed: () {},
        ),
        title: const Text(
          'Hearth & Horizon',
          style: TextStyle(
            color: Color(0xFFE07A5F), // Sử dụng màu cam thương hiệu đặc trưng cho tên ứng dụng
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro', // Cần cấu hình font tương ứng trong pubspec.yaml để hiển thị chuẩn
          ),
        ),
        centerTitle: true, // Căn giữa nội dung tiêu đề ứng dụng
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF6D4C41)), // Biểu tượng chuông thông báo
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18, // Ảnh đại diện thu nhỏ góc trên bên phải AppBar
              backgroundImage: (ref.watch(profileViewModelProvider).profile?.avatarUrl != null)
                  ? NetworkImage(ref.watch(profileViewModelProvider).profile!.avatarUrl!)
                  : const NetworkImage('https://i.pravatar.cc/150?u=placeholder'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(), // Khối chữ chào hỏi người dùng thân thiện
            _buildSearchSection(), // Thanh tìm kiếm nhanh kèm bộ lọc thông minh
            _buildCategoryFilter(), // Danh sách các thẻ danh mục phân loại địa hình (Biển, Núi, Rừng,...)
            _buildFeaturedSection(), // Danh sách hiển thị các thẻ Homestay nổi bật dạng cuộn dọc
            const SizedBox(height: 100), // Khoảng trống đệm an toàn tránh bị che bởi thanh điều hướng và nút FAB
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(), // Thanh thực đơn điều hướng chuyển đổi tab ở đáy màn hình
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Xử lý bật tính năng bản đồ tìm kiếm vị trí
          print("Mở chế độ xem Bản đồ homestay");
        },
        backgroundColor: const Color(0xFF6D4C41), // Đặt màu nền nâu chủ đạo cho nút nổi FAB
        child: const Icon(Icons.map_outlined, color: Colors.white), // Biểu tượng bản đồ dạng nét vẽ
      ),
    );
  }

  // Khối giao diện hiển thị văn bản chào hỏi cá nhân hóa
  Widget _buildWelcomeHeader() {
    final profile = ref.watch(profileViewModelProvider).profile;
    final name = profile?.fullName ?? 'bạn';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chào $name,',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242), // Màu xám đen thẫm tinh tế
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tìm kiếm homestay hoàn hảo cho kỳ nghỉ của bạn.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Khối hộp tìm kiếm (Search Bar) bo góc có hiệu ứng đổ bóng mờ mịn
  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // Bo tròn góc hộp nhập liệu 20 đơn vị
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Hiệu ứng đổ bóng mờ nhẹ 5% sắc đen
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Bạn muốn đi đâu?',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: InputBorder.none, // Loại bỏ đường gạch chân thô mặc định của TextField
            icon: const Icon(Icons.search, color: Color(0xFFE07A5F)), // Biểu tượng kính lúp màu cam đầu dòng
            suffixIcon: const Icon(Icons.tune, color: Color(0xFF6D4C41)), // Biểu tượng cấu hình bộ lọc cuối dòng
          ),
        ),
      ),
    );
  }

  // Khối danh sách các bộ lọc danh mục (Category Filter) hỗ trợ cuộn theo chiều ngang
  Widget _buildCategoryFilter() {
    final categories = [
      {'icon': Icons.beach_access, 'label': 'Biển'},
      {'icon': Icons.terrain, 'label': 'Núi'},
      {'icon': Icons.apartment, 'label': 'Thành phố'},
      {'icon': Icons.forest, 'label': 'Rừng'},
    ];

    return SizedBox(
      height: 90, // Thiết lập giới hạn chiều cao cố định cho vùng chứa danh sách cuộn ngang
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Cấu hình cuộn ngang danh mục
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          // Giả định mục đầu tiên (index == 0) đang được chọn kích hoạt hoạt động tích cực
          final isSelected = index == 0;

          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // Thay đổi màu nền hộp icon dựa vào trạng thái kích hoạt được chọn
                    color: isSelected ? const Color(0xFFE07A5F).withOpacity(0.1) : const Color(0xFFF7F4E1),
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected ? Border.all(color: const Color(0xFFE07A5F)) : null, // Vẽ viền nếu được chọn
                  ),
                  child: Icon(
                    categories[index]['icon'] as IconData,
                    color: isSelected ? const Color(0xFFE07A5F) : const Color(0xFF6D4C41),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  categories[index]['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, // Chữ in đậm hơn khi được chọn
                    color: isSelected ? const Color(0xFFE07A5F) : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Khối gom danh sách các căn Homestay nổi bật kèm tiêu đề nhóm và nút "Xem tất cả"
  Widget _buildFeaturedSection() {
    final homestayState = ref.watch(homestayViewModelProvider);
    final homestays = homestayState.homestays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Homestay nổi bật',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
              ),
              TextButton(
                onPressed: () {
                  // Xử lý mở xem toàn bộ danh sách Homestay
                },
                child: const Text('Xem tất cả', style: TextStyle(color: Color(0xFFE07A5F))),
              ),
            ],
          ),
        ),
        if (homestayState.isLoading)
           const Center(child: CircularProgressIndicator(color: Color(0xFFE07A5F)))
        else if (homestays.isEmpty)
           const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Chưa có homestay nào được đăng", style: TextStyle(color: Colors.grey))))
        else
          ListView.builder(
            shrinkWrap: true, // Cho phép ListView thu gọn kích thước vừa vặn theo số lượng phần tử con
            physics: const NeverScrollableScrollPhysics(), // Vô hiệu hóa tính năng cuộn riêng biệt của ListView này để dùng cuộn chung của SingleChildScrollView body
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: homestays.length,
            itemBuilder: (context, index) {
              return _buildHomestayCard(homestays[index]); // Vẽ cấu trúc từng thẻ Card Homestay chi tiết
            },
          ),
      ],
    );
  }

  // Hàm thiết kế cấu trúc chi tiết cho từng thẻ Card hiển thị hình ảnh và thông tin Homestay
  Widget _buildHomestayCard(Homestay homestay) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final imageUrl = homestay.images.isNotEmpty ? homestay.images[0] : 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?q=80&w=1000&auto=format&fit=crop';

    return GestureDetector(
      onTap: () {
        context.push('/homestay-detail', extra: homestay);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24), // Tạo khoảng cách đệm trống phía dưới thẻ Card
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // Thiết lập bo tròn bốn góc cho toàn bộ khung thẻ Card
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Bo tròn góc phần hình ảnh phía trên cùng của Card bằng cách dùng ClipRRect
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover, // Cắt và kéo dãn hình ảnh phủ kín khung chứa
                  ),
                // Nút bấm biểu tượng trái tim yêu thích (Yêu thích/Thích) đặt ở góc trên bên phải ảnh
                Positioned(
                  top: 16,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white70, // Nền trắng đục mờ trong suốt nhẹ
                    child: const Icon(Icons.favorite_border, color: Colors.black),
                  ),
                ),
                // Nhãn hiển thị điểm số xếp hạng đánh giá đặt ở góc dưới bên trái ảnh
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16), // Ngôi sao vàng đánh giá
                        const SizedBox(width: 4),
                        Text(
                          homestay.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Phần hiển thị khối văn bản thông tin chi tiết (Tên, Địa chỉ, Giá cả) phía dưới ảnh
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homestay.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Hiển thị dấu ba chấm nếu tên quá dài vượt khung
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${homestay.address}, ${homestay.city}',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Hiển thị giá tiền theo cấu trúc Text.rich tinh tế phối trộn kích thước chữ
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: formatCurrency.format(homestay.pricePerNight),
                          style: const TextStyle(
                            color: Color(0xFFE07A5F), // Sắc cam nổi bật cho thông tin giá phòng
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const TextSpan(text: '/đêm', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thanh menu điều hướng chuyển tab cố định ở phần đáy màn hình ứng dụng
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Cố định cấu trúc tránh hiệu ứng dịch dịch chuyển vị trí khi click
      selectedItemColor: const Color(0xFFE07A5F), // Tông cam làm nổi bật icon tab đang hoạt động tích cực
      unselectedItemColor: Colors.grey, // Sắc xám nhẹ cho các tab còn lại chưa được lựa chọn
      currentIndex: _currentIndex, // Gắn giá trị chỉ mục tab hiện hành của hệ thống
      onTap: (index) => setState(() => _currentIndex = index), // Cập nhật làm mới lại trạng thái Tab được chọn
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Khám phá'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Yêu thích'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Đặt chỗ'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
      ],
    );
  }
}