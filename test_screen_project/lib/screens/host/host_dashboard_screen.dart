import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/api_service.dart';
import '../../models/homestay_model.dart';

// Màn hình bảng điều khiển chính dành cho luồng giao diện Chủ nhà (Host Dashboard)
class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 4 tab tương ứng cho Host: Bảng điều khiển, Yêu cầu đặt phòng, Nhà của tôi, Hồ sơ
    final List<Widget> tabs = [
      _buildDashboardTab(),
      _buildBookingRequestsTab(),
      _buildMyHomestaysTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Surface color từ design system
      body: SafeArea(
        child: Stack(
          children: [
            tabs[_currentIndex],
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
                ),
              ),
          ],
        ),
      ),
      // Nút nổi thêm homestay mới (được hiển thị trên Tab 0 và Tab 2)
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 2)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/add-homestay-basic-info').then((_) {
                  setState(() {});
                });
              },
              backgroundColor: const Color(0xFFE07A5F),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Đăng tin mới',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- 1. TAB BẢNG ĐIỀU KHIỂN (DASHBOARD TAB) ---
  Widget _buildDashboardTab() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _apiService.getHostBookingRequests(),
        _apiService.getMyHomestays(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE07A5F)));
        }

        final bookings = snapshot.data?[0] as List<dynamic>? ?? [];
        final homestays = snapshot.data?[1] as List<Homestay>? ?? [];

        // Tính toán doanh thu thật từ các booking đã xác nhận (status == 'confirmed')
        double monthlyEarnings = 0.0;
        int completedBookings = 0;
        for (var booking in bookings) {
          if (booking['status'] == 'confirmed') {
            monthlyEarnings += (booking['total_price'] ?? 0.0).toDouble();
            completedBookings++;
          }
        }

        final String formattedEarnings = monthlyEarnings.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          color: const Color(0xFFE07A5F),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader('Host Dashboard'),
                const SizedBox(height: 16),
                _buildEarningsCard(formattedEarnings),
                const SizedBox(height: 24),
                _buildStatsGrid(completedBookings, homestays.length),
                const SizedBox(height: 32),
                _buildSectionHeader('Yêu cầu đặt phòng mới nhất', () => _onTabTapped(1)),
                const SizedBox(height: 12),
                bookings.isEmpty
                    ? _buildEmptyState('Chưa có yêu cầu đặt phòng nào.')
                    : _buildBookingRequestItem(bookings.first),
                const SizedBox(height: 32),
                _buildSectionHeader('Homestay của tôi', () => _onTabTapped(2)),
                const SizedBox(height: 12),
                homestays.isEmpty
                    ? _buildEmptyState('Chưa đăng tin homestay nào.')
                    : _buildMyHomestayCard(homestays.first),
                const SizedBox(height: 60),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String title) {
    final user = Supabase.instance.client.auth.currentUser;
    final String email = user?.email ?? 'host@example.com';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'BeVietnamPro',
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Color(0xFF6D4C41)),
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${email.substring(0, 3)}'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningsCard(String earningsStr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF6D4C41),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4C41).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng thu nhập đã xác nhận',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${earningsStr}đ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, color: Colors.greenAccent, size: 16),
                SizedBox(width: 4),
                Text(
                  '+15% so với tháng trước',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int confirmedBookings, int homestaysCount) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _statItem('Số homestay', '$homestaysCount', Icons.home_work_outlined),
        _statItem('Đơn đã duyệt', '$confirmedBookings', Icons.check_circle_outline),
        _statItem('Đánh giá', '4.8 ★', Icons.star_outline),
        _statItem('Phản hồi', '100%', Icons.chat_bubble_outline),
      ],
    );
  }

  Widget _statItem(String label, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFE07A5F), size: 22),
          const SizedBox(height: 8),
          Text(
            val,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text(
            'Xem tất cả',
            style: TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ),
    );
  }

  // Khối vẽ Item yêu cầu đặt phòng (booking)
  Widget _buildBookingRequestItem(Map<String, dynamic> booking) {
    final profile = booking['profiles'];
    final homestay = booking['homestays'];
    final String clientName = profile?['full_name'] ?? 'Khách hàng ẩn danh';
    final String homestayName = homestay?['name'] ?? 'Homestay';
    
    final checkIn = DateTime.parse(booking['check_in']);
    final checkOut = DateTime.parse(booking['check_out']);
    final int nights = checkOut.difference(checkIn).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: profile?['avatar_url'] != null
                    ? NetworkImage(profile['avatar_url'])
                    : const NetworkImage('https://i.pravatar.cc/150?u=client'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '$nights đêm • $homestayName',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: booking['status'] == 'confirmed'
                      ? Colors.green.shade50
                      : (booking['status'] == 'cancelled' ? Colors.red.shade50 : Colors.orange.shade50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking['status'] == 'confirmed' ? 'Đã duyệt' : (booking['status'] == 'cancelled' ? 'Đã hủy' : 'Đang xử lý'),
                  style: TextStyle(
                    color: booking['status'] == 'confirmed' ? Colors.green : (booking['status'] == 'cancelled' ? Colors.red : Colors.orange),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (booking['status'] == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _updateStatus(booking['id'], 'cancelled'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Từ chối', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _updateStatus(booking['id'], 'confirmed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Phê duyệt', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _updateStatus(int bookingId, String status) async {
    setState(() => _isLoading = true);
    try {
      await _apiService.updateBookingStatus(bookingId, status);
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildMyHomestayCard(Homestay homestay) {
    final String imageUrl = homestay.images.isNotEmpty 
        ? homestay.images.first 
        : 'https://images.unsplash.com/photo-1510798831971-661eb04b3739?q=80&w=1000';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(
              imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      homestay.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.green, size: 8),
                        const SizedBox(width: 6),
                        Text(
                          homestay.status == 'active' ? 'Đang hoạt động' : 'Tạm ẩn',
                          style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${homestay.pricePerNight.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ/đêm',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE07A5F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. TAB YÊU CẦU ĐẶT PHÒNG (BOOKINGS TAB) ---
  Widget _buildBookingRequestsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _apiService.getHostBookingRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE07A5F)));
        }

        final bookings = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFFDFAE7),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Yêu cầu đặt phòng',
              style: TextStyle(color: Color(0xFF6D4C41), fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            color: const Color(0xFFE07A5F),
            child: bookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa nhận được yêu cầu nào.',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: bookings.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildBookingRequestItem(bookings[index]);
                    },
                  ),
          ),
        );
      },
    );
  }

  // --- 3. TAB NHÀ CỦA TÔI (MY HOMESTAYS TAB) ---
  Widget _buildMyHomestaysTab() {
    return FutureBuilder<List<Homestay>>(
      future: _apiService.getMyHomestays(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE07A5F)));
        }

        final homestays = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFFDFAE7),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Homestay của tôi',
              style: TextStyle(color: Color(0xFF6D4C41), fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            color: const Color(0xFFE07A5F),
            child: homestays.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_work_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          'Bạn chưa đăng tin homestay nào.',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: homestays.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildMyHomestayCard(homestays[index]),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  // --- 4. TAB HỒ SƠ & MENU (PROFILE TAB) ---
  Widget _buildProfileTab() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _apiService.getMyProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE07A5F)));
        }

        final profile = snapshot.data;
        final currentUser = Supabase.instance.client.auth.currentUser;
        
        final String rawName = profile?['full_name'] ?? '';
        final String fullName = rawName.isEmpty ? (currentUser?.email?.split('@').first ?? 'Người dùng') : rawName;
        
        final String rawEmail = profile?['email'] ?? '';
        final String email = rawEmail.isEmpty ? (currentUser?.email ?? 'Chưa cập nhật email') : rawEmail;
        
        final String rawPhone = profile?['phone'] ?? '';
        final String phone = rawPhone.isEmpty ? 'Chưa cập nhật SĐT' : rawPhone;
        
        final String? avatarUrl = profile?['avatar_url'];

        return Scaffold(
          backgroundColor: const Color(0xFFFDFAE7),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Menu & Hồ sơ',
              style: TextStyle(color: Color(0xFF6D4C41), fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : const NetworkImage('https://i.pravatar.cc/150?u=host'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fullName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
                      ),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE07A5F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, color: Color(0xFFE07A5F), size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'Chủ nhà',
                              style: TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildContactRow(Icons.phone_iphone, 'Số điện thoại', phone),
                      const Divider(height: 24),
                      _buildContactRow(Icons.email_outlined, 'Email liên hệ', email),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                  icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                  label: const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D4C41),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactRow(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6D4C41), size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 2),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF424242))),
          ],
        ),
      ],
    );
  }

  // --- BOTOMNAVBAR DÀNH CHO HOST ---
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFE07A5F),
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Yêu cầu duyệt'),
        BottomNavigationBarItem(icon: Icon(Icons.home_work_outlined), activeIcon: Icon(Icons.home_work), label: 'Nhà của tôi'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
      ],
    );
  }
}