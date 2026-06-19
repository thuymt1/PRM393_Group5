import 'package:flutter/material.dart';

class AfterOptimizationPage extends StatefulWidget {
  const AfterOptimizationPage({super.key});

  @override
  State<AfterOptimizationPage> createState() => _AfterOptimizationPageState();
}

class _AfterOptimizationPageState extends State<AfterOptimizationPage> {
  late List<String> _cachedItems;

  @override
  void initState() {
    super.initState();
    // ✅ TỐI ƯU 1: Chạy logic nặng 1 lần duy nhất ở initState
    _cachedItems = _processData();
  }

  List<String> _processData() {
    debugPrint('⚙️ Logic nặng chỉ chạy 1 lần lúc khởi tạo');
    return List.generate(1000, (index) => 'Item $index').reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🟢 CHỈ MÀN HÌNH CHÍNH BUILD (Lần đầu)');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đã tối ưu (After)'),
        backgroundColor: Colors.green.shade100,
      ),
      body: Column(
        children: [
          // ✅ TỐI ƯU 2: Sử dụng 'const' triệt để
          const StaticHeaderWidget(),

          // ✅ TỐI ƯU 3: Tách phần thay đổi State thành Widget riêng
          const OptimizedCounterSection(),

          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: Text(_cachedItems[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StaticHeaderWidget extends StatelessWidget {
  const StaticHeaderWidget({super.key});
  @override
  Widget build(BuildContext context) {
    debugPrint('❄️ Header (const) không bao giờ rebuild');
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Giải pháp: Dùng const, tách nhỏ widget, đưa logic ra khỏi build().',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
      ),
    );
  }
}

class OptimizedCounterSection extends StatefulWidget {
  const OptimizedCounterSection({super.key});
  @override
  State<OptimizedCounterSection> createState() => _OptimizedCounterSectionState();
}

class _OptimizedCounterSectionState extends State<OptimizedCounterSection> {
  int _counter = 0;
  @override
  Widget build(BuildContext context) {
    debugPrint('⚡ CHỈ VÙNG NÀY REBUILD');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.green.shade50,
      child: Column(
        children: [
          Text('Số lần bấm: $_counter', style: const TextStyle(fontSize: 30)),
          ElevatedButton.icon(
            onPressed: () => setState(() => _counter++),
            icon: const Icon(Icons.add),
            label: const Text('Tăng số (Chỉ rebuild ở đây)'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
