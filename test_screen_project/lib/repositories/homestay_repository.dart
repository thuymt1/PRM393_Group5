import '../models/homestay_model.dart';
import '../core/network/api_client.dart';

/// Repository cho Homestay — goi Spring Boot Backend
class HomestayRepository {
  final _api = ApiClient();

  /// Lay danh sach homestay active (co the tim kiem)
  Future<List<Homestay>> getHomestays({String? search}) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;

    final List<dynamic> json = await _api.get('/homestays', queryParams: params);
    return json.map((e) => Homestay.fromJson(e)).toList();
  }

  /// Lay homestay cua Host dang dang nhap
  Future<List<Homestay>> getMyHomestays() async {
    final List<dynamic> json = await _api.get('/homestays/mine');
    return json.map((e) => Homestay.fromJson(e)).toList();
  }

  /// Tao homestay moi (Host)
  Future<Homestay> createHomestay(Map<String, dynamic> data, String? imageUrl) async {
    final body = {...data, if (imageUrl != null) 'image_url': imageUrl};
    final json = await _api.post('/homestays', body);
    return Homestay.fromJson(json);
  }

  /// Lay danh sach categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final List<dynamic> json = await _api.get('/categories');
    return json.cast<Map<String, dynamic>>();
  }
}
