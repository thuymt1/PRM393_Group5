import 'package:flutter/material.dart';

class ProductListViewBad extends StatefulWidget {
  const ProductListViewBad({super.key});

  @override
  State<ProductListViewBad> createState() => _ProductListViewBadState();
}

class _ProductListViewBadState extends State<ProductListViewBad> {
  String _searchQuery = "";
  int _tapCount = 0;
  int _rebuildCount = 0;
  double _lastLogicTime = 0;

  @override
  Widget build(BuildContext context) {
    _rebuildCount++;
    final stopwatch = Stopwatch()..start();

    // LỖI: Logic tạo data và filter nằm ngay trong Build()
    final allProducts = List.generate(5000, (i) => 'Sản phẩm $i');
    final filtered = allProducts.where((p) => p.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    _lastLogicTime = stopwatch.elapsedMicroseconds / 1000;
    debugPrint('⚠️ REBUILD: Bad Page - Lần: $_rebuildCount - Logic: $_lastLogicTime ms');

    return Scaffold(
      appBar: AppBar(
        title: Text('BAD (Build: $_rebuildCount)'),
        backgroundColor: Colors.red.shade100,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Text('Logic build mất: ${_lastLogicTime.toStringAsFixed(3)} ms', 
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm sản phẩm...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          
          Container(
            color: Colors.amber.shade50,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Tương tác: $_tapCount', style: const TextStyle(fontSize: 18)),
                ElevatedButton(
                  onPressed: () => setState(() => _tapCount++), 
                  child: const Text('Tăng số'),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filtered.length > 100 ? 100 : filtered.length,
              itemBuilder: (context, index) {
                // LỖI: Widget con không được tách ra, gây khó quản lý
                return ListTile(
                  leading: const Icon(Icons.shopping_bag, color: Colors.red),
                  title: Text(filtered[index]),
                  subtitle: const Text('Giá: 100.000đ'),
                  trailing: const Icon(Icons.arrow_forward),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
