import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? article;
  const ArticleDetailScreen({super.key, this.article});

  @override
  Widget build(BuildContext context) {
    // Retrieve article arguments passed through constructor
    final Map<String, dynamic>? currentArticle = article;
    if (currentArticle == null) return const Scaffold(body: Center(child: Text('Lỗi: Không tìm thấy bài viết')));
    
    // For convenience we assign it to a non-nullable variable for the rest of the code
    final Map<String, dynamic> articleData = currentArticle;
    
    const Color purpleColor = Color(0xFF8E24AA);
    const Color primaryBrown = Color(0xFF6D4C41);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: primaryBrown),
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, color: primaryBrown),
                  onPressed: () {
                    _showArticleActions(context, articleData);
                  },
                ),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    articleData['image'],
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: purpleColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          articleData['homestay'],
                          style: const TextStyle(
                            color: purpleColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        articleData['date'],
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    articleData['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryBrown,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildAuthorRow(),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    articleData['excerpt'] + "\n\n" + 
                    "Khuôn viên của homestay vô cùng thoáng đãng với nhiều cây xanh và hoa. Sáng sớm, mình có thể ngồi ngoài ban công thưởng thức ly cafe ấm và ngắm nhìn sương mù lơ lửng trên thung lũng. Không gian tĩnh mịch giúp tâm hồn được thư thái sau chuỗi ngày làm việc căng thẳng ở thành phố.\n\n" +
                    "Phòng nghỉ được thiết kế rất tỉ mỉ, giường nệm êm ái và thơm tho. Phòng tắm sạch sẽ, đầy đủ tiện nghi cần thiết. Anh chị chủ nhà cực kỳ chu đáo và mến khách, luôn nhiệt tình chỉ đường và gợi ý các quán ăn ngon chuẩn vị bản địa. Chắc chắn mình sẽ quay lại đây vào một ngày không xa!",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF424242),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInteractionsRow(articleData),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAuthorRow() {
    return const Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=author_emma'),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emma Watson',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF424242)),
            ),
            SizedBox(height: 2),
            Text(
              'Người viết bài chuyên nghiệp',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInteractionsRow(Map<String, dynamic> article) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _interactionButton(
          icon: Icons.favorite,
          iconColor: Colors.red,
          label: '${article['likes']} Thích',
          onTap: () {},
        ),
        const SizedBox(width: 32),
        _interactionButton(
          icon: Icons.chat_bubble_outline,
          iconColor: Colors.grey.shade700,
          label: '45 Bình luận',
          onTap: () {},
        ),
        const SizedBox(width: 32),
        _interactionButton(
          icon: Icons.share_outlined,
          iconColor: Colors.grey.shade700,
          label: 'Chia sẻ',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _interactionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF424242)),
            ),
          ],
        ),
      ),
    );
  }

  void _showArticleActions(BuildContext context, Map<String, dynamic> article) {
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
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: Colors.blue),
                  title: const Text('Sửa bài viết', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    context.pop();
                    // Open edit flow
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Xóa bài viết', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  onTap: () {
                    context.pop();
                    _confirmDelete(context, article);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa?'),
        content: Text('Bạn có chắc chắn muốn xóa bài viết "${article['title']}"? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Back to list
              print("Bài viết đã được xóa thành công!");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}