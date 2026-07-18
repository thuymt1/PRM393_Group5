import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/author/viewmodels/article_form_view_model.dart';

class CreateArticleScreen extends ConsumerStatefulWidget {
  const CreateArticleScreen({super.key});

  @override
  ConsumerState<CreateArticleScreen> createState() =>
      _CreateArticleScreenState();
}

class _CreateArticleScreenState extends ConsumerState<CreateArticleScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _homestayController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String _selectedCategory = 'Review Trải Nghiệm';
  int _homestayRating = 5;
  bool get _isLoading => ref.read(articleFormViewModelProvider).isLoading;

  final List<String> _categories = [
    'Review Trải Nghiệm',
    'Hướng Dẫn Du Lịch',
    'Ẩm Thực Địa Phương',
    'Mẹo Đi Phượt',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _homestayController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(articleFormViewModelProvider);
    const Color purpleColor = Color(0xFF8E24AA);
    const Color primaryBrown = Color(0xFF6D4C41);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Viết bài review mới',
          style: TextStyle(
            color: primaryBrown,
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro',
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Thông tin bài viết'),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Tiêu đề bài viết',
                  hint: 'Nhập tiêu đề thu hút người đọc...',
                  controller: _titleController,
                  maxLines: 1,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Homestay được nhắc đến',
                  hint: 'Nhập tên homestay bạn muốn review...',
                  controller: _homestayController,
                  maxLines: 1,
                ),
                const SizedBox(height: 20),
                _buildDropdownSelector(purpleColor),
                const SizedBox(height: 24),
                _buildSectionTitle('Đánh giá homestay'),
                const SizedBox(height: 12),
                _buildRatingStars(purpleColor),
                const SizedBox(height: 24),
                _buildSectionTitle('Nội dung chi tiết'),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Nội dung bài viết',
                  hint:
                      'Chia sẻ chi tiết về phòng ốc, phong cảnh, dịch vụ, chủ nhà và những kỷ niệm của bạn...',
                  controller: _contentController,
                  maxLines: 10,
                ),
                const SizedBox(height: 20),
                _buildAddPhotosButton(purpleColor),
                const SizedBox(height: 40),
                _buildActionButtons(purpleColor),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: purpleColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6D4C41),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required int maxLines,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownSelector(Color activeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh mục bài viết',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF6D4C41),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: activeColor),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category, style: const TextStyle(fontSize: 15)),
                );
              }).toList(),
              onChanged: (String? val) {
                if (val != null) {
                  setState(() => _selectedCategory = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStars(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final starValue = index + 1;
          return IconButton(
            icon: Icon(
              starValue <= _homestayRating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 36,
            ),
            onPressed: () {
              setState(() => _homestayRating = starValue);
            },
          );
        }),
      ),
    );
  }

  Widget _buildAddPhotosButton(Color color) {
    return OutlinedButton.icon(
      onPressed: () {
        print("Tải ảnh bài viết lên...");
      },
      icon: Icon(Icons.add_photo_alternate_outlined, color: color),
      label: Text(
        'Thêm hình ảnh bài đăng',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildActionButtons(Color color) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              side: const BorderSide(color: Color(0xFF6D4C41)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Hủy bỏ',
              style: TextStyle(
                color: Color(0xFF6D4C41),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handlePostArticle,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Đăng bài viết',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handlePostArticle() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ tiêu đề và nội dung bài viết'),
        ),
      );
      return;
    }

    try {
      // Lưu bài viết thật vào Supabase
      await ref
          .read(articleFormViewModelProvider.notifier)
          .create(title, content);

      if (!mounted) return;
      _showSuccessDialog(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể đăng bài viết: ${e.toString()}')),
      );
    }
  }

  void _showSuccessDialog(BuildContext context) {
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
                'Đăng bài thành công!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D4C41),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Bài viết của bạn đã được phê duyệt và xuất bản lên cổng thông tin trải nghiệm Hearth & Horizon.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                  Navigator.pop(context); // Return to list/dashboard
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
