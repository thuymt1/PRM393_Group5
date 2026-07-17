import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/homestay_model.dart';

/// Màn hình hiển thị thông tin chi tiết của một căn Homestay cụ thể
class HomestayDetailPage extends StatefulWidget {
  const HomestayDetailPage({super.key});

  @override
  State<HomestayDetailPage> createState() => _HomestayDetailPageState();
}

class _HomestayDetailPageState extends State<HomestayDetailPage> {
  final ApiService _apiService = ApiService();
  bool _initialized = false;
  late Homestay _homestay;
  bool _isFavorite = false;
  bool _isFavoriteLoading = true;
  String _hostName = 'Chủ nhà';
  String? _hostAvatar;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _homestay = ModalRoute.of(context)!.settings.arguments as Homestay;
      _hostName = _homestay.hostName;
      _hostAvatar = _homestay.hostAvatar;
      _checkIfFavorite();
      _fetchHostProfile();
      _initialized = true;
    }
  }

  Future<void> _fetchHostProfile() async {
    if (_homestay.hostId.isNotEmpty) {
      final profile = await _apiService.getProfileById(_homestay.hostId);
      if (profile != null && mounted) {
        setState(() {
          _hostName = profile['full_name'] ?? _hostName;
          _hostAvatar = profile['avatar_url'] ?? _hostAvatar;
        });
      }
    }
  }

  Future<void> _checkIfFavorite() async {
    try {
      final favIds = await _apiService.getMyFavoriteHomestayIds();
      if (mounted) {
        setState(() {
          _isFavorite = favIds.contains(_homestay.id);
          _isFavoriteLoading = false;
        });
      }
    } catch (e) {
      print('Error checking favorite status: $e');
      if (mounted) {
        setState(() => _isFavoriteLoading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final originalState = _isFavorite;
    setState(() {
      _isFavorite = !originalState;
    });

    try {
      if (originalState) {
        await _apiService.removeFavorite(_homestay.id);
      } else {
        await _apiService.addFavorite(_homestay.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFavorite = originalState;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật danh sách yêu thích: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFDFAE7,
      ), // Sắc nền nhẹ (Surface color từ design system)
      body: CustomScrollView(
        // Sử dụng CustomScrollView kết hợp các Slivers để tạo hiệu ứng cuộn AppBar mượt mà
        slivers: [
          _buildSliverAppBar(
            context,
          ), // Thanh AppBar chứa hình ảnh nền có thể thu phóng và ghim cố định
          SliverToBoxAdapter(
            // Chuyển đổi khối Widget thông thường thành cấu trúc tương thích với Slivers
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(
                    _homestay,
                  ), // Khối tên nhà, chi phí thuê, địa chỉ và số sao đánh giá
                  const SizedBox(height: 24),
                  _buildHostSection(), // Khối thông tin chi tiết và nút liên hệ với chủ nhà (Host)
                  const SizedBox(height: 24),
                  _buildIntroductionSection(
                    _homestay,
                  ), // Khối văn bản mô tả giới thiệu chi tiết về homestay
                  const SizedBox(height: 24),
                  _buildReviewsSection(),
                  const SizedBox(
                    height: 100,
                  ), // Khoảng trống đệm an toàn cuối dòng tránh bị che bởi thanh đặt phòng
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBookingBar(
        context,
        _homestay,
      ), // Thanh đặt phòng kèm chi phí tổng ghim cố định ở đáy màn hình
    );
  }

  Widget _buildReviewsSection() {
    return FutureBuilder<List<dynamic>>(
      future: _apiService.getHomestayReviews(_homestay.id),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Đánh giá của khách',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6D4C41),
                  ),
                ),
                Text(
                  '${reviews.length} feedback',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (reviews.isEmpty)
              const Text(
                'Chưa có feedback cho homestay này.',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...reviews.take(5).map((item) {
                final review = item as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(
                      Icons.account_circle,
                      color: Color(0xFFE07A5F),
                    ),
                    title: Text(
                      '${review['profiles']?['full_name'] ?? 'Khách'} • ${review['rating']} ★',
                    ),
                    subtitle: Text(review['comment'] ?? ''),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  // Khối thiết kế thanh cuộn đầu trang linh hoạt (SliverAppBar) tích hợp ảnh nền
  Widget _buildSliverAppBar(BuildContext context) {
    final String imageUrl = _homestay.images.isNotEmpty
        ? _homestay.images.first
        : 'https://images.unsplash.com/photo-1510798831971-661eb04b3739?q=80&w=1000';

    return SliverAppBar(
      expandedHeight:
          320, // Chiều cao tối đa khi thanh ứng dụng mở rộng hoàn toàn
      pinned:
          true, // Ghim thanh AppBar lại thành một thanh Menu cố định khi người dùng cuộn xuống dưới
      backgroundColor: const Color(0xFFFDFAE7),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit
                  .cover, // Cắt và kéo dãn ảnh phủ kín khung không gian AppBar
            ),
            // Lớp phủ màu chuyển sắc (Gradient) giúp làm dịu và tăng độ contrast rõ nét cho các nút bấm
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black26, Colors.transparent, Colors.black26],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      // Nút tròn quay lại màn hình trước đó đặt ở góc trái
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      // Cụm các nút tròn tương tác (Chia sẻ & Yêu thích) đặt ở bên phải thanh công cụ
      actions: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF6D4C41)),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: Icon(
              _isFavoriteLoading
                  ? Icons.favorite_border
                  : (_isFavorite ? Icons.favorite : Icons.favorite_border),
              color: _isFavorite && !_isFavoriteLoading
                  ? Colors.red
                  : const Color(0xFF6D4C41),
            ),
            onPressed: _isFavoriteLoading ? null : _toggleFavorite,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  // Khối giao diện hiển thị tên biệt thự, giá tiền/đêm và số lượt bình luận đánh giá
  Widget _buildHeaderSection(Homestay homestay) {
    final String formattedPrice = homestay.pricePerNight
        .toInt()
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                homestay.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242),
                  fontFamily: 'BeVietnamPro',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${formattedPrice}đ',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(
                      0xFFE07A5F,
                    ), // Sắc cam cam làm nổi bật thông tin giá thuê phòng
                  ),
                ),
                const Text(
                  '/ đêm',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: Color(0xFFE07A5F),
            ), // Biểu tượng ghim vị trí địa lý
            const SizedBox(width: 4),
            Text(
              '${homestay.address}, ${homestay.city}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Thẻ bo góc hiển thị tổng số điểm xếp hạng trung bình (Rating Badge)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F4E1), // Nền màu vàng/be nhạt tinh tế
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize
                .min, // Giới hạn chiều rộng co khít theo khối text bên trong
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 18,
              ), // Biểu tượng ngôi sao vàng
              const SizedBox(width: 4),
              FutureBuilder<List<dynamic>>(
                future: _apiService.getHomestayReviews(homestay.id),
                builder: (_, snapshot) {
                  final ratings = (snapshot.data ?? [])
                      .map((r) => (r['rating'] as num).toDouble())
                      .toList();
                  final average = ratings.isEmpty
                      ? null
                      : ratings.reduce((a, b) => a + b) / ratings.length;
                  return Text(
                    average?.toStringAsFixed(1) ?? 'Chưa có',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  );
                },
              ),
              const Text(
                ' đánh giá',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Khối giao diện hiển thị danh tính chủ sở hữu căn hộ (Host Information)
  Widget _buildHostSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.03,
            ), // Đổ bóng mờ nhẹ tạo chiều sâu nổi khối
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24, // Ảnh đại diện hình tròn của chủ nhà
            backgroundImage: NetworkImage(
              _hostAvatar ?? 'https://i.pravatar.cc/150?u=host_alex',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hostName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF424242),
                  ),
                ),
                const Text(
                  'Chủ nhà siêu cấp • Tham gia 2021',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          // Nút liên hệ chat trực tiếp gửi tin nhắn riêng cho chủ nhà
          OutlinedButton(
            onPressed: () {
              // Xử lý mở màn hình chat hội thoại
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6D4C41), // Màu chữ nâu đậm
              side: const BorderSide(
                color: Color(0xFF6D4C41),
              ), // Màu đường viền bao quanh nút bấm
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Nhắn tin'),
          ),
        ],
      ),
    );
  }

  // Khối văn bản chứa thông tin mô tả giới thiệu tổng quan kiến trúc, vị trí homestay
  Widget _buildIntroductionSection(Homestay homestay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới thiệu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          homestay.description,
          style: const TextStyle(
            color: Color(0xFF424242),
            height: 1.6,
            fontSize: 14,
          ), // Tăng height lên 1.6 giúp giãn cách dòng văn bản thông thoáng dễ đọc
        ),
      ],
    );
  }

  // Khối hiển thị phân nhóm tập hợp các nhãn thẻ tiện ích (Amenities Grid/Chips) bọc trong Wrap linh hoạt
  Widget _buildAmenitiesSection() {
    final amenities = [
      {'icon': Icons.wifi, 'label': 'Wifi 5G'},
      {'icon': Icons.ac_unit, 'label': 'Điều hòa'},
      {'icon': Icons.kitchen, 'label': 'Bếp đầy đủ'},
      {'icon': Icons.pool, 'label': 'Hồ bơi'},
      {'icon': Icons.local_parking, 'label': 'Chỗ để xe'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiện ích cung cấp',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
        ),
        const SizedBox(height: 16),
        // Wrap tự động tính toán đẩy phần tử xuống hàng tiếp theo nếu hàng ngang hiện hành bị tràn khung hình
        Wrap(
          spacing: 10, // Khoảng hở giữa các ô kế cạnh nhau
          runSpacing: 10, // Khoảng hở giữa hàng trên và hàng dưới
          children: amenities.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize
                    .min, // Thu hẹp độ rộng vừa khít với icon và nhãn chữ đi kèm
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 18,
                    color: const Color(0xFFE07A5F),
                  ), // Icon cam thương hiệu đại diện tiện ích
                  const SizedBox(width: 8),
                  Text(
                    item['label'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Khối giao diện giả lập bản đồ không gian địa lý hiển thị vị trí căn hộ
  Widget _buildLocationSection(Homestay homestay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vị trí',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
        ),
        const SizedBox(height: 16),
        // Cắt tròn viền bốn góc cho hình nền bản đồ thông qua ClipRRect
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F4E1),
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=1000&auto=format&fit=crop',
                ), // Sử dụng ảnh sơ đồ vệ tinh bản đồ giả định
                fit: BoxFit.cover,
              ),
            ),
            // Tâm vòng tròn điểm nhấn ghim định vị màu cam nổi bật giữa bản đồ
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFFE07A5F),
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Thanh điều khiển chứa thông tin chi phí và nút hành động lớn "Đặt ngay" cố định phía đáy màn hình
  Widget _buildBottomBookingBar(BuildContext context, Homestay homestay) {
    final String formattedPrice = homestay.pricePerNight
        .toInt()
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        32,
      ), // Đệm thêm khoảng cách đáy 32 đơn vị bảo toàn phần tai thỏ / thanh vuốt hệ thống (Navigation Bar)
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.05,
            ), // Tạo bóng mờ ngược lên trên phân định ranh giới rõ ràng với body
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ), // Tạo độ bo cong mượt ở hai góc trên
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Giá dự tính',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                '${formattedPrice}đ',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE07A5F),
                ),
              ),
            ],
          ),
          // Nút bấm lớn kích hoạt tiến trình book/đặt chỗ homestay nhanh
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/booking-form',
                arguments: homestay,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFF6D4C41,
              ), // Sắc nâu đậm chủ đạo hệ thống
              minimumSize: const Size(
                160,
                56,
              ), // Đảm bảo phím bấm có độ rộng ngang tối thiểu 160 và cao 56 đơn vị
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation:
                  0, // Triệt tiêu đổ bóng mặc định để nút phẳng mịn màng tiệp vào nền BottomSheet
            ),
            child: const Text(
              'Đặt ngay',
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
