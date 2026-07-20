import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/common/viewmodels/edit_profile_view_model.dart';
import '../../features/common/viewmodels/profile_view_model.dart';
import '../../utils/validators.dart';

/// Màn hình chỉnh sửa thông tin cá nhân – Họ tên, Số điện thoại & Avatar
class EditProfileScreen extends ConsumerStatefulWidget {
  final String currentName;
  final String currentPhone;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentPhone,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  XFile? _pickedImage; // ảnh vừa chọn (hiển thị tạm trước khi upload xong)
  bool _isUploadingAvatar = false;

  bool get _isLoading => ref.read(editProfileViewModelProvider).isLoading;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ─── Chọn & Upload Avatar ─────────────────────────────────────────────────
  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chọn ảnh đại diện',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF6D4C41),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFFE07A5F)),
              title: const Text('Thư viện ảnh'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFFE07A5F)),
              title: const Text('Máy ảnh'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked == null) return;

    // Hiển thị ảnh tạm ngay lập tức
    setState(() {
      _pickedImage = picked;
      _isUploadingAvatar = true;
    });

    try {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();

      await ref
          .read(profileViewModelProvider.notifier)
          .uploadAvatar(bytes: bytes, ext: ext);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật ảnh đại diện thành công! ✓'),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Nếu lỗi thì bỏ ảnh tạm đi
      setState(() => _pickedImage = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi upload ảnh: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  // ─── Lưu thông tin ────────────────────────────────────────────────────────
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(editProfileViewModelProvider.notifier)
          .save(
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cập nhật thông tin thành công! ✓'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Trả về true để màn hình Profile biết cần reload
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật thất bại: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(editProfileViewModelProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'BeVietnamPro',
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: const Text(
              'Lưu',
              style: TextStyle(
                color: Color(0xFFE07A5F),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 36),
                  _buildFormSection(),
                  const SizedBox(height: 40),
                  _buildSaveButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Loading overlay khi đang upload avatar
          if (_isUploadingAvatar)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFE07A5F)),
                    SizedBox(height: 12),
                    Text(
                      'Đang tải ảnh lên...',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Avatar section ───────────────────────────────────────────────────────
  Widget _buildAvatarSection() {
    // Ưu tiên: ảnh vừa chọn → avatar_url từ profile → null
    final profileData = ref.watch(profileViewModelProvider).value;
    final networkAvatarUrl = profileData?['avatar_url'] as String?;

    ImageProvider? imageProvider;
    if (_pickedImage != null) {
      imageProvider = FileImage(File(_pickedImage!.path));
    } else if (networkAvatarUrl != null && networkAvatarUrl.isNotEmpty) {
      imageProvider = NetworkImage(networkAvatarUrl);
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: const Color(0xFFF7F4E1),
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(Icons.person, size: 56, color: Color(0xFFBDBDBD))
                : null,
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: GestureDetector(
              onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isUploadingAvatar
                      ? Colors.grey
                      : const Color(0xFFE07A5F),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Form fields ─────────────────────────────────────────────────────────
  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin cá nhân',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6D4C41),
            ),
          ),
          const SizedBox(height: 24),
          _buildField(
            label: 'Họ và tên',
            hint: 'Nguyễn Văn A',
            icon: Icons.person_outline,
            controller: _nameController,
            validator: Validators.validateFullName,
          ),
          const SizedBox(height: 20),
          _buildField(
            label: 'Số điện thoại',
            hint: '0987 654 321',
            icon: Icons.phone_outlined,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: Validators.validatePhone,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4E1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF6D4C41),
                ),
                const SizedBox(width: 8),
                Text(
                  'Email không thể thay đổi sau khi đăng ký',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF6D4C41),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15),
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFFE07A5F), size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE07A5F),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              errorStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Nút Lưu ─────────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : const Text(
              'Lưu thay đổi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
    );
  }
}
