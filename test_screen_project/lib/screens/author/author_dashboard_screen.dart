import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/article_viewmodel.dart';
import '../../models/article_model.dart';

class AuthorDashboardScreen extends ConsumerStatefulWidget {
  const AuthorDashboardScreen({super.key});

  @override
  ConsumerState<AuthorDashboardScreen> createState() => _AuthorDashboardScreenState();
}

class _AuthorDashboardScreenState extends ConsumerState<AuthorDashboardScreen> {
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Author Dashboard',
          style: TextStyle(
            color: primaryBrown,
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: primaryBrown),
            onPressed: () {
              context.push('/notifications');
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=author_emma'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
              context.push('/article-list');
            }),
            const SizedBox(height: 12),
            _buildRecentArticlesList(context, purpleColor),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
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
            color: const Color(0xFF6D4C41).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chào mừng quay trở lại, Emma!',
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
              // Navigate to Create Article Screen
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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, {bool showSeeAll = false, VoidCallback? onSeeAll}) {
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

  Widget _buildQuickActionsGrid(BuildContext context, Color color) {
    return Row(
      children: [
        Expanded(
          child: _quickActionCard(
            context,
            'Viết bài',
            'Chia sẻ trải nghiệm',
            Icons.edit_note,
            color,
            () {
              context.push('/create-article');
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _quickActionCard(
            context,
            'Bài viết',
            'Quản lý bài đăng',
            Icons.book_outlined,
            color,
            () {
              context.push('/article-list');
            },
          ),
        ),
      ],
    );
  }

  Widget _quickActionCard(
      BuildContext context,
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF424242)),
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

  Widget _buildRecentArticlesList(BuildContext context, Color color) {
    final state = ref.watch(authorArticleViewModelProvider);
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final articles = state.articles.take(2).toList();
    if (articles.isEmpty) {
      return const Center(child: Text('Không có bài viết nào', style: TextStyle(color: Colors.grey)));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: articles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final article = articles[index];
        final isDraft = article.status == 'draft';
        final statusText = isDraft ? 'Bản nháp' : 'Đã xuất bản';
        return GestureDetector(
          onTap: () {
            context.push('/article-detail', extra: article,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1518780664697-55e3ad937233?q=80&w=1000',
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
                            article.authorName ?? 'Hearth & Horizon',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDraft ? Colors.orange.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusText,
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
                        article.title,
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
                          const Icon(Icons.visibility_outlined, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text('0', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(width: 12),
                          const Icon(Icons.favorite_border_outlined, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text('0', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          const Spacer(),
                          Text(
                            article.createdAt != null ? article.createdAt.toString().split('T')[0] : 'N/A',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF8E24AA),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          context.pushReplacement('/article-list');
        } else if (index == 2) {
          context.push('/notifications');
        } else if (index == 3) {
          context.push('/profile');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article), label: 'Bài viết'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), activeIcon: Icon(Icons.notifications), label: 'Thông báo'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Hồ sơ'),
      ],
    );
  }
}