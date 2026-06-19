import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../viewmodels/item_viewmodel.dart';

class UnoptimizedListScreen extends StatefulWidget {
  const UnoptimizedListScreen({super.key});

  @override
  State<UnoptimizedListScreen> createState() => _UnoptimizedListScreenState();
}

class _UnoptimizedListScreenState extends State<UnoptimizedListScreen> {
  final ItemViewModel _viewModel = ItemViewModel();

  @override
  void initState() {
    super.initState();
    // CHƯA TỐI ƯU: Chỉ chạy 2,000 items để tránh treo máy hoàn toàn
    _viewModel.fetchItems(2000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHƯA TỐI ƯU (Unoptimized)'),
        backgroundColor: Colors.red.shade100,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // CÁCH CHƯA TỐI ƯU: 
          // 1. Sử dụng ListView(children: []) render tất cả items cùng lúc vào bộ nhớ.
          // 2. Không có itemExtent, Flutter phải đo từng item.
          // 3. Dùng IntrinsicHeight ép tính toán layout phức tạp.
          return ListView(
            children: _viewModel.items.map((item) {
              return IntrinsicHeight(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade50,
                    child: Text('${item.id}', style: const TextStyle(color: Colors.red, fontSize: 10)),
                  ),
                  title: Text(item.title),
                  subtitle: Text("${item.subtitle} - Ép tính Layout"),
                  trailing: const Icon(Icons.warning, color: Colors.red),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
