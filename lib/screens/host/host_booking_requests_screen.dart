import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repository_providers.dart';

class HostBookingRequestsScreen extends ConsumerStatefulWidget {
  const HostBookingRequestsScreen({super.key});

  @override
  ConsumerState<HostBookingRequestsScreen> createState() =>
      _HostBookingRequestsScreenState();
}

class _HostBookingRequestsScreenState
    extends ConsumerState<HostBookingRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final data = await ref.read(bookingRepositoryProvider).getHostRequests();
      if (!mounted) return;
      setState(() {
        _requests = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFDFAE7,
      ), // Sắc nền nhẹ (Surface color từ design system)
      appBar: AppBar(
        backgroundColor: Colors
            .white, // Nền trắng giúp phần thanh công cụ phía trên hiển thị sạch sẽ
        elevation: 0, // Loại bỏ hiệu ứng bóng đổ của thanh AppBar
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF6D4C41),
          ), // Nút quay lại màn hình Dashboard trước đó
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Yêu cầu đặt phòng',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily:
                'BeVietnamPro', // Đảm bảo khai báo font tương ứng trong pubspec.yaml
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: Color(0xFF6D4C41),
            ), // Biểu tượng phím lọc nâng cao
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
            )
          : _loadError != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Không thể tải yêu cầu: $_loadError'),
                  TextButton(
                    onPressed: _fetchRequests,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildTabFilter(), // Khối chứa các nhãn phân loại nhanh trạng thái đặt phòng (Tất cả, Chờ duyệt...)
                Expanded(
                  child: _requests.isEmpty
                      ? const Center(
                          child: Text(
                            'Chưa có yêu cầu đặt phòng nào.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(
                            20,
                          ), // Biên đệm 20 đơn vị xung quanh danh sách cuộn
                          itemCount: _requests.length,
                          itemBuilder: (context, index) {
                            return _buildRequestCard(
                              context,
                              _requests[index],
                            ); // Sinh dựng cấu trúc chi tiết từng thẻ yêu cầu
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // Khối giao diện tạo thanh danh mục lọc trạng thái nhanh dạng hàng ngang (Horizontal Filter Chips)
  Widget _buildTabFilter() {
    return Container(
      color: Colors.white, // Tiệp nền trắng liên mạch liền kề phía dưới AppBar
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection:
            Axis.horizontal, // Cấu hình chế độ cuộn theo hàng ngang linh hoạt
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _filterChip(
              'Tất cả',
              true,
            ), // Thẻ mặc định giả định đang được tích chọn kích hoạt hoạt động
            _filterChip('Chờ duyệt', false),
            _filterChip('Đã duyệt', false),
            _filterChip('Đã từ chối', false),
          ],
        ),
      ),
    );
  }

  // Hàm hỗ trợ thiết kế cấu trúc chi tiết cho từng nhãn viên thuốc phân loại bộ lọc nhanh
  Widget _filterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(
        right: 12,
      ), // Khoảng cách hở đệm giữa các nhãn liền kề
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // Biến đổi màu nền sang sắc cam thương hiệu nếu thẻ đó được kích hoạt chọn
        color: isSelected ? const Color(0xFFE07A5F) : Colors.white,
        borderRadius: BorderRadius.circular(
          20,
        ), // Tạo kiểu dáng bo tròn viên thuốc mềm mại
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : Colors.grey.shade700, // Đổi màu văn bản tương phản với nền thẻ
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Hàm thiết kế cấu trúc chi tiết thẻ Card chứa đầy đủ thông tin khách đặt và nút duyệt tác vụ
  Widget _buildRequestCard(BuildContext context, dynamic data) {
    bool isPending = data['status'] == 'pending';
    bool isConfirmed = data['status'] == 'confirmed';
    bool isCancelPending = data['status'] == 'cancel_pending';
    bool isRefunded = data['status'] == 'refunded';
    bool isCancelled = data['status'] == 'cancelled';

    final profiles = data['profiles'] ?? {};
    final homestays = data['homestays'] ?? {};
    final guestName = profiles['full_name'] ?? 'Ẩn danh';
    final avatar =
        profiles['avatar_url'] ??
        'https://i.pravatar.cc/150?u=${data['customer_id']}';
    final homestayName = homestays['name'] ?? 'Homestay';

    // Parse ngày tháng
    final checkIn = DateTime.parse(data['check_in']);
    final checkOut = DateTime.parse(data['check_out']);
    final nights = checkOut.difference(checkIn).inDays;
    final stayDate =
        '${checkIn.day}/${checkIn.month} - ${checkOut.day}/${checkOut.month}, ${checkIn.year}';
    final details = '$nights đêm';

    final priceStr =
        data['total_price'].toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        ) +
        'đ';

    String statusText = 'Đã từ chối';
    Color statusBg = Colors.red.shade50;
    Color statusFg = Colors.red;

    if (isPending) {
      statusText = 'Chờ duyệt';
      statusBg = Colors.orange.shade50;
      statusFg = Colors.orange;
    } else if (isConfirmed) {
      statusText = 'Đã duyệt';
      statusBg = Colors.green.shade50;
      statusFg = Colors.green;
    } else if (isCancelPending) {
      statusText = 'Yêu cầu hủy';
      statusBg = Colors.deepOrange.shade50;
      statusFg = Colors.deepOrange;
    } else if (isRefunded) {
      statusText = 'Đã hoàn/hủy';
      statusBg = Colors.blue.shade50;
      statusFg = Colors.blue;
    } else if (isCancelled) {
      statusText = 'Đã hủy hoàn tất';
      statusBg = Colors.grey.shade200;
      statusFg = Colors.grey.shade800;
    }

    return InkWell(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          '/host-booking-detail',
          arguments: data,
        );
        if (result == true) {
          _fetchRequests();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 20,
        ), // Khoảng trống đệm an toàn phân cách giữa các thẻ Card
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            24,
          ), // Bo góc tròn thẻ hồ sơ 24 đơn vị
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.03,
              ), // Đổ bóng mờ mịn siêu nhẹ 3% tạo chiều sâu nổi khối
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng ngang đầu tiên hiển thị Avatar khách, Tên khách, Homestay tương ứng và nhãn trạng thái (Badge)
            Row(
              children: [
                CircleAvatar(
                  radius: 24, // Bán kính vòng tròn ảnh chân dung vị khách
                  backgroundImage: NetworkImage(avatar),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guestName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF424242), // Sắc xám đen thẫm tinh tế
                        ),
                      ),
                      Text(
                        homestayName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Khung nhãn Badge hiển thị chữ trạng thái (Đổi sắc màu linh hoạt dựa vào điều kiện trạng thái)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg, // Đổi màu nền theo trạng thái
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusFg, // Đổi màu chữ theo trạng thái
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              height: 32,
            ), // Đường vạch kẻ ngang phân tách phần thông tin cơ bản với thông số lịch trình
            _infoRow(
              Icons.calendar_today_outlined,
              stayDate,
            ), // Dòng hiển thị mốc thời gian lưu trú
            const SizedBox(height: 12),
            _infoRow(
              Icons.people_outline,
              details,
            ), // Dòng hiển thị tổng số đêm và số lượng khách
            const SizedBox(height: 12),
            // Hàng hiển thị chi phí doanh thu thu nhập tổng cộng từ đơn phòng này
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền:',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  priceStr,
                  style: const TextStyle(
                    color: Color(
                      0xFFE07A5F,
                    ), // Sắc cam cam làm điểm nhấn nổi bật thông tin số tiền giá trị
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            // Điều kiện Render: Nếu đơn phòng đang ở trạng thái 'Yêu cầu hủy', hiển thị nút hoàn tiền
            if (isCancelPending) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Admin đang xử lý hoàn tiền',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (isPending) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  // Nút bấm "Từ chối" dạng viền nét vẽ màu đỏ nổi bật tác vụ hủy bỏ đơn
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRejectDialog(
                        context,
                        data['id'],
                      ), // Gọi mở cửa sổ pop-up lấy lý do từ chối đơn phòng
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(
                          0,
                          48,
                        ), // Chiều cao hộp nút chuẩn 48 đơn vị
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Từ chối',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ), // Khoảng trống ngăn cách giữa hai phím nút bấm
                  // Nút bấm lớn màu nâu hệ thống thực hiện phê duyệt tiếp nhận đơn phòng thành công
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Cập nhật gọi API xử lý đổi trạng thái status sang 'Đã duyệt'
                        try {
                          await ref
                              .read(bookingRepositoryProvider)
                              .updateStatus(data['id'], 'confirmed');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã phê duyệt thành công!'),
                            ),
                          );
                          _fetchRequests(); // Refresh list
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF6D4C41,
                        ), // Tông màu nâu đậm chủ đạo hệ thống
                        minimumSize: const Size(0, 48),
                        elevation:
                            0, // Triệt tiêu đổ bóng mặc định giúp phím phẳng mượt tinh tế
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Phê duyệt',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Hàm thiết kế dùng chung hiển thị một hàng chứa Icon xám mờ và văn bản đối ứng đi kèm
  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
        ),
      ],
    );
  }

  // Hàm sinh dựng và mở hộp thoại pop-up lấy thông tin lý do từ chối đơn hàng của khách (Alert Dialog)
  void _showRejectDialog(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ), // Thiết lập bo cong góc hộp hội thoại 24 đơn vị
        title: const Text(
          'Lý do từ chối',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize
              .min, // Thu hẹp chiều cao khung vừa khít ôm khít theo số lượng phần tử con bên trong
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vui lòng cho khách biết lý do bạn không thể nhận đơn đặt phòng này.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                height: 1.4,
              ), // Giãn dòng 1.4 thông thoáng văn bản dễ đọc
            ),
            const SizedBox(height: 16),
            // Ô TextField nhập nội dung lý do gỡ bỏ đơn đặt phòng từ chủ nhà
            TextField(
              maxLines:
                  3, // Giới hạn chiều cao ô nhập mặc định hiển thị 3 dòng chữ
              decoration: InputDecoration(
                hintText: 'Nhập lý do...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor:
                    Colors.grey.shade100, // Phủ lớp nền màu xám nhạt mịn màng
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide
                      .none, // Triệt tiêu đường viền mặc định của khung TextField
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Nút bấm văn bản thực hiện đóng hủy bỏ tác vụ pop-up
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          // Nút bấm lớn màu đỏ xác thực thực thi tác vụ hủy bỏ đơn đặt phòng thực tế
          ElevatedButton(
            onPressed: () async {
              // Xử lý gọi API chuyển đổi trạng thái đơn đặt phòng sang 'Đã từ chối'
              try {
                await ref
                    .read(bookingRepositoryProvider)
                    .updateStatus(bookingId, 'rejected');
                Navigator.pop(
                  context,
                ); // Đóng cửa sổ pop-up hộp thoại AlertDialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã từ chối đơn hàng!')),
                );
                _fetchRequests(); // Lấy lại dữ liệu mới
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.red, // Nền màu đỏ nổi bật hành động xóa/bỏ
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Xác nhận từ chối',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
