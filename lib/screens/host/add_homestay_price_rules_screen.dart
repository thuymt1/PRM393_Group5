import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/repository_providers.dart';
import '../../features/host/viewmodels/host_dashboard_view_model.dart';

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 12) digits = digits.substring(0, 12);
    final formatted = digits.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AddHomestayPriceRulesScreen extends ConsumerStatefulWidget {
  const AddHomestayPriceRulesScreen({super.key});

  @override
  ConsumerState<AddHomestayPriceRulesScreen> createState() =>
      _AddHomestayPriceRulesScreenState();
}

class _AddHomestayPriceRulesScreenState
    extends ConsumerState<AddHomestayPriceRulesScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Bộ điều khiển dữ liệu nhập vào cho các trường thông tin
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _checkInController = TextEditingController(
    text: '14:00',
  ); // Khởi tạo giờ nhận phòng mặc định
  final TextEditingController _checkOutController = TextEditingController(
    text: '12:00',
  ); // Khởi tạo giờ trả phòng mặc định
  final TextEditingController _rulesController = TextEditingController();
  final Set<String> _selectedRules = <String>{};
  static const _commonRules = [
    'Không hút thuốc',
    'Không thú cưng',
    'Giữ yên lặng sau 22h',
    'Không tổ chức tiệc',
  ];

  bool _isLoading = false;

  Future<void> _pickTime(TextEditingController controller) async {
    final parts = controller.text.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 12,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    final selected = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Chọn thời gian',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (selected == null || !mounted) return;
    controller.text =
        '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    setState(() {});
  }

  void _setPrice(int price) {
    final text = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    _priceController.text = text;
    setState(() {});
  }

  void _toggleRule(String rule) {
    setState(() {
      final rules = _rulesController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
      if (_selectedRules.add(rule)) {
        if (!rules.contains(rule)) rules.add(rule);
      } else {
        _selectedRules.remove(rule);
        rules.removeWhere((item) => item == rule);
      }
      _rulesController.text = rules.join(', ');
      _rulesController.selection = TextSelection.collapsed(
        offset: _rulesController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _checkInController.dispose();
    _checkOutController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

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
      body: Stack(
        children: [
          Column(
            children: [
              _buildProgressBar(), // Thanh trạng thái tiến độ trực quan đạt sát dưới AppBar
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
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
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Ô nhập chi phí thuê phòng mỗi đêm (Chỉ cho phép nhập số)
                              _buildInputField(
                                label: 'Giá mỗi đêm (VND)',
                                hint: 'VD: 1.200.000',
                                controller: _priceController,
                                icon: Icons.payments_outlined,
                                keyboardType: TextInputType.number,
                                inputFormatters: [_CurrencyInputFormatter()],
                                suffixText: 'đ',
                                validator: (value) {
                                  final digits = value?.replaceAll(
                                    RegExp(r'\D'),
                                    '',
                                  );
                                  final price = double.tryParse(digits ?? '');
                                  if (price == null || price <= 0) {
                                    return 'Vui lòng nhập giá hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              _buildPriceSuggestions(),
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
                                      readOnly: true,
                                      onTap: () =>
                                          _pickTime(_checkInController),
                                      suffixIcon: Icons.schedule_rounded,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ), // Khoảng hở đệm giữa hai ô nhập thời gian
                                  Expanded(
                                    child: _buildInputField(
                                      label: 'Giờ trả phòng',
                                      hint: '12:00',
                                      controller: _checkOutController,
                                      icon: Icons.logout_rounded,
                                      readOnly: true,
                                      onTap: () =>
                                          _pickTime(_checkOutController),
                                      suffixIcon: Icons.schedule_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Ô nhập liệu văn bản ghi chú các nội quy chung tại homestay (Cho phép nhập nhiều dòng)
                              _buildInputField(
                                label: 'Quy định chung',
                                hint:
                                    'VD: Không hút thuốc, không thú cưng, giữ yên lặng sau 22h...',
                                controller: _rulesController,
                                maxLines:
                                    4, // Thiết lập chiều cao mở rộng ô nhập liệu lên 4 dòng
                                icon: Icons.gavel_outlined,
                                maxLength: 500,
                                onChanged: (value) => setState(
                                  () => _selectedRules.removeWhere(
                                    (rule) => !value.contains(rule),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildRuleSuggestions(),
                              const SizedBox(height: 28),
                              _buildPublishSummary(args),
                              const SizedBox(height: 32),
                              _buildTermsNotice(), // Khối hiển thị thông báo lưu ý ràng buộc điều khoản hệ thống
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildBottomActions(
                args,
              ), // Thanh điều hướng tác vụ ("Hoàn tất") cố định dưới đáy màn hình
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFE07A5F)),
                        SizedBox(height: 14),
                        Text(
                          'Đang tải ảnh và đăng homestay...',
                          style: TextStyle(
                            color: Color(0xFF6D4C41),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Thanh hiển thị tiến trình hoàn thiện hồ sơ (Linear Progress Indicator)
  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value:
          1.0, // Đạt mốc tối đa biểu thị đã hoàn thành tất cả các bước (Bước 4 của 4 bước)
      backgroundColor: Colors.grey.shade200,
      valueColor: const AlwaysStoppedAnimation<Color>(
        Color(0xFFE07A5F),
      ), // Sắc cam cam biểu thị tiến độ hành trình
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
    List<TextInputFormatter>? inputFormatters,
    String? suffixText,
    IconData? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    int? maxLength,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
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
                color: Colors.black.withValues(
                  alpha: 0.03,
                ), // Đổ bóng siêu nhẹ tạo cảm giác nổi tinh tế
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            onTap: onTap,
            maxLength: maxLength,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              if (onChanged != null) {
                onChanged(value);
              } else {
                setState(() {});
              }
            },
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFFE07A5F),
                size: 22,
              ), // Biểu tượng đặc trưng đặt đầu ô
              suffixText: suffixText,
              suffixStyle: const TextStyle(
                color: Color(0xFF6D4C41),
                fontWeight: FontWeight.w700,
              ),
              suffixIcon: suffixIcon == null
                  ? null
                  : Icon(suffixIcon, color: const Color(0xFF9D8D84), size: 20),
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

  Widget _buildPriceSuggestions() {
    const prices = [500000, 1000000, 1500000, 2000000];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: prices.map((price) {
          final label = price >= 1000000
              ? '${price ~/ 1000000}${price % 1000000 == 0 ? '' : ',5'} triệu'
              : '${price ~/ 1000} nghìn';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: const Icon(Icons.add_rounded, size: 16),
              label: Text(label),
              onPressed: () => _setPrice(price),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE7DDD3)),
              labelStyle: const TextStyle(
                color: Color(0xFF6D4C41),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRuleSuggestions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _commonRules.map((rule) {
        final selected = _selectedRules.contains(rule);
        return FilterChip(
          label: Text(rule),
          selected: selected,
          onSelected: (_) => _toggleRule(rule),
          showCheckmark: false,
          selectedColor: const Color(0xFFF1DDD4),
          backgroundColor: Colors.white,
          side: BorderSide(
            color: selected ? const Color(0xFFE07A5F) : const Color(0xFFE7DDD3),
          ),
          labelStyle: TextStyle(
            color: selected ? const Color(0xFF6D4C41) : const Color(0xFF776C66),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPublishSummary(Map<String, dynamic> args) {
    final price = _priceController.text.trim();
    final rows = <(IconData, String, String)>[
      (Icons.cottage_outlined, 'Homestay', args['name']?.toString() ?? '—'),
      (
        Icons.location_on_outlined,
        'Địa điểm',
        [args['address'], args['city']].whereType<Object>().join(', '),
      ),
      (
        Icons.payments_outlined,
        'Giá mỗi đêm',
        price.isEmpty ? 'Chưa nhập' : '$price đ',
      ),
      (
        Icons.schedule_outlined,
        'Nhận / trả phòng',
        '${_checkInController.text} / ${_checkOutController.text}',
      ),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7DDD3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xem lại trước khi đăng',
            style: TextStyle(
              color: Color(0xFF6D4C41),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(row.$1, color: const Color(0xFFE07A5F), size: 19),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 104,
                    child: Text(
                      row.$2,
                      style: const TextStyle(
                        color: Color(0xFF958982),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.$3.isEmpty ? '—' : row.$3,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF4A413C),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Khối thông báo lưu ý nhỏ nhắc nhở về chính sách hoạt động của cộng đồng
  Widget _buildTermsNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF7F4E1,
        ), // Sắc nền be vàng nhạt nhã nhặn phù hợp khối thông tin lưu ý
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF6D4C41),
            size: 20,
          ), // Biểu tượng dấu chấm hỏi thông tin mờ
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bằng cách hoàn tất, bạn đồng ý với các Điều khoản dịch vụ và Chính sách hoạt động của Hearth & Horizon.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6D4C41),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
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
            color: Colors.black.withValues(
              alpha: 0.05,
            ), // Đổ bóng mờ nhẹ ngược lên trên nhằm phân ranh giới rõ ràng với body
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút quay lại màn hình cấu hình Bước 2 trước đó
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Quay lại',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          // Nút bấm xác nhận hoàn tất quy trình lưu trữ dữ liệu và gửi tin đăng
          ElevatedButton(
            onPressed: _isLoading ? null : () => _confirmPublish(args),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFF6D4C41,
              ), // Sắc nâu đậm chủ đạo hệ thống
              minimumSize: const Size(
                160,
                56,
              ), // Độ rộng tối thiểu 160 đơn vị và chiều cao nút bấm chuẩn là 56 đơn vị
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation:
                  0, // Loại bỏ hiệu ứng bóng đổ phẳng mịn màng tiệp vào nền trắng của Bottom Bar
            ),
            child: const Text(
              'Đăng homestay',
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

  Future<void> _confirmPublish(Map<String, dynamic> args) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng homestay này?'),
        content: Text(
          '“${args['name'] ?? 'Homestay'}” sẽ được hiển thị công khai với giá ${_priceController.text} đ mỗi đêm.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Kiểm tra lại'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6D4C41),
            ),
            icon: const Icon(Icons.publish_rounded, size: 18),
            label: const Text('Đăng ngay'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _handleComplete(args);
  }

  Future<void> _handleComplete(Map<String, dynamic> args) async {
    final priceStr = _priceController.text.replaceAll(RegExp(r'\D'), '');
    if (priceStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền giá phòng mỗi đêm')),
      );
      return;
    }

    final double? price = double.tryParse(priceStr);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giá phòng nhập vào không hợp lệ')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final baseDescription = args['description']?.toString().trim() ?? '';
      final rules = _rulesController.text.trim();
      final details = [
        'Loại chỗ ở: ${args['stayType'] ?? 'Chưa cập nhật'}',
        'Giờ nhận phòng: ${_checkInController.text}',
        'Giờ trả phòng: ${_checkOutController.text}',
        if (rules.isNotEmpty) 'Quy định: $rules',
      ].join('\n');
      final homestayData = {
        'name': args['name'],
        'description': '$baseDescription\n\n$details',
        'address': args['address'],
        'city': args['city'],
        'price_per_night': price,
      };

      final imageBytes = args['imageBytes'];
      final imageName = args['imageName'];
      if (imageBytes is! Uint8List ||
          imageName is! String ||
          imageName.trim().isEmpty) {
        throw Exception(
          'Không tìm thấy ảnh homestay. Vui lòng quay lại bước 1.',
        );
      }
      final imageUrl = await ref
          .read(homestayRepositoryProvider)
          .uploadImage(imageBytes, imageName);

      await ref.read(homestayRepositoryProvider).create(homestayData, imageUrl);
      ref.invalidate(hostDashboardViewModelProvider);

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng tin thất bại: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'Đăng tin thành công',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D4C41),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Homestay của bạn đã được đăng thành công và hiển thị công khai trên hệ thống.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Đóng pop-up Dialog
                  // Quay về trang chủ dashboard của Host
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/host-dashboard',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D4C41),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Đồng ý',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
