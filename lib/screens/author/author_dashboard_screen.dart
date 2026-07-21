import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/repository_providers.dart';
import '../../features/author/viewmodels/author_dashboard_view_model.dart';

class AuthorDashboardScreen extends ConsumerStatefulWidget {
  const AuthorDashboardScreen({super.key});

  @override
  ConsumerState<AuthorDashboardScreen> createState() =>
      _AuthorDashboardScreenState();
}

class _AuthorDashboardScreenState extends ConsumerState<AuthorDashboardScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 4 tab tương ứng cho Author: Dashboard, Bài viết, Thông báo, Hồ sơ
    final List<Widget> tabs = [
      _buildDashboardTab(),
      _buildArticlesTab(),
      _buildNotificationsTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      body: SafeArea(child: tabs[_currentIndex]),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- 1. TAB BẢNG ĐIỀU KHIỂN (DASHBOARD TAB) ---
  Widget _buildDashboardTab() {
    const Color purpleColor = Color(0xFF8E24AA);

    return ref
        .watch(authorDashboardViewModelProvider)
        .when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: purpleColor),
          ),
          error: (error, _) => Center(child: Text('Lỗi tải dữ liệu: $error')),
          data: (dashboard) {
            final myArticles = dashboard.articles;

            return RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(authorDashboardViewModelProvider.notifier)
                    .refresh();
              },
              color: purpleColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader('Author Dashboard'),
                    const SizedBox(height: 16),
                    _buildWelcomeCard(purpleColor),
                    const SizedBox(height: 24),
                    _buildStatsGrid(purpleColor, myArticles.length),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Thao tác nhanh', purpleColor),
                    const SizedBox(height: 12),
                    _buildQuickActionsGrid(purpleColor),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      'Bài viết gần đây nhất',
                      purpleColor,
                      showSeeAll: true,
                      onSeeAll: () {
                        _onTabTapped(1);
                      },
                    ),
                    const SizedBox(height: 12),
                    myArticles.isEmpty
                        ? _buildEmptyState('Bạn chưa viết bài viết nào.')
                        : _buildRecentArticleItem(
                            myArticles.first,
                            purpleColor,
                          ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
  }

  Widget _buildHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'BeVietnamPro',
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Color(0xFF6D4C41)),
          onPressed: () {
            _onTabTapped(2);
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(Color accentColor) {
    final user = ref.read(authRepositoryProvider).currentUser;
    final String displayName = user?.email?.split('@').first ?? 'Emma';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF6D4C41),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4C41).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chào mừng quay trở lại, $displayName!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hôm nay bạn muốn chia sẻ trải nghiệm homestay nào?',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/create-article').then((_) {
                setState(() {});
              });
            },
            icon: const Icon(Icons.edit, size: 16, color: Color(0xFF6D4C41)),
            label: const Text(
              'Viết bài mới',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFF6D4C41),
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Color accentColor, int articlesCount) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _statItem(
          'Bài viết',
          '$articlesCount',
          Icons.article_outlined,
          accentColor,
        ),
        _statItem('Lượt đọc', '1.240', Icons.visibility_outlined, accentColor),
        _statItem(
          'Lượt thích',
          '320',
          Icons.favorite_border_outlined,
          accentColor,
        ),
        _statItem('Đánh giá', '4.8 ★', Icons.star_outline, accentColor),
      ],
    );
  }

  Widget _statItem(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            val,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    Color color, {
    bool showSeeAll = false,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
        ),
        if (showSeeAll)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'Xem tất cả',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(Color color) {
    return Row(
      children: [
        Expanded(
          child: _quickActionCard(
            'Viết bài',
            'Chia sẻ trải nghiệm',
            Icons.edit_note,
            color,
            () {
              Navigator.pushNamed(context, '/create-article').then((_) {
                setState(() {});
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _quickActionCard(
            'Bài viết',
            'Quản lý bài đăng',
            Icons.book_outlined,
            color,
            () {
              _onTabTapped(1);
            },
          ),
        ),
      ],
    );
  }

  Widget _quickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          msg,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildRecentArticleItem(Map<String, dynamic> article, Color color) {
    final isDraft = article['status'] == 'draft';
    final DateTime createdAt = DateTime.parse(article['created_at']);
    final String dateStr =
        '${createdAt.day}/${createdAt.month}/${createdAt.year}';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/article-detail', arguments: article);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://images.unsplash.com/photo-1510798831971-661eb04b3739?q=80&w=1000',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TRẢI NGHIỆM',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDraft
                              ? Colors.orange.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isDraft ? 'Bản nháp' : 'Đã xuất bản',
                          style: TextStyle(
                            color: isDraft ? Colors.orange : Colors.green,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '1.250',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.favorite_border_outlined,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '320',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      const Spacer(),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. TAB BÀI VIẾT CỦA TÔI (ARTICLES TAB) ---
  Widget _buildArticlesTab() {
    const Color color = Color(0xFF8E24AA);

    return ref
        .watch(authorDashboardViewModelProvider)
        .when(
          loading: () =>
              const Center(child: CircularProgressIndicator(color: color)),
          error: (error, _) => Center(child: Text('Lỗi tải dữ liệu: $error')),
          data: (dashboard) {
            final articles = dashboard.articles;

            return Scaffold(
              backgroundColor: const Color(0xFFFDFAE7),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Bài viết của tôi',
                  style: TextStyle(
                    color: Color(0xFF6D4C41),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(authorDashboardViewModelProvider.notifier)
                      .refresh();
                },
                color: color,
                child: articles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Bạn chưa viết bài viết nào.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: articles.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildRecentArticleItem(
                            articles[index],
                            color,
                          );
                        },
                      ),
              ),
            );
          },
        );
  }

  // --- 3. TAB THÔNG BÁO (NOTIFICATIONS TAB) ---
  Widget _buildNotificationsTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có thông báo nào từ hệ thống.',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. TAB HỒ SƠ & MENU (PROFILE TAB) ---
  Widget _buildProfileTab() {
    const Color activeColor = Color(0xFF8E24AA);

    return ref
        .watch(authorDashboardViewModelProvider)
        .when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: activeColor),
          ),
          error: (error, _) => Center(child: Text('Lỗi tải dữ liệu: $error')),
          data: (dashboard) {
            final profile = dashboard.profile;
            final currentUser = ref.read(authRepositoryProvider).currentUser;

            final String rawName = profile?['full_name'] ?? '';
            final String fullName = rawName.isEmpty
                ? (currentUser?.email?.split('@').first ?? 'Người dùng')
                : rawName;

            final String rawEmail = profile?['email'] ?? '';
            final String email = rawEmail.isEmpty
                ? (currentUser?.email ?? 'Chưa cập nhật email')
                : rawEmail;

            final String rawPhone = profile?['phone'] ?? '';
            final String phone = rawPhone.isEmpty
                ? 'Chưa cập nhật SĐT'
                : rawPhone;

            final String? avatarUrl = profile?['avatar_url'];

            return Scaffold(
              backgroundColor: const Color(0xFFFDFAE7),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Menu & Hồ sơ',
                  style: TextStyle(
                    color: Color(0xFF6D4C41),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
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
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                avatarUrl != null && avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : const NetworkImage(
                                    'https://i.pravatar.cc/150?u=author',
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF424242),
                            ),
                          ),
                          Text(
                            email,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: activeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: activeColor,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Người viết bài',
                                  style: TextStyle(
                                    color: activeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildContactRow(
                            Icons.phone_iphone,
                            'Số điện thoại',
                            phone,
                          ),
                          const Divider(height: 24),
                          _buildContactRow(
                            Icons.email_outlined,
                            'Email liên hệ',
                            email,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(authRepositoryProvider).signOut();
                        if (!mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Đăng xuất',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4C41),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
  }

  Widget _buildContactRow(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6D4C41), size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              val,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF424242),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- BOTTOMNAVBAR DÀNH CHO AUTHOR ---
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF8E24AA),
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined),
          activeIcon: Icon(Icons.article),
          label: 'Bài viết',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          activeIcon: Icon(Icons.notifications),
          label: 'Thông báo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Hồ sơ',
        ),
      ],
    );
  }
}
