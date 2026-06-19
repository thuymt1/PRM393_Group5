import 'package:flutter/material.dart';

class BeforeOptimizationPage extends StatefulWidget {
  const BeforeOptimizationPage({super.key});

  @override
  State<BeforeOptimizationPage> createState() => _BeforeOptimizationPageState();
}

class _BeforeOptimizationPageState extends State<BeforeOptimizationPage> {
  int _counter = 0;

  // Giả lập logic nặng: Sắp xếp danh sách 1000 item mỗi khi build
  List<String> _processData() {
    debugPrint('🔴 Đang chạy LOGIC NẶNG (Sorting) trong hàm build()...');
    return List.generate(1000, (index) => 'Item $index')
        .reversed // Đảo ngược danh sách (tốn CPU)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('⚠️ CẢ MÀN HÌNH ĐANG REBUILD (Toàn bộ Scaffold)');
    final items = _processData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chưa tối ưu (Before)'),
        backgroundColor: Colors.red.shade100,
      ),
      body: Column(
        children: [
          // 1. Không dùng const: Widget này bị build lại vô ích
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Vấn đề: Không dùng const, logic nặng nằm trong build(), State quản lý quá rộng.',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
          
          // 2. State nằm ở root: Khi _counter đổi, cả Column/ListView rebuild
          Text('Số lần bấm: $_counter', style: const TextStyle(fontSize: 30)),

          Expanded(
            child: ListView.builder(
              itemCount: 20, 
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: Text(items[index]),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => setState(() => _counter++),
        child: const Icon(Icons.add),
      ),
    );
  }
}
