import 'package:flutter/material.dart';
import '../models/item_model.dart';

class ItemViewModel extends ChangeNotifier {
  List<ItemModel> _items = [];
  bool _isLoading = false;
  int _lastExecutionTime = 0;

  List<ItemModel> get items => _items;
  bool get isLoading => _isLoading;
  int get lastExecutionTime => _lastExecutionTime;

  void fetchItems(int count) async {
    _isLoading = true;
    _items = []; // Xóa danh sách cũ
    notifyListeners();

    // Để UI có thời gian hiện loading
    await Future.delayed(const Duration(milliseconds: 100));

    final stopwatch = Stopwatch()..start();
    
    // Giả lập tạo dữ liệu
    _items = List.generate(
      count,
      (i) => ItemModel(
        id: i,
        title: "Sản phẩm thứ $i",
        subtitle: "Demo so sánh hiệu suất MVVM",
      ),
    );

    stopwatch.stop();
    _lastExecutionTime = stopwatch.elapsedMilliseconds;
    
    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _items = [];
    _lastExecutionTime = 0;
    notifyListeners();
  }
}
