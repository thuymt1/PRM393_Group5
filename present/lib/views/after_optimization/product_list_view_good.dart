import 'package:flutter/material.dart';
import '../../view_models/product_view_model.dart';
import 'widgets/product_item_widget.dart';
import 'widgets/search_bar_widget.dart';

class ProductListViewGood extends StatefulWidget {
  const ProductListViewGood({super.key});

  @override
  State<ProductListViewGood> createState() => _ProductListViewGoodState();
}

class _ProductListViewGoodState extends State<ProductListViewGood> {
  final ProductViewModel _viewModel = ProductViewModel();
  int _mainRebuildCount = 0;

  @override
  void initState() {
    super.initState();
    _viewModel.loadProducts(); // Load data 1 lần duy nhất khi khởi tạo
  }

  @override
  Widget build(BuildContext context) {
    _mainRebuildCount++;
    debugPrint('🟢 REBUILD: Chỉ khung màn hình (Good Page) - Lần: $_mainRebuildCount');

    return Scaffold(
      appBar: AppBar(
        title: Text('GOOD (Build: $_mainRebuildCount)'),
        backgroundColor: Colors.green.shade100,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) => Text(
              'Logic xử lý mất: ${(_viewModel.lastProcessingTime / 1000).toStringAsFixed(3)} ms',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // ✅ TỐI ƯU 1: Tách Widget riêng, không bị rebuild khi các phần khác thay đổi
              SearchBarWidget(onChanged: _viewModel.filterProducts),

              const Divider(),

              // ✅ TỐI ƯU 2: Sử dụng bộ đếm cục bộ nếu cần, ở đây giả sử ta dùng 1 widget nhỏ
              const LocalCounterWidget(),

              Expanded(
                child: ListView.builder(
                  itemCount: _viewModel.products.length > 100 ? 100 : _viewModel.products.length,
                  itemBuilder: (context, index) {
                    // ✅ TỐI ƯU 3: Truyền data sạch vào widget con có 'const'
                    return ProductItemWidget(product: _viewModel.products[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LocalCounterWidget extends StatefulWidget {
  const LocalCounterWidget({super.key});

  @override
  State<LocalCounterWidget> createState() => _LocalCounterWidgetState();
}

class _LocalCounterWidgetState extends State<LocalCounterWidget> {
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    debugPrint('⚡ Rebuild bộ đếm cục bộ');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Tương tác: $_count ', style: const TextStyle(fontSize: 16)),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green),
          onPressed: () => setState(() => _count++),
        ),
      ],
    );
  }
}
