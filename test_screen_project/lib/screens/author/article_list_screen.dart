import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/article_model.dart';
import '../../viewmodels/article_viewmodel.dart';

class ArticleListScreen extends ConsumerStatefulWidget {
  const ArticleListScreen({super.key});

  @override
  ConsumerState<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends ConsumerState<ArticleListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authorArticleViewModelProvider.notifier).loadMyArticles());
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color purpleColor = Color(0xFF8E24AA);
    const Color primaryBrown = Color(0xFF6D4C41);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Bài viết của tôi',
          style: TextStyle(
            color: primaryBrown,
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro',
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: purpleColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: purpleColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Bản nháp'),
            Tab(text: 'Đã đăng'),
          ],
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(authorArticleViewModelProvider);
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: purpleColor));
          }
          final articles = state.articles;
          return TabBarView(
            controller: _tabController,
            children: [
              _buildArticleList(articles, purpleColor),
              _buildArticleList(articles.where((a) => a.status == 'draft').toList(), purpleColor),
              _buildArticleList(articles.where((a) => a.status == 'published').toList(), purpleColor),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create-article');
        },
        backgroundColor: purpleColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildArticleList(List<ArticleModel> articles, Color color) {
    if (articles.isEmpty) {
      return const Center(
        child: Text('Không có bài viết nào', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
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
          onLongPress: () {
            _showOptionsBottomSheet(context, article);
          },
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                article.authorName ?? 'Hearth & Horizon',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 8),
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
                          const SizedBox(height: 8),
                          Text(
                            article.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF424242),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1518780664697-55e3ad937233?q=80&w=1000',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  article.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(article.createdAt != null ? article.createdAt.toString().split('T')[0] : 'N/A', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const Spacer(),
                    const Icon(Icons.visibility_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text('0', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(width: 12),
                    const Icon(Icons.favorite_border_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text('0', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOptionsBottomSheet(BuildContext context, ArticleModel article) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  article.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF424242)),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: Colors.blue),
                  title: const Text('Chỉnh sửa bài viết', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    context.pop();
                    // Open edit/create screen with parameters
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Xóa bài viết', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  onTap: () {
                    context.pop();
                    _showDeleteConfirmationDialog(context, article);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, ArticleModel article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa?'),
        content: Text('Bạn có chắc chắn muốn xóa bài viết "${article.title}"? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              print("Xóa bài viết hoàn tất!");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF8E24AA),
      unselectedItemColor: Colors.grey,
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          context.pushReplacement('/author-dashboard');
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