import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/homestay_viewmodel.dart';
import '../common/profile_page.dart';
import 'host_booking_requests_screen.dart';
import 'homestay_list_screen.dart';

class HostDashboardScreen extends ConsumerStatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  ConsumerState<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends ConsumerState<HostDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(hostHomestayViewModelProvider.notifier).loadMyHomestays();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: _buildBody(),
      floatingActionButton: _currentIndex == 0 ? _buildFAB(context) : null,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return const HostBookingRequestsScreen(isTab: true);
      case 2:
        return const HomestayListScreen(isTab: true);
      case 3:
        return const ProfilePage();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsGrid(),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Yêu cầu đặt phòng mới', () {
                      setState(() => _currentIndex = 1);
                    }),
                    const SizedBox(height: 12),
                    // Hardcode for now, later fetch from bookings
                    const Text('Chưa có yêu cầu mới.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Homestay của tôi', () {
                      setState(() => _currentIndex = 2);
                    }),
                    const SizedBox(height: 12),
                    _buildMyHomestayList(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    final profile = ref.watch(authViewModelProvider).profile;
    final username = profile?.fullName ?? 'Host';
    final avatarUrl = profile?.avatarUrl;

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF5D3A2E),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B4A35), Color(0xFF5D3A2E), Color(0xFF3D2318)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chào buổi tối, $username 👋',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Host Dashboard',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.push('/notifications'),
                            child: const Icon(Icons.notifications_outlined, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => setState(() => _currentIndex = 3),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                              child: avatarUrl == null ? const Icon(Icons.person) : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildEarningsInline(),
                ],
              ),
            ),
          ),
        ),
      ),
      title: const Text('Host Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
    );
  }

  Widget _buildEarningsInline() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Doanh thu tháng này', style: TextStyle(color: Colors.white70, fontSize: 12)),
              SizedBox(height: 4),
              Text('0 đ', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final state = ref.watch(hostHomestayViewModelProvider);
    return Row(
      children: [
        _buildStatCard('Tổng số nhà', '${state.homestays.length}', Icons.home_work, Colors.blue),
        const SizedBox(width: 16),
        _buildStatCard('Đánh giá', '0.0', Icons.star, Colors.amber),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(onPressed: onSeeAll, child: const Text('Xem tất cả')),
      ],
    );
  }

  Widget _buildMyHomestayList(BuildContext context) {
    final state = ref.watch(hostHomestayViewModelProvider);
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.homestays.isEmpty) return const Text('Bạn chưa có homestay nào.');

    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.homestays.take(3).length,
      itemBuilder: (context, index) {
        final homestay = state.homestays[index];
        final imageUrl = homestay.images.isNotEmpty ? homestay.images[0] : 'https://placehold.co/400';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
            title: Text(homestay.name),
            subtitle: Text(formatCurrency.format(homestay.pricePerNight)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              context.push('/homestay-detail', extra: homestay);
            },
          ),
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/add-homestay-basic-info'),
      backgroundColor: const Color(0xFFE07A5F),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Đăng tin mới', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFE07A5F),
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Yêu cầu'),
        BottomNavigationBarItem(icon: Icon(Icons.home_work), label: 'Nhà của tôi'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
      ],
    );
  }
}