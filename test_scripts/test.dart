import '../lib/models/homestay_model.dart';

void main() {
  final data = {
    'id': 1,
    'price_per_night': 100.0,
    'rating': 4.5,
    'host_id': 'abc',
    'status': 'active'
  };
  try {
    final h = Homestay.fromJson(data);
    print('SUCCESS: \${h.hostName}');
  } catch (e, stack) {
    print('ERROR: \$e');
    print(stack);
  }
}
