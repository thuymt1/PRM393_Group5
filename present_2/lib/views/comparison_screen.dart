import 'package:flutter/material.dart';
import '../viewmodels/item_viewmodel.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final ItemViewModel _viewModel = ItemViewModel();
  bool _isOptimized = true;
  String _renderStatus = "Chưa bắt đầu";

  void _runDemo() {
    _viewModel.clear();
    // Để thấy lag ở bản Unoptimized, ta dùng 2000 items
    int count = _isOptimized ? 10000 : 2000; 
    
    _viewModel.fetchItems(count);
    setState(() {
      _renderStatus = "Đang render ${_isOptimized ? '10,000' : '2,000'} items...";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('So sánh Hiệu suất'),
        backgroundColor: _isOptimized ? Colors.green.shade100 : Colors.red.shade100,
      ),
      body: Column(
        children: [
          _buildControlPanel(),
          Expanded(
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, child) {
                if (_viewModel.isLoading) return const Center(child: CircularProgressIndicator());
                if (_viewModel.items.isEmpty) return Center(child: Text(_renderStatus));

                return _isOptimized ? _buildOptimizedList() : _buildUnoptimizedList();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade200,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text("Chế độ:"),
              ChoiceChip(
                label: const Text("CHƯA TỐI ƯU"),
                selected: !_isOptimized,
                onSelected: (val) => setState(() { 
                  _isOptimized = false; 
                  _viewModel.clear(); 
                  _renderStatus = "Chuyển sang Chế độ Chưa tối ưu";
                }),
                selectedColor: Colors.red.shade200,
              ),
              ChoiceChip(
                label: const Text("ĐÃ TỐI ƯU"),
                selected: _isOptimized,
                onSelected: (val) => setState(() { 
                  _isOptimized = true; 
                  _viewModel.clear(); 
                  _renderStatus = "Chuyển sang Chế độ Đã tối ưu";
                }),
                selectedColor: Colors.green.shade200,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _runDemo,
            child: Text("Bắt đầu Demo (${_isOptimized ? '10,000 items' : '2,000 items'})"),
          ),
          if (_viewModel.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Thời gian xử lý Logic: ${_viewModel.lastExecutionTime}ms",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  // 1. CÁCH CHƯA TỐI ƯU
  Widget _buildUnoptimizedList() {
    return ListView(
      children: _viewModel.items.map((item) {
        return IntrinsicHeight(
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Text(item.title),
            subtitle: Text(item.subtitle),
            tileColor: Colors.red.withAlpha(12), // Thay thế withOpacity để tránh warning
          ),
        );
      }).toList(),
    );
  }

  // 2. CÁCH ĐÃ TỐI ƯU
  Widget _buildOptimizedList() {
    return ListView.builder(
      itemCount: _viewModel.items.length,
      itemExtent: 70.0,
      itemBuilder: (context, index) {
        final item = _viewModel.items[index];
        return ListTile(
          leading: const Icon(Icons.bolt, color: Colors.green),
          title: Text(item.title),
          subtitle: Text(item.subtitle),
        );
      },
    );
  }
}
