import 'package:flutter/material.dart';
import '../../../models/product_model.dart';

class ProductItemWidget extends StatelessWidget {
  final Product product;
  
  // ✅ TỐI ƯU: Sử dụng const constructor để Flutter tái sử dụng instance
  const ProductItemWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    debugPrint('❄️ Rebuild Item: ${product.name}');
    return ListTile(
      leading: const Icon(Icons.shopping_bag, color: Colors.green),
      title: Text(product.name),
      subtitle: Text('Giá: ${product.price}đ'),
      trailing: const Icon(Icons.check_circle_outline, color: Colors.green),
    );
  }
}
