import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/repository_providers.dart';

class CreateReviewPage extends ConsumerStatefulWidget {
  const CreateReviewPage({super.key});

  @override
  ConsumerState<CreateReviewPage> createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends ConsumerState<CreateReviewPage> {
  int _rating = 0;
  bool _isSubmitting = false;
  final TextEditingController _reviewController = TextEditingController();
  final List<String> _selectedTags = [];

  final List<String> _quickTags = [
    'Sạch sẽ',
    'Chủ nhà thân thiện',
    'Vị trí đẹp',
    'Tiện nghi đầy đủ',
    'Yên tĩnh',
    'Giá hợp lý',
  ];

  late Map<String, dynamic> _booking;
  bool _initialized = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _booking = args;
      } else {
        _booking = {};
      }
      _initialized = true;
    }
  }

  String get _homestayName =>
      (_booking['homestays'] as Map?)?['name']?.toString() ?? 'Homestay';

  String? get _imageUrl {
    final images = (_booking['homestays'] as Map?)?['homestay_images'] as List?;
    if (images != null && images.isNotEmpty) {
      return images[0]['url']?.toString();
    }
    return null;
  }

  String get _checkOutStr {
    final raw = _booking['check_out']?.toString();
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  int? get _homestayId {
    final raw = (_booking['homestays'] as Map?)?['id'];
    if (raw == null) return null;
    return int.tryParse(raw.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF6D4C41)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đánh giá trải nghiệm',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'BeVietnamPro',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHomestayHeader(),
            const SizedBox(height: 32),
            const Text(
              'Kỳ nghỉ của bạn thế nào?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D4C41),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Xếp hạng của bạn sẽ giúp chủ nhà cải thiện dịch vụ và giúp khách hàng khác có lựa chọn tốt hơn.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildStarRating(),
            if (_rating > 0) ...[
              const SizedBox(height: 12),
              Text(
                _ratingLabel(_rating),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE07A5F),
                ),
              ),
            ],
            const SizedBox(height: 40),
            _buildQuickTagsSection(),
            const SizedBox(height: 32),
            _buildReviewInput(),
            const SizedBox(height: 40),
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1:
        return 'Rất tệ';
      case 2:
        return 'Không hài lòng';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Hài lòng';
      case 5:
        return 'Tuyệt vời!';
      default:
        return '';
    }
  }

  Widget _buildHomestayHeader() {
    final imageUrl = _imageUrl;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  )
                : _placeholderImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _homestayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _checkOutStr.isNotEmpty
                      ? 'Đã rời đi vào $_checkOutStr'
                      : 'Chuyến đã hoàn thành',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4E1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.home_outlined, color: Color(0xFF6D4C41)),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= _rating;
        return GestureDetector(
          onTap: () => setState(() => _rating = starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFilled ? Colors.amber : Colors.grey.shade300,
              size: 48,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuickTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bạn ấn tượng nhất điều gì?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _quickTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () => setState(() {
                isSelected ? _selectedTags.remove(tag) : _selectedTags.add(tag);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE07A5F) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6D4C41),
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chia sẻ thêm chi tiết',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _reviewController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText:
                'Nhập cảm nhận của bạn về không gian, chủ nhà hoặc những kỷ niệm đáng nhớ...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE07A5F)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: (_rating == 0 || _isSubmitting) ? null : _submitReview,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
        disabledBackgroundColor: Colors.grey.shade300,
      ),
      child: _isSubmitting
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Gửi đánh giá',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
    );
  }

  Future<void> _submitReview() async {
    final id = _homestayId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy thông tin homestay.')),
      );
      return;
    }

    // Gộp tags vào comment nếu người dùng chọn
    final tagLine = _selectedTags.isNotEmpty
        ? '[${_selectedTags.join(', ')}]\n'
        : '';
    final comment = '$tagLine${_reviewController.text.trim()}';

    setState(() => _isSubmitting = true);

    try {
      await ref.read(reviewRepositoryProvider).createReview(
        homestayId: id,
        rating: _rating,
        comment: comment,
      );
      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi đánh giá thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE07A5F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cảm ơn bạn!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D4C41),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Đánh giá của bạn đã được ghi nhận. Chúc bạn có những hành trình tuyệt vời tiếp theo!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);       // Đóng dialog
                Navigator.pop(context);   // Quay về màn hình trước
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Đóng',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
