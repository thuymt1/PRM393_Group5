import 'package:flutter/material.dart';

import '../../models/homestay_model.dart';
import '../../services/api_service.dart';

class HostHomestayDetailScreen extends StatefulWidget {
  const HostHomestayDetailScreen({super.key});

  @override
  State<HostHomestayDetailScreen> createState() => _HostHomestayDetailScreenState();
}

class _HostHomestayDetailScreenState extends State<HostHomestayDetailScreen> {
  final ApiService _apiService = ApiService();
  late Homestay _homestay;
  bool _initialized = false;
  bool _changed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _homestay = ModalRoute.of(context)!.settings.arguments as Homestay;
      _initialized = true;
    }
  }

  Future<void> _editHomestay() async {
    final name = TextEditingController(text: _homestay.name);
    final description = TextEditingController(text: _homestay.description);
    final address = TextEditingController(text: _homestay.address);
    final city = TextEditingController(text: _homestay.city);
    final price = TextEditingController(text: _homestay.pricePerNight.toInt().toString());
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chỉnh sửa thông tin'),
        content: SizedBox(
          width: 520,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(name, 'Tên homestay'),
                  _field(description, 'Mô tả', maxLines: 4),
                  _field(address, 'Địa chỉ'),
                  _field(city, 'Thành phố'),
                  _field(price, 'Giá mỗi đêm', number: true),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true);
            },
            child: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
    if (saved != true || !mounted) return;

    try {
      final newPrice = double.parse(price.text.trim());
      await _apiService.updateHomestay(_homestay.id, {
        'name': name.text.trim(),
        'description': description.text.trim(),
        'address': address.text.trim(),
        'city': city.text.trim(),
        'price_per_night': newPrice,
      });
      setState(() {
        _homestay = Homestay(
          id: _homestay.id,
          name: name.text.trim(),
          description: description.text.trim(),
          address: address.text.trim(),
          city: city.text.trim(),
          pricePerNight: newPrice,
          rating: _homestay.rating,
          images: _homestay.images,
          category: _homestay.category,
          status: _homestay.status,
          hostId: _homestay.hostId,
          hostName: _homestay.hostName,
          hostAvatar: _homestay.hostAvatar,
        );
        _changed = true;
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật thông tin homestay')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể cập nhật: $e')));
    }
  }

  Widget _field(TextEditingController controller, String label, {int maxLines = 1, bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Vui lòng nhập $label';
          if (number && (double.tryParse(value.trim()) == null || double.parse(value.trim()) < 0)) return 'Giá không hợp lệ';
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _homestay.images.isNotEmpty ? _homestay.images.first : null;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFAE7),
        appBar: AppBar(
          title: const Text('Thông tin nhà'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF6D4C41),
          actions: [IconButton(onPressed: _editHomestay, icon: const Icon(Icons.edit_outlined), tooltip: 'Chỉnh sửa thông tin')],
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            if (imageUrl != null) Image.network(imageUrl, height: 260, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_homestay.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41))),
                  const SizedBox(height: 10),
                  Text('${_homestay.pricePerNight.toInt()}đ / đêm', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE07A5F))),
                  const SizedBox(height: 18),
                  _info(Icons.location_on_outlined, '${_homestay.address}, ${_homestay.city}'),
                  if (_homestay.category.isNotEmpty) _info(Icons.home_work_outlined, _homestay.category),
                  _info(Icons.circle, _homestay.status == 'active' ? 'Đang hoạt động' : 'Tạm ẩn'),
                  const SizedBox(height: 20),
                  const Text('Mô tả', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_homestay.description.isEmpty ? 'Chưa có mô tả.' : _homestay.description, style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 24),
                  FutureBuilder<List<dynamic>>(
                    future: _apiService.getHomestayReviews(_homestay.id),
                    builder: (context, snapshot) {
                      final reviews = snapshot.data ?? [];
                      final avg = reviews.isEmpty ? _homestay.rating : reviews.map((r) => (r['rating'] as num?)?.toDouble() ?? 0).reduce((a, b) => a + b) / reviews.length;
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [const Text('Đánh giá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(width: 10), Text(avg.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 4), ...List.generate(5, (i) => Icon(i < avg.round() ? Icons.star : Icons.star_border, size: 19, color: Colors.amber))]),
                        const SizedBox(height: 12),
                        if (snapshot.connectionState == ConnectionState.waiting) const Center(child: CircularProgressIndicator()) else if (reviews.isEmpty) const Text('Chưa có đánh giá nào.', style: TextStyle(color: Colors.grey)) else ...reviews.map((r) {
                          final profile = r['profiles'];
                          return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(profile?['full_name'] ?? 'Khách hàng', style: const TextStyle(fontWeight: FontWeight.bold)), Row(children: List.generate(5, (i) => Icon(i < ((r['rating'] as num?)?.toInt() ?? 0) ? Icons.star : Icons.star_border, size: 16, color: Colors.amber))), const SizedBox(height: 4), Text(r['comment'] ?? '', style: const TextStyle(color: Colors.grey))]));
                        }),
                      ]);
                    },
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _editHomestay,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Chỉnh sửa thông tin'),
                    style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: const Color(0xFF6D4C41)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _deleteHomestay,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Xóa homestay', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52), side: const BorderSide(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [Icon(icon, size: 19, color: const Color(0xFFE07A5F)), const SizedBox(width: 10), Expanded(child: Text(text))]),
      );

  Future<void> _deleteHomestay() async {
    final confirmed = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Xóa homestay?'), content: const Text('Thao tác này không thể hoàn tác.'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xóa'))]));
    if (confirmed != true) return;
    await _apiService.deleteHomestay(_homestay.id);
    if (mounted) Navigator.pop(context, true);
  }
}
