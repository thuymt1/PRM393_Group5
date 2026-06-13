import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_IntroPageData> _pages = const [
    _IntroPageData(
      imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1600&q=80',
      title: 'Tìm homestay phù hợp',
      description: 'Khám phá những homestay thoải mái, tiện nghi và đúng nhu cầu cho chuyến đi của bạn.',
      note1: 'Gợi ý nhanh',
      note2: 'Lọc theo nhu cầu',
    ),
    _IntroPageData(
      imageUrl: 'https://images.unsplash.com/photo-1560067174-8943bd829c05?auto=format&fit=crop&w=1600&q=80',
      title: 'Đặt phòng dễ dàng',
      description: 'Xem phòng trống, đặt lịch và theo dõi hành trình chỉ với vài thao tác đơn giản.',
      note1: 'Tiết kiệm thời gian',
      note2: 'Quản lý thuận tiện',
    ),
    _IntroPageData(
      imageUrl: 'https://images.unsplash.com/photo-1501183638710-841dd1904471?auto=format&fit=crop&w=1600&q=80',
      title: 'Lưu lại trải nghiệm',
      description: 'Ghi nhận đánh giá sau chuyến đi để giúp cộng đồng chọn homestay tốt hơn.',
      note1: 'Đánh giá minh bạch',
      note2: 'Cộng đồng tin cậy',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildFullScreenSlide(_pages[index]);
              },
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.34),
                    ],
                    stops: const [0.0, 0.58, 1.0],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(
                children: [
                  _buildTopBar(context),
                  const Spacer(),
                  _buildIndicators(),
                  const SizedBox(height: 14),
                  _buildBottomCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Hearth & Horizon',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'BeVietnamPro',
              shadows: [
                Shadow(
                  color: Color(0x66000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/customer-home'),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            minimumSize: const Size(0, 0),
            foregroundColor: Colors.white,
          ),
          child: const Text(
            'Bỏ qua',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Color(0x66000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullScreenSlide(_IntroPageData data) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          data.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFF7F1D8),
              alignment: Alignment.center,
              child: const Icon(
                Icons.broken_image_rounded,
                color: Color(0xFFE07A5F),
                size: 52,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final active = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }

  Widget _buildBottomCard(BuildContext context) {
    final data = _pages[_currentIndex];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6D4C41),
              fontFamily: 'BeVietnamPro',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.description,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(data.note1),
              _buildChip(data.note2),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D4C41),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
              shadowColor: const Color(0xFF6D4C41).withValues(alpha: 0.3),
            ),
            icon: const Icon(Icons.login_rounded, color: Colors.white, size: 18),
            label: const Text(
              'Đăng nhập',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: Color(0xFFE07A5F), width: 1.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              foregroundColor: const Color(0xFFE07A5F),
              backgroundColor: Colors.white,
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: const Text(
              'Đăng ký',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1D8),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6D4C41),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _IntroPageData {
  final String imageUrl;
  final String title;
  final String description;
  final String note1;
  final String note2;

  const _IntroPageData({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.note1,
    required this.note2,
  });
}
