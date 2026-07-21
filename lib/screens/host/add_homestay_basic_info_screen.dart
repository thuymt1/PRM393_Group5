import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddHomestayBasicInfoScreen extends StatefulWidget {
  const AddHomestayBasicInfoScreen({super.key});

  @override
  State<AddHomestayBasicInfoScreen> createState() =>
      _AddHomestayBasicInfoScreenState();
}

class _AddHomestayBasicInfoScreenState
    extends State<AddHomestayBasicInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Bộ điều khiển dữ liệu nhập vào cho trường Tên và trường Mô tả chi tiết
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Biến lưu trữ loại hình chỗ ở đang được chọn (Mặc định là 'Toàn bộ nhà')
  String _selectedStayType = 'Toàn bộ nhà';

  // Danh sách các loại hình lưu trú được hệ thống hỗ trợ đăng tải
  final List<String> _stayTypes = [
    'Toàn bộ nhà',
    'Phòng riêng',
    'Phòng chung',
    'Khách sạn',
  ];

  Uint8List? _imageBytes;
  String? _imageName;
  bool _isPickingImage = false;

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 82,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      if (bytes.lengthInBytes > 6 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ảnh vẫn lớn hơn 6 MB. Vui lòng chọn ảnh khác.'),
          ),
        );
        return;
      }
      setState(() {
        _imageBytes = bytes;
        _imageName = image.name;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể chọn ảnh: $error')));
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }

  Future<void> _confirmClose() async {
    final hasInput =
        _imageBytes != null ||
        _nameController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty;
    if (!hasInput) {
      Navigator.pop(context);
      return;
    }

    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bỏ thông tin đang nhập?'),
        content: const Text('Ảnh và nội dung ở bước này sẽ không được lưu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Tiếp tục chỉnh sửa'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6D4C41),
            ),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
    if (shouldClose == true && mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Icons.close,
            color: Color(0xFF6D4C41),
          ), // Biểu tượng dấu X để hủy tiến trình đăng tin
          onPressed: _confirmClose,
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
          _buildProgressBar(), // Thanh trạng thái tiến độ trực quan đặt sát dưới AppBar
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
                            'Thông tin cơ bản',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6D4C41),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Bắt đầu bằng những chi tiết cốt lõi về không gian của bạn.',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 32),
                          // Chọn ảnh homestay
                          const Text(
                            'Ảnh Homestay',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6D4C41),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _pickImage,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: _isPickingImage
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFE07A5F),
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : _imageBytes != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          child: Image.memory(
                                            _imageBytes!,
                                            fit: BoxFit.cover,
                                            cacheWidth: kIsWeb ? null : 1200,
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: Row(
                                            children: [
                                              _imageAction(
                                                icon: Icons.refresh_rounded,
                                                tooltip: 'Đổi ảnh',
                                                onTap: _pickImage,
                                              ),
                                              const SizedBox(width: 8),
                                              _imageAction(
                                                icon: Icons
                                                    .delete_outline_rounded,
                                                tooltip: 'Xóa ảnh',
                                                onTap: _removeImage,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Chọn ảnh đại diện',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        const Text(
                                          'JPG hoặc PNG • tối đa 6 MB',
                                          style: TextStyle(
                                            color: Color(0xFFAAA09A),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          if (_imageBytes != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${_imageName ?? 'Ảnh homestay'} • ${_formatFileSize(_imageBytes!.lengthInBytes)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF8C8079),
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          // Ô nhập liệu Tên của Homestay
                          _buildInputField(
                            label: 'Tên Homestay',
                            hint: 'VD: The Pine Hill Dalat',
                            controller: _nameController,
                            icon: Icons.home_work_outlined,
                            maxLength: 80,
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Vui lòng nhập tên homestay';
                              }
                              if (text.length < 3) {
                                return 'Tên cần ít nhất 3 ký tự';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          // Ô nhập liệu đoạn văn bản Mô tả ngắn gọn (Cho phép nhập nhiều dòng)
                          _buildInputField(
                            label: 'Mô tả',
                            hint:
                                'Giới thiệu về không gian, tiện ích đặc biệt và phong cách sống tại đây...',
                            controller: _descriptionController,
                            maxLines:
                                5, // Mở rộng không gian hiển thị lên 5 dòng
                            icon: Icons.description_outlined,
                            maxLength: 1000,
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) return 'Vui lòng nhập mô tả';
                              if (text.length < 20) {
                                return 'Mô tả cần ít nhất 20 ký tự';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Loại chỗ ở',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6D4C41),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStayTypeSelector(), // Khối bọc (Wrap) chứa danh sách các thẻ chọn mô hình lưu trú
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildBottomActions(), // Thanh điều hướng tác vụ ("Tiếp theo") cố định ở đáy màn hình
        ],
      ),
    );
  }

  // Thanh hiển thị tiến trình hoàn thiện hồ sơ (Linear Progress Indicator)
  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: 1 / 3,
      backgroundColor: Colors.grey.shade200,
      valueColor: const AlwaysStoppedAnimation<Color>(
        Color(0xFFE07A5F),
      ), // Sắc cam cam biểu thị tiến độ
      minHeight: 6, // Độ dày của thanh tiến trình
    );
  }

  // Hàm thiết kế dùng chung cấu trúc khối ô TextField bo góc tròn kèm nhãn tiêu đề phía trên
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    required IconData icon,
    int? maxLength,
    String? Function(String?)? validator,
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
            maxLength: maxLength,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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

  Widget _imageAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox.square(
            dimension: 38,
            child: Icon(icon, color: const Color(0xFF6D4C41), size: 20),
          ),
        ),
      ),
    );
  }

  // Khối giao diện sắp xếp các nút chọn loại hình lưu trú đa dòng linh hoạt chống tràn (Wrap)
  Widget _buildStayTypeSelector() {
    return Wrap(
      spacing:
          12, // Khoảng cách hở giữa các mảnh thẻ liền kề nhau trên cùng một hàng
      runSpacing:
          12, // Khoảng cách hở giữa các hàng khi bị tự động đẩy xuống dòng
      children: _stayTypes.map((type) {
        bool isSelected =
            _selectedStayType ==
            type; // Đối chiếu kiểm tra trạng thái kích hoạt của thẻ
        return GestureDetector(
          onTap: () => setState(
            () => _selectedStayType = type,
          ), // Cập nhật State khi người dùng nhấn chọn loại hình mới
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              // Đổi sang màu vàng/be nhạt nhã nhặn nếu thẻ đó nằm trong trạng thái được kích hoạt
              color: isSelected ? const Color(0xFFF7F4E1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFE07A5F)
                    : Colors.grey.shade200, // Đường viền cam làm điểm nhấn
                width: 1.5,
              ),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFFE07A5F)
                    : const Color(
                        0xFF6D4C41,
                      ), // Đổi màu văn bản tương phản tương ứng
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Thanh thao tác chức năng đặt cố định ở phần đáy màn hình (Bottom Bar Actions)
  Widget _buildBottomActions() {
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
            ), // Đổ bóng mờ nhẹ ngược lên trên nhằm phân ranh giới với body cụ thể
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Bước 1/3',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          ElevatedButton(
            onPressed: _isPickingImage
                ? null
                : () {
                    if (_imageBytes == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng chọn ảnh homestay'),
                        ),
                      );
                      return;
                    }

                    if (!(_formKey.currentState?.validate() ?? false)) return;

                    final name = _nameController.text.trim();
                    final description = _descriptionController.text.trim();

                    Navigator.pushNamed(
                      context,
                      '/add-homestay-location',
                      arguments: {
                        'name': name,
                        'description': description,
                        'stayType': _selectedStayType,
                        'imageBytes': _imageBytes,
                        'imageName': _imageName,
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
