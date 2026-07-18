import 'package:flutter/material.dart';

class HostReviewsScreen extends StatelessWidget {
  const HostReviewsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final reviews = (ModalRoute.of(context)?.settings.arguments as List<dynamic>? ?? []);
    return Scaffold(appBar: AppBar(title: const Text('Tất cả đánh giá')), backgroundColor: const Color(0xFFFDFAE7), body: reviews.isEmpty ? const Center(child: Text('Chưa có đánh giá nào.')) : ListView.separated(padding: const EdgeInsets.all(16), itemCount: reviews.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) { final r = reviews[i]; final p = r['profiles']; final rating = (r['rating'] as num?)?.toDouble() ?? 0; return Card(child: ListTile(title: Text(p?['full_name'] ?? 'Khách hàng'), subtitle: Text('${r['comment'] ?? ''}\n${'★' * rating.round()}'), isThreeLine: true)); }));
  }
}
