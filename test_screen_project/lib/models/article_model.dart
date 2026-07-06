class ArticleModel {
  final int id;
  final String title;
  final String content;
  final String? authorId;
  final String? authorName;
  final String status;
  final String createdAt;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    this.authorId,
    this.authorName,
    required this.status,
    required this.createdAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorId: json['author_id'],
      authorName: json['author_name'],
      status: json['status'] ?? 'published',
      createdAt: json['created_at'] ?? '',
    );
  }
}
