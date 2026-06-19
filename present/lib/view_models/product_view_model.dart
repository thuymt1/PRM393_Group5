import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductViewModel extends ChangeNotifier {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  int _lastProcessingTime = 0;

  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  int get lastProcessingTime => _lastProcessingTime;

  void loadProducts() async {
    _isLoading = true;
    notifyListeners();

    final stopwatch = Stopwatch()..start();
    // Giả lập load 5000 sản phẩm
    await Future.delayed(const Duration(milliseconds: 500)); 
    _allProducts = List.generate(
      5000,
      (i) => Product(id: '$i', name: 'Sản phẩm $i', price: (i + 1) * 10.0),
    );
    _filteredProducts = _allProducts;
    _lastProcessingTime = stopwatch.elapsedMicroseconds;

    _isLoading = false;
    notifyListeners();
  }

  void filterProducts(String query) {
    final stopwatch = Stopwatch()..start();
    
    if (query.isEmpty) {
      _filteredProducts = _allProducts;
    } else {
      _filteredProducts = _allProducts
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    
    _lastProcessingTime = stopwatch.elapsedMicroseconds;
    debugPrint('⚙️ ViewModel: Lọc xong trong ${_lastProcessingTime / 1000} ms');
    notifyListeners(); 
  }
}
