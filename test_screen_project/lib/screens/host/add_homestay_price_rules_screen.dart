import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/homestay_viewmodel.dart';

class AddHomestayPriceRulesScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? args;
  const AddHomestayPriceRulesScreen({super.key, this.args});

  @override
  ConsumerState<AddHomestayPriceRulesScreen> createState() => _AddHomestayPriceRulesScreenState();
}

class _AddHomestayPriceRulesScreenState extends ConsumerState<AddHomestayPriceRulesScreen> {
  // Bộ điều khiển dữ liệu nhập vào cho các trường thông tin
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _checkInController = TextEditingController(text: '14:00'); // Khởi tạo giờ nhận phòng mặc định
  final TextEditingController _checkOutController = TextEditingController(text: '12:00'); // Khởi tạo giờ trả phòng mặc định
  final TextEditingController _rulesController = TextEditingController();

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
                    'Giá & Quy định',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6D4C41),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Thiết lập chi phí và các quy tắc để khách hàng có trải nghiệm tốt nhất.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  // Ô nhập chi phí thuê phòng mỗi đêm (Chỉ cho phép nhập số)
                  _buildInputField(
                    label: 'Giá mỗi đêm (VND)',
                    hint: 'VD: 1.200.000',
                    controller: _priceController,
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number, // Tối ưu cấu hình bàn phím hiển thị các nút số
                  ),
                  const SizedBox(height: 24),
                  // Hàng ngang kết hợp song song hai trường cấu hình thời gian Check-in và Check-out
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: 'Giờ nhận phòng',
                          hint: '14:00',
                          controller: _checkInController,
                          icon: Icons.login_rounded,
                        ),
                      ),
                      const SizedBox(width: 16), // Khoảng hở đệm giữa hai ô nhập thời gian
                      Expanded(
                        child: _buildInputField(
                          label: 'Giờ trả phòng',
                          hint: '12:00',
                          controller: _checkOutController,
                          icon: Icons.logout_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Ô nhập liệu văn bản ghi chú các nội quy chung tại homestay (Cho phép nhập nhiều dòng)
                  _buildInputField(
                    label: 'Quy định chung',
                    hint: 'VD: Không hút thuốc, không thú cưng, giữ yên lặng sau 22h...',
                    controller: _rulesController,
                    maxLines: 4, // Thiết lập chiều cao mở rộng ô nhập liệu lên 4 dòng
                    icon: Icons.gavel_outlined,
                  ),
                  const SizedBox(height: 32),
                  _buildTermsNotice(), // Khối hiển thị thông báo lưu ý ràng buộc điều khoản hệ thống
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomActions(), // Thanh điều hướng tác vụ ("Hoàn tất") cố định dưới đáy màn hình
        ],
      ),
    );
  }

  // Thanh hiển thị tiến trình hoàn thiện hồ sơ (Linear Progress Indicator)
  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: 1.0, // Đạt mốc tối đa biểu thị đã hoàn thành tất cả các bước (Bước 4 của 4 bước)
      backgroundColor: Colors.grey.shade200,
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE07A5F)), // Sắc cam cam biểu thị tiến độ hành trình
      minHeight: 6, // Đổi độ dày thanh tiến trình
    );
  }

  // Hàm thiết kế dùng chung cấu trúc khối ô TextField bo góc tròn kèm nhãn tiêu đề phía trên
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
                color: Colors.black.withValues(alpha: 0.03), // Đổ bóng siêu nhẹ tạo cảm giác nổi tinh tế
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
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

  // Khối thông báo lưu ý nhỏ nhắc nhở về chính sách hoạt động của cộng đồng
  Widget _buildTermsNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4E1), // Sắc nền be vàng nhạt nhã nhặn phù hợp khối thông tin lưu ý
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFF6D4C41), size: 20), // Biểu tượng dấu chấm hỏi thông tin mờ
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bằng cách hoàn tất, bạn đồng ý với các Điều khoản dịch vụ và Chính sách hoạt động của Hearth & Horizon.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6D4C41), height: 1.4),
            ),
          ),
        ],
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
            color: Colors.black.withValues(alpha: 0.05), // Đổ bóng mờ nhẹ ngược lên trên nhằm phân ranh giới rõ ràng với body
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút quay lại màn hình cấu hình Bước 3 trước đó
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Quay lại',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          // Nút bấm xác nhận hoàn tất quy trình lưu trữ dữ liệu và gửi tin đăng
          ElevatedButton(
            onPressed: () async {
              final args = widget.args ?? {};
              
              if (_priceController.text.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập giá')));
                 return;
              }
              
              final price = int.tryParse(_priceController.text.replaceAll('.', '')) ?? 0;
              final data = {
                ...args,
                'price_per_night': price,
                'amenities': _rulesController.text, // Just map to amenities or description for now
              };
              
              final success = await ref.read(hostHomestayViewModelProvider.notifier).createHomestay(data, null);
              if (success) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng homestay thành công!')));
                context.go('/host-dashboard');
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại!')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D4C41), // Sắc nâu đậm chủ đạo hệ thống
              minimumSize: const Size(160, 56), // Độ rộng tối thiểu 160 đơn vị và chiều cao nút bấm chuẩn là 56 đơn vị
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0, // Loại bỏ hiệu ứng bóng đổ phẳng mịn màng tiệp vào nền trắng của Bottom Bar
            ),
            child: const Text(
              'Hoàn tất',
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