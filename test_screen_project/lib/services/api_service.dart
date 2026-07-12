import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/homestay_model.dart';

class ApiService {
  final _supabase = Supabase.instance.client;

  // --- HỆ THỐNG XÁC THỰC & PROFILE ---

  // 1. Đăng nhập
  Future<AuthResponse> login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // 2. Đăng ký tài khoản
  Future<AuthResponse> register(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  // 3. Tạo Profile mới sau khi đăng ký
  Future<void> createProfile({
    required String id,
    required String email,
    required String fullName,
    required String phone,
  }) async {
    await _supabase.from('profiles').insert({
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // 4. Lấy Profile của tôi
  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return null;
    }
  }

  // 5. Cập nhật Vai trò người dùng (Customer, Host, Author)
  Future<void> updateProfileRole(String role) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    await _supabase.from('profiles').update({
      'role': role,
    }).eq('id', user.id);
  }


  // --- PHÂN HỆ HOMESTAY & TIỆN ÍCH ---

  // 6. Lấy danh sách Homestay đang hoạt động kèm theo Ảnh và Category
  Future<List<Homestay>> getHomestays() async {
    try {
      final response = await _supabase
          .from('homestays')
          .select('''
            *,
            homestay_images(url),
            categories(name)
          ''')
          .eq('status', 'active');
      
      return (response as List).map((json) => Homestay.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching homestays: $e');
      return [];
    }
  }

  // 7. Lấy danh sách Homestay của riêng Chủ nhà
  Future<List<Homestay>> getMyHomestays() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('homestays')
          .select('''
            *,
            homestay_images(url),
            categories(name)
          ''')
          .eq('host_id', user.id);
      
      return (response as List).map((json) => Homestay.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching my homestays: $e');
      return [];
    }
  }

  // 8. Đăng tin Homestay mới
  Future<void> createHomestay(Map<String, dynamic> homestayData, String defaultImageUrl) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    final data = {
      ...homestayData,
      'host_id': user.id,
      'status': 'active',
    };

    // Chèn homestay mới
    final response = await _supabase
        .from('homestays')
        .insert(data)
        .select('id')
        .single();
    
    final int newHomestayId = response['id'];

    // Chèn hình ảnh homestay mặc định
    await _supabase.from('homestay_images').insert({
      'homestay_id': newHomestayId,
      'url': defaultImageUrl,
    });
  }

  // 9. Lấy danh sách Categories
  Future<List<dynamic>> getCategories() async {
    try {
      return await _supabase.from('categories').select();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }


  // --- PHÂN HỆ ĐẶT PHÒNG (BOOKINGS) ---

  // 10. Tạo đơn đặt phòng
  Future<void> createBooking({
    required int homestayId,
    required String checkIn,
    required String checkOut,
    required double totalPrice,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    await _supabase.from('bookings').insert({
      'homestay_id': homestayId,
      'customer_id': user.id,
      'check_in': checkIn,
      'check_out': checkOut,
      'total_price': totalPrice,
      'status': 'confirmed', // Xác nhận đặt chỗ thành công
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // 11. Lấy danh sách chuyến đi của tôi (Khách hàng)
  Future<List<dynamic>> getMyBookings() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      return await _supabase
          .from('bookings')
          .select('''
            *,
            homestays (
              name,
              address,
              city,
              homestay_images (url)
            )
          ''')
          .eq('customer_id', user.id)
          .order('created_at', ascending: false);
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      return [];
    }
  }

  // 12. Lấy danh sách đặt phòng đến homestay của tôi (Chủ nhà)
  Future<List<dynamic>> getHostBookingRequests() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      // Đầu tiên lấy ID của tất cả homestays do chủ nhà này quản lý
      final homestayList = await _supabase
          .from('homestays')
          .select('id')
          .eq('host_id', user.id);
      
      final homestayIds = (homestayList as List).map((h) => h['id'] as int).toList();
      if (homestayIds.isEmpty) return [];

      // Truy vấn bookings tương ứng
      return await _supabase
          .from('bookings')
          .select('''
            *,
            profiles (
              full_name,
              email,
              avatar_url
            ),
            homestays (
              name
            )
          ''')
          .inFilter('homestay_id', homestayIds)
          .order('created_at', ascending: false);
    } catch (e) {
      debugPrint('Error fetching host booking requests: $e');
      return [];
    }
  }

  // 13. Cập nhật trạng thái Booking (Host phê duyệt/Hủy đơn)
  Future<void> updateBookingStatus(int bookingId, String status) async {
    await _supabase
        .from('bookings')
        .update({'status': status})
        .eq('id', bookingId);
  }


  // --- PHÂN HỆ REVIEW & BÀI VIẾT (ARTICLES) ---

  // 14. Lấy danh sách Bài viết
  Future<List<dynamic>> getArticles() async {
    try {
      return await _supabase
          .from('articles')
          .select()
          .order('created_at', ascending: false);
    } catch (e) {
      debugPrint('Error fetching articles: $e');
      return [];
    }
  }

  // 15. Lấy danh sách Bài viết của riêng tác giả hiện tại
  Future<List<dynamic>> getMyArticles() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      return await _supabase
          .from('articles')
          .select()
          .eq('author_id', user.id)
          .order('created_at', ascending: false);
    } catch (e) {
      debugPrint('Error fetching my articles: $e');
      return [];
    }
  }

  // 16. Viết bài viết mới
  Future<void> createArticle(String title, String content) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    await _supabase.from('articles').insert({
      'title': title,
      'content': content,
      'author_id': user.id,
      'status': 'published',
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
