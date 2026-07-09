import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/article_viewmodel.dart';
import '../../models/article_model.dart';
import 'article_list_screen.dart';
import '../common/profile_page.dart';

class AuthorDashboardScreen extends ConsumerStatefulWidget {
  const AuthorDashboardScreen({super.key});

  @override
  ConsumerState<AuthorDashboardScreen> createState() => _AuthorDashboardScreenState();
}

class _AuthorDashboardScreenState extends ConsumerState<AuthorDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authorArticleViewModelProvider.notifier).loadMyArticles());
  }

  @override
  Widget build(BuildContext context) {
    const Color purpleColor = Color(0xFF8E24AA);
    const Color primaryBrown = Color(0xFF6D4C41);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      body: _buildBody(purpleColor, primaryBrown),
      bottomNavigationBar: _buildBottomNavBar(purpleColor),
    );
  }

  Widget _buildBody(Color purpleColor, Color primaryBrown) {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab(purpleColor, primaryBrown);
      case 1:
        return const ArticleListScreen(isTab: true);
      case 2:
        return const ProfilePage();
      default:
        return _buildDashboardTab(purpleColor, primaryBrown);
    }
  }

  Widget _buildDashboardTab(Color purpleColor, Color primaryBrown) {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Author Dashboard',
            style: TextStyle(
              color: primaryBrown,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_none, color: primaryBrown),
              onPressed: () {
                context.push('/notifications');
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = 2),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=author_emma'),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(purpleColor),
                const SizedBox(height: 24),
                _buildStatsGrid(purpleColor),
                const SizedBox(height: 32),
                _buildSectionHeader('Thao tác nhanh', purpleColor),
                const SizedBox(height: 12),
                _buildQuickActionsGrid(context, purpleColor),
                const SizedBox(height: 32),
                _buildSectionHeader('Bài viết gần đây', purpleColor, showSeeAll: true, onSeeAll: () {
                  setState(() => _currentIndex = 1);
                }),
                const SizedBox(height: 12),
                _buildRecentArticlesList(context, purpleColor),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF6D4C41),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4C41).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chào mừng quay trở lại!',
            style: TextStyle(
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
              context.push('/create-article');
            },
            icon: const Icon(Icons.edit, size: 16, color: Color(0xFF6D4C41)),
            label: const Text('Viết bài mới', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildStatsGrid(Color accentColor) {
    final state = ref.watch(authorArticleViewModelProvider);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _statItem('Bài viết', state.isLoading ? '...' : state.articles.length.toString(), Icons.article_outlined, accentColor),
        _statItem('Lượt đọc', '0', Icons.visibility_outlined, accentColor),
        _statItem('Lượt thích', '0', Icons.favorite_border_outlined, accentColor),
        _statItem('Đánh giá', '0.0 ★', Icons.star_outline, accentColor),
      ],
    );
  }

  Widget _statItem(String title, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: accentColor, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D4C41),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color accentColor, {bool showSeeAll = false, VoidCallback? onSeeAll}) {
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
            child: Text('Xem tất cả', style: TextStyle(color: accentColor)),
          ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, Color accentColor) {
    return Row(
      children: [
        Expanded(
          child: _quickActionItem(
            'Quản lý\nbài viết',
            Icons.folder_outlined,
            accentColor,
            () => setState(() => _currentIndex = 1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _quickActionItem(
            'Bình luận',
            Icons.comment_outlined,
            const Color(0xFF00897B),
            () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng sắp ra mắt')));
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _quickActionItem(
            'Thống kê',
            Icons.analytics_outlined,
            const Color(0xFFE53935),
            () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng sắp ra mắt')));
            },
          ),
        ),
      ],
    );
  }

  Widget _quickActionItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6D4C41),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentArticlesList(BuildContext context, Color accentColor) {
    final state = ref.watch(authorArticleViewModelProvider);
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.articles.isEmpty) return const Text('Bạn chưa có bài viết nào.', style: TextStyle(color: Colors.grey));
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.articles.take(3).length,
      itemBuilder: (context, index) {
        final article = state.articles[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: article.coverImage != null 
                  ? Image.network(article.coverImage!, width: 70, height: 70, fit: BoxFit.cover)
                  : Container(width: 70, height: 70, color: Colors.grey[200]),
            ),
            title: Text(
              article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              article.status == 'published' ? 'Đã xuất bản' : 'Bản nháp',
              style: TextStyle(
                color: article.status == 'published' ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onPressed: () {
                context.push('/article-detail', extra: article.id);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar(Color purpleColor) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: purpleColor,
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article), label: 'Bài viết'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Hồ sơ'),
      ],
    );
  }
}