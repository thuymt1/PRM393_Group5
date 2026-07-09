import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/article_model.dart';
import '../../viewmodels/article_viewmodel.dart';

class ArticleListScreen extends ConsumerStatefulWidget {
  final bool isTab;
  const ArticleListScreen({super.key, this.isTab = false});

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
        leading: widget.isTab ? null : IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryBrown),
          onPressed: () => context.pop(),
        ),
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
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final article = articles[index];
        final isDraft = article.status == 'draft';
        final statusText = isDraft ? 'Bản nháp' : 'Đã đăng';

        return GestureDetector(
          onTap: () {
            context.push('/article-detail', extra: article.id);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
                      child: article.coverImage != null
                          ? Image.network(
                              article.coverImage!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            )
                          : Container(width: 70, height: 70, color: Colors.grey[200]),
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
              ],
            ),
          ),
        );
      },
    );
  }
}