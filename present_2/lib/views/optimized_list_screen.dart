import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../viewmodels/item_viewmodel.dart';

class OptimizedListScreen extends StatefulWidget {
  const OptimizedListScreen({super.key});

  @override
  State<OptimizedListScreen> createState() => _OptimizedListScreenState();
}

class _OptimizedListScreenState extends State<OptimizedListScreen> {
  final ItemViewModel _viewModel = ItemViewModel();

  @override
  void initState() {
    super.initState();
    // ĐÃ TỐI ƯU: Có thể chạy 10,000+ items vẫn cực kỳ mượt mà
    _viewModel.fetchItems(10000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ĐÃ TỐI ƯU (Optimized)'),
        backgroundColor: Colors.green.shade100,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // CÁCH ĐÃ TỐI ƯU:
          // 1. Dùng ListView.builder: Chỉ khởi tạo các items đang hiển thị (Lazy Loading).
          // 2. Dùng itemExtent: Cố định chiều cao 80.0, Flutter bỏ qua bước đo đạc (Layout pass).
          // 3. Không dùng IntrinsicHeight: Giảm tải cho CPU/GPU.
          return ListView.builder(
            itemCount: _viewModel.items.length,
            itemExtent: 80.0, 
            itemBuilder: (context, index) {
              final item = _viewModel.items[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade50,
                  child: Text('${item.id}', style: const TextStyle(color: Colors.green, fontSize: 10)),
                ),
                title: Text(item.title),
                subtitle: Text("${item.subtitle} - Tối ưu 60 FPS"),
                trailing: const Icon(Icons.bolt, color: Colors.green),
              );
            },
          );
        },
      ),
    );
  }
}
