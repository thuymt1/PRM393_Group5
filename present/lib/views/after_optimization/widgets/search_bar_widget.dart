import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String) onChanged;

  const SearchBarWidget({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 Rebuild SearchBar');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          labelText: 'Tìm kiếm sản phẩm (Tối ưu)...',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search, color: Colors.green),
        ),
      ),
    );
  }
}
