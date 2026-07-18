import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/homestay_model.dart';
import '../models/host_application_model.dart';

class ApiService {
  final _supabase = Supabase.instance.client;

  // --- HỆ THỐNG XÁC THỰC & PROFILE ---

  // 1. Đăng nhập
  Future<AuthResponse> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null || response.session == null) {
      throw const AuthException(
        'Tài khoản không tồn tại hoặc mật khẩu không đúng',
      );
    }
    if (user.emailConfirmedAt == null) {
      await _supabase.auth.signOut();
      throw const AuthException('Email chưa được xác minh');
    }
    return response;
  }

  // Đăng nhập bằng Google
  Future<void> signInWithGoogle() async {
    String redirectTo = 'io.supabase.test_screen_project://login-callback';
    if (kIsWeb) {
      redirectTo = Uri.base.origin;
    }

    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
    );
  }

  // 2. Đăng ký tài khoản
  Future<AuthResponse> register(String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Xác minh mã OTP Supabase gửi về email khi đăng ký.
  Future<AuthResponse> verifyRegistrationOtp(String email, String token) async {
    return await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  // Gửi lại mã xác minh đăng ký.
  Future<void> resendRegistrationOtp(String email) async {
    await _supabase.auth.resend(type: OtpType.signup, email: email);
  }

  // 3. Tạo Profile mới sau khi đăng ký
  Future<void> createProfile({
    required String id,
    required String email,
    required String fullName,
    required String phone,
  }) async {
    // Có thể Auth user đã tồn tại nhưng profile đã bị xóa thủ công. Upsert giúp
    // việc hoàn tất OTP/khôi phục tài khoản tạo lại profile một cách an toàn.
    await _supabase.from('profiles').upsert({
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'created_at': DateTime.now().toIso8601String(),
    }, onConflict: 'id');
  }

  // 4. Lấy Profile của tôi
  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    return await getProfileById(user.id);
  }

  // Lấy Profile theo ID
  Future<Map<String, dynamic>?> getProfileById(String id) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  // 5. Cập nhật Vai trò người dùng (Customer, Host, Author)
  Future<void> updateProfileRole(String role) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    final fullName = user.userMetadata?['full_name'] ?? 'Người dùng mới';
    final avatarUrl = user.userMetadata?['avatar_url'] ?? '';

    try {
      // Cố gắng tạo mới (Dành cho người đăng nhập qua Google/MagicLink chưa có profile)
      await _supabase.from('profiles').insert({
        'id': user.id,
        'email': user.email ?? '',
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'phone': '',
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      // 23505: Duplicate key -> Có nghĩa là profile ĐÃ TỒN TẠI (do RegisterScreen tạo)
      if (e.code == '23505') {
        // Chuyển sang chế độ cập nhật
        final res = await _supabase
            .from('profiles')
            .update({'role': role})
            .eq('id', user.id)
            .select();

        if (res.isEmpty) {
          throw Exception(
            'Không thể cập nhật vai trò do bị chặn bởi RLS. Vui lòng cấp quyền UPDATE cho bảng profiles.',
          );
        }
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- PHÂN HỆ HOMESTAY & TIỆN ÍCH ---

  // 6. Lấy danh sách Homestay đang hoạt động kèm theo Ảnh và Category (có phân trang & tìm kiếm)
  Future<List<Homestay>> getHomestays({
    int page = 0,
    int pageSize = 10,
    String? searchQuery,
    String? category,
  }) async {
    try {
      var query = _supabase
          .from('homestays')
          .select('''
            *,
            homestay_images(url),
            categories(name),
            reviews(rating)
          ''')
          .eq('status', 'active');

      // Tìm kiếm theo tên, địa chỉ, hoặc thành phố (server-side)
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim()}%';
        query = query.or('name.ilike.$q,address.ilike.$q,city.ilike.$q');
      }

      // Lọc theo category
      if (category != null && category != 'Tất cả') {
        query = query.eq('categories.name', category);
      }

      final from = page * pageSize;
      final to = from + pageSize - 1;

      final response = await query
          .order('id', ascending: false)
          .range(from, to);

      // Filter out results where category join returned null (when filtering by category)
      List<dynamic> results = response as List;
      if (category != null && category != 'Tất cả') {
        results = results.where((json) {
          final cat = json['categories'];
          return cat != null && cat['name'] != null;
        }).toList();
      }

      return results.map((raw) {
        final json = Map<String, dynamic>.from(raw);
        final ratings = (json['reviews'] as List? ?? [])
            .map((r) => (r['rating'] as num).toDouble())
            .toList();
        json['rating'] = ratings.isEmpty
            ? 0.0
            : ratings.reduce((a, b) => a + b) / ratings.length;
        return Homestay.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error fetching homestays: $e');
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
            categories(name),
            reviews(rating)
          ''')
          .eq('host_id', user.id)
          .order('id', ascending: false);

      return (response as List).map((raw) {
        final json = Map<String, dynamic>.from(raw);
        final ratings = (json['reviews'] as List? ?? [])
            .map((r) => (r['rating'] as num).toDouble())
            .toList();
        json['rating'] = ratings.isEmpty
            ? 0.0
            : ratings.reduce((a, b) => a + b) / ratings.length;
        return Homestay.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error fetching my homestays: $e');
      return [];
    }
  }

  Future<void> updateHomestay(int homestayId, Map<String, dynamic> data) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    final response = await _supabase
        .from('homestays')
        .update(data)
        .eq('id', homestayId)
        .eq('host_id', user.id)
        .select('id');
    if ((response as List).isEmpty) {
      throw Exception('Không tìm thấy homestay hoặc bạn không có quyền chỉnh sửa');
    }
  }

  Future<void> deleteHomestay(int homestayId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');
    await _supabase.from('homestays').delete().eq('id', homestayId).eq('host_id', user.id);
  }

  Future<List<dynamic>> getHostReviews() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];
    try {
      return await _supabase.from('reviews').select('''
        *, homestays!inner(name, host_id), profiles(full_name, avatar_url)
      ''').eq('homestays.host_id', user.id).order('created_at', ascending: false);
    } catch (e) {
      print('Error fetching host reviews: $e');
      return [];
    }
  }

  // Hàm upload ảnh lên Supabase Storage (Hỗ trợ cả Web & Mobile)
  Future<String> uploadHomestayImage(
    Uint8List fileBytes,
    String fileName,
  ) async {
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _supabase.storage
        .from('homestays')
        .uploadBinary(
          uniqueName,
          fileBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return _supabase.storage.from('homestays').getPublicUrl(uniqueName);
  }

  // 8. Đăng tin Homestay mới
  Future<void> createHomestay(
    Map<String, dynamic> homestayData,
    String imageUrl,
  ) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    final data = {...homestayData, 'host_id': user.id, 'status': 'active'};

    // Chèn homestay mới
    final response = await _supabase
        .from('homestays')
        .insert(data)
        .select('id')
        .single();

    final int newHomestayId = response['id'];

    // Chèn hình ảnh homestay (ảnh vừa chọn)
    await _supabase.from('homestay_images').insert({
      'homestay_id': newHomestayId,
      'url': imageUrl,
    });
  }

  // 9. Lấy danh sách Categories
  Future<List<dynamic>> getCategories() async {
    try {
      return await _supabase.from('categories').select();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // --- PHÂN HỆ ĐẶT PHÒNG (BOOKINGS) ---

  // Kiểm tra ngày có trống không (chống trùng lịch)
  Future<bool> checkDateAvailability({
    required int homestayId,
    required String checkIn,
    required String checkOut,
  }) async {
    try {
      // Tìm các booking đang hoạt động có ngày trùng lặp (overlap)
      // Overlap condition: existing.check_in < requestedCheckOut AND existing.check_out > requestedCheckIn
      final response = await _supabase
          .from('bookings')
          .select('id')
          .eq('homestay_id', homestayId)
          .not('status', 'in', '(cancelled,rejected,cancel_pending,refunded)')
          .lt('check_in', checkOut)
          .gt('check_out', checkIn);

      return (response as List)
          .isEmpty; // true = available, false = already booked
    } catch (e) {
      print('Error checking availability: $e');
      return false;
    }
  }

  // Lấy danh sách các khoảng thời gian đã được đặt của một homestay
  Future<List<Map<String, String>>> getBookedDateRanges(int homestayId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('check_in, check_out')
          .eq('homestay_id', homestayId)
          .not('status', 'in', '(cancelled,rejected,cancel_pending,refunded)');

      return (response as List)
          .map(
            (json) => {
              'check_in': json['check_in'] as String,
              'check_out': json['check_out'] as String,
            },
          )
          .toList();
    } catch (e) {
      print('Error fetching booked dates: $e');
      return [];
    }
  }

  // 10. Tạo đơn đặt phòng (có kiểm tra trùng lịch)
  Future<void> createBooking({
    required int homestayId,
    required String checkIn,
    required String checkOut,
    required double totalPrice,
    String status = 'pending',
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    // Kiểm tra trùng lịch trước khi tạo đơn
    final isAvailable = await checkDateAvailability(
      homestayId: homestayId,
      checkIn: checkIn,
      checkOut: checkOut,
    );
    if (!isAvailable) {
      throw Exception(
        'Homestay đã có người đặt trong khoảng thời gian này. Vui lòng chọn ngày khác.',
      );
    }

    await _supabase.from('bookings').insert({
      'homestay_id': homestayId,
      'customer_id': user.id,
      'check_in': checkIn,
      'check_out': checkOut,
      'total_price': totalPrice,
      'status': status,
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
              *,
              homestay_images (url),
              categories (name),
              profiles!host_id (full_name, avatar_url),
              reviews (rating)
            )
          ''')
          .eq('customer_id', user.id)
          .order('created_at', ascending: false);
    } catch (e) {
      print('Error fetching bookings: $e');
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

      final homestayIds = (homestayList as List)
          .map((h) => h['id'] as int)
          .toList();
      if (homestayIds.isEmpty) return [];

      // Truy vấn bookings tương ứng
      final bookingsResponse = await _supabase
          .from('bookings')
          .select('''
            *,
            homestays (
              name
            )
          ''')
          .inFilter('homestay_id', homestayIds)
          .order('created_at', ascending: false);

      final bookings = List<Map<String, dynamic>>.from(bookingsResponse);
      await Future.wait(bookings.map((booking) async {
        if (booking['customer_id'] != null) {
          booking['profiles'] = await getProfileById(booking['customer_id']);
        }
      }));
      return bookings;
    } catch (e) {
      print('Error fetching host booking requests: $e');
      return [];
    }
  }

  // 13. Cập nhật trạng thái Booking (Host phê duyệt/Hủy đơn)
  Future<void> updateBookingStatus(int bookingId, String status) async {
    final response = await _supabase
        .from('bookings')
        .update({'status': status})
        .eq('id', bookingId)
        .select();

    if ((response as List).isEmpty) {
      throw Exception(
        'Không có quyền cập nhật hoặc không tìm thấy đơn phòng (Lỗi RLS)',
      );
    }
  }

  /// Lưu yêu cầu huỷ/hoàn tiền kèm lý do và ảnh QR ngân hàng của khách.
  Future<void> submitCancellationRequest({
    required int bookingId,
    required String reason,
    String? qrImageUrl,
  }) async {
    try {
      await _supabase.from('bookings').update({
        'status': 'cancel_pending',
        'cancellation_reason': reason,
        'refund_qr_url': qrImageUrl,
        'cancellation_requested_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);
    } on PostgrestException catch (e) {
      // Cho phép hủy vẫn thành công khi database chưa chạy migration bổ sung cột hoàn tiền.
      if (e.code != 'PGRST204' && !e.message.contains('cancellation_reason')) rethrow;
      await _supabase.from('bookings').update({'status': 'cancel_pending'}).eq('id', bookingId);
    }
  }

  /// Upload ảnh bằng chứng/QR vào bucket riêng. Bucket phải được tạo trong Storage.
  Future<String> uploadUserAttachment(Uint8List bytes, String fileName) async {
    final path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    try {
      await _supabase.storage.from('user-attachments').uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: false));
      return _supabase.storage.from('user-attachments').getPublicUrl(path);
    } catch (_) {
      // Bucket user-attachments có thể chưa được tạo; bucket homestays đã có sẵn trong app.
      final fallbackPath = 'refund_qr/$path';
      await _supabase.storage.from('homestays').uploadBinary(fallbackPath, bytes, fileOptions: const FileOptions(upsert: false));
      return _supabase.storage.from('homestays').getPublicUrl(fallbackPath);
    }
  }

  Future<void> createReview({
    required int bookingId,
    required int homestayId,
    required int rating,
    required String content,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');
    await _supabase.from('reviews').insert({
      'homestay_id': homestayId,
      'customer_id': user.id,
      'rating': rating,
      'comment': content,
    });
  }

  Future<List<dynamic>> getHomestayReviews(int homestayId) async {
    return await _supabase
        .from('reviews')
        .select('*, profiles(full_name, avatar_url)')
        .eq('homestay_id', homestayId)
        .order('created_at', ascending: false);
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
      print('Error fetching articles: $e');
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
      print('Error fetching my articles: $e');
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

  // --- HỆ THỐNG QUÊN MẬT KHẨU & CẬP NHẬT PROFILE ---

  // 17. Gửi email đặt lại mật khẩu (link mở thẳng app qua Deep Link hoặc Web)
  Future<void> sendPasswordResetOtp(String email) async {
    // Supabase tạo recovery OTP. Template Reset Password phải hiển thị
    // {{ .Token }} thay vì chỉ hiển thị {{ .ConfirmationURL }}.
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<AuthResponse> verifyPasswordResetOtp(
    String email,
    String token,
  ) async {
    return _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.recovery,
    );
  }

  Future<void> updatePassword(String password) async {
    await _supabase.auth.updateUser(UserAttributes(password: password));
  }

  // 18. Cập nhật thông tin Profile (tên, số điện thoại, avatar)
  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    final Map<String, dynamic> updates = {};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (updates.isEmpty) return;

    final res = await _supabase
        .from('profiles')
        .update(updates)
        .eq('id', user.id)
        .select();

    if (res.isEmpty) {
      throw Exception(
        'Không thể cập nhật hồ sơ do bị chặn bởi RLS. Vui lòng cấp quyền UPDATE cho bảng profiles.',
      );
    }
  }

  // --- PHÂN HỆ YÊU THÍCH (FAVORITES) ---

  // 19. Lấy danh sách ID các homestay đã lưu vào mục yêu thích
  Future<List<int>> getMyFavoriteHomestayIds() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('favorites')
          .select('homestay_id')
          .eq('user_id', user.id);

      return (response as List).map((item) {
        // Ép kiểu an toàn, tránh lỗi cast String to int
        return int.tryParse(item['homestay_id'].toString()) ?? 0;
      }).toList();
    } catch (e) {
      print('Error fetching favorite homestays: $e');
      return [];
    }
  }

  // 20. Thêm homestay vào mục yêu thích
  Future<void> addFavorite(int homestayId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    try {
      await _supabase.from('favorites').insert({
        'user_id': user.id,
        'homestay_id': homestayId,
      });
    } on PostgrestException catch (e) {
      // 23505: Đã tồn tại trong DB, bỏ qua lỗi này để UI đồng bộ
      if (e.code != '23505') {
        rethrow;
      }
    }
  }

  // 21. Xoá homestay khỏi mục yêu thích
  Future<void> removeFavorite(int homestayId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('homestay_id', homestayId);
  }

  // --- THÔNG BÁO (NOTIFICATIONS) ---

  // 22. Lấy thông báo tự động (Dựa trên booking)
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      // Xác định vai trò của user (Khách hay Chủ)
      final profile = await getMyProfile();
      final String role = profile?['role'] ?? 'customer';

      List<Map<String, dynamic>> notifications = [];

      if (role == 'host') {
        // Lấy danh sách booking đến homestay của tôi
        final bookings = await getHostBookingRequests();
        for (var b in bookings) {
          if (b['status'] == 'pending') {
            notifications.add({
              'title': 'Yêu cầu thanh toán mới',
              'desc':
                  'Khách hàng ${b['profiles']?['full_name'] ?? 'Ẩn danh'} đã báo chuyển khoản đặt phòng tại ${b['homestays']?['name']}. Vui lòng kiểm tra tài khoản và xác nhận.',
              'time': b['created_at'],
              'type': 'payment_pending',
              'is_unread': true,
            });
          } else if (b['status'] == 'confirmed') {
            notifications.add({
              'title': 'Đặt phòng đã xác nhận',
              'desc':
                  'Bạn đã xác nhận đặt phòng cho ${b['profiles']?['full_name'] ?? 'Ẩn danh'} tại ${b['homestays']?['name']}.',
              'time': b['created_at'],
              'type': 'payment_confirmed',
              'is_unread': false,
            });
          }
        }
      } else {
        // Thông báo cho Khách hàng
        final bookings = await getMyBookings();
        for (var b in bookings) {
          if (b['status'] == 'confirmed') {
            notifications.add({
              'title': 'Thanh toán hoàn tất!',
              'desc':
                  'Đơn đặt phòng tại ${b['homestays']?['name'] ?? 'homestay'} đã được chủ nhà xác nhận. Chúc bạn có một chuyến đi vui vẻ!',
              'time': b['created_at'],
              'type': 'payment_confirmed',
              'is_unread': true,
            });
          } else if (b['status'] == 'pending') {
            notifications.add({
              'title': 'Đang chờ chủ nhà xác nhận',
              'desc':
                  'Bạn đã gửi yêu cầu thanh toán cho ${b['homestays']?['name'] ?? 'homestay'}. Vui lòng chờ chủ nhà xác nhận giao dịch.',
              'time': b['created_at'],
              'type': 'payment_pending',
              'is_unread': false,
            });
          } else if (b['status'] == 'rejected') {
            notifications.add({
              'title': 'Đặt phòng thất bại',
              'desc':
                  'Chủ nhà đã từ chối yêu cầu đặt phòng tại ${b['homestays']?['name'] ?? 'homestay'}.',
              'time': b['created_at'],
              'type': 'payment_rejected',
              'is_unread': false,
            });
          }
        }
      }

      // Sắp xếp thông báo mới nhất lên đầu
      notifications.sort((a, b) {
        DateTime timeA = DateTime.parse(a['time']);
        DateTime timeB = DateTime.parse(b['time']);
        return timeB.compareTo(timeA);
      });

      return notifications;
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // --- PHÂN HỆ ĐƠN ĐĂNG KÝ HOST (HOST APPLICATIONS) ---
  // ─────────────────────────────────────────────────────────────────────────

  // 23. Gửi đơn đăng ký làm host
  Future<void> submitHostApplication({
    required String fullName,
    required String phone,
    required String email,
    String? reason,
    String? experience,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    // Kiểm tra đã có đơn pending chưa
    final existing = await _supabase
        .from('host_applications')
        .select('id, status')
        .eq('user_id', user.id)
        .eq('status', 'pending')
        .maybeSingle();

    if (existing != null) {
      throw Exception('Bạn đã có đơn đăng ký đang chờ xét duyệt.');
    }

    await _supabase.from('host_applications').insert({
      'user_id': user.id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'reason': reason,
      'experience': experience,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Cập nhật profile: cập nhật thông tin họ tên, SĐT mới (giữ nguyên role là customer)
    await _supabase
        .from('profiles')
        .update({'full_name': fullName, 'phone': phone})
        .eq('id', user.id);
  }

  // 24. Lấy đơn đăng ký host của tôi (mới nhất)
  Future<HostApplication?> getMyHostApplication() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('host_applications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return HostApplication.fromJson(response);
    } catch (e) {
      print('Error fetching my host application: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // --- PHÂN HỆ QUẢN TRỊ ADMIN ---
  // ─────────────────────────────────────────────────────────────────────────

  // 25. [ADMIN] Lấy tất cả đơn đăng ký host (có thể lọc theo status)
  Future<List<HostApplication>> getHostApplications({String? status}) async {
    try {
      var query = _supabase.from('host_applications').select();

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List)
          .map((json) => HostApplication.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching host applications: $e');
      return [];
    }
  }

  // 26. [ADMIN] Phê duyệt hoặc từ chối đơn đăng ký host
  Future<void> reviewHostApplication({
    required String applicationId,
    required String userId,
    required String status, // 'approved' | 'rejected'
    String? adminNote,
  }) async {
    final admin = _supabase.auth.currentUser;
    if (admin == null) throw Exception('Chưa đăng nhập');

    // Cập nhật trạng thái đơn
    await _supabase
        .from('host_applications')
        .update({
          'status': status,
          'admin_note': adminNote,
          'reviewed_at': DateTime.now().toIso8601String(),
          'reviewed_by': admin.id,
        })
        .eq('id', applicationId);

    // Cập nhật role người dùng tương ứng
    final newRole = status == 'approved' ? 'host' : 'customer';
    await _supabase.from('profiles').update({'role': newRole}).eq('id', userId);
  }

  // 27. [ADMIN] Lấy tất cả người dùng
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // 28. [ADMIN] Lấy tất cả homestay (bao gồm cả inactive)
  Future<List<Map<String, dynamic>>> getAllHomestaysAdmin() async {
    try {
      final response = await _supabase
          .from('homestays')
          .select('''
            *,
            homestay_images(url),
            categories(name),
            profiles!host_id(full_name, email)
          ''')
          .order('id', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching all homestays: $e');
      return [];
    }
  }

  // 29. [ADMIN] Bật/tắt trạng thái homestay
  Future<void> updateHomestayStatus(int homestayId, String status) async {
    await _supabase
        .from('homestays')
        .update({'status': status})
        .eq('id', homestayId);
  }

  // 30. [ADMIN] Lấy thống kê tổng quan Dashboard
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final results = await Future.wait([
        _supabase.from('profiles').select('id').neq('role', 'admin'),
        _supabase.from('homestays').select('id').eq('status', 'active'),
        _supabase.from('homestays').select('id').neq('status', 'active'),
        _supabase.from('bookings').select('id'),
        _supabase
            .from('host_applications')
            .select('id')
            .eq('status', 'pending'),
      ]);

      return {
        'total_users': (results[0] as List).length,
        'active_homestays': (results[1] as List).length,
        'inactive_homestays': (results[2] as List).length,
        'total_bookings': (results[3] as List).length,
        'pending_applications': (results[4] as List).length,
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {
        'total_users': 0,
        'active_homestays': 0,
        'inactive_homestays': 0,
        'total_bookings': 0,
        'pending_applications': 0,
      };
    }
  }

  Future<List<dynamic>> getAllBookingsAdmin() async {
    return await _supabase.from('bookings').select('*, homestays(name)').order('created_at', ascending: false);
  }
}
