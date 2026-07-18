import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class HostEarningsScreen extends StatelessWidget {
  const HostEarningsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chi tiết tổng thu nhập')),
    backgroundColor: const Color(0xFFFDFAE7),
    body: FutureBuilder<List<dynamic>>(
      future: ApiService().getHostBookingRequests(),
      builder: (context, snapshot) {
        final items = (snapshot.data ?? []).where((b) => b['status'] == 'confirmed').toList();
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (items.isEmpty) return const Center(child: Text('Chưa có khoản thanh toán nào.'));
        return ListView.separated(padding: const EdgeInsets.all(16), itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) {
          final b = items[i]; final home = b['homestays']?['name'] ?? 'Homestay';
          return Card(
            child: ListTile(
              title: Text(home, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Đặt ngày: ${b['check_in']} → ${b['check_out']}\nTạo lúc: ${b['created_at'] ?? 'Không rõ'}'),
              trailing: Text('${(b['total_price'] ?? 0)}đ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE07A5F))),
            ),
          );
        });
      },
    ),
  );
}
