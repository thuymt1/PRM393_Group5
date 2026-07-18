import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/repository_providers.dart';
import '../../features/common/viewmodels/profile_view_model.dart';
import 'edit_profile_screen.dart';

/// Màn hình Hồ sơ cá nhân – tải dữ liệu thực từ Supabase và hỗ trợ chỉnh sửa
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Map<String, dynamic>? get _profile =>
      ref.read(profileViewModelProvider).value;
  bool get _isLoadingProfile => ref.read(profileViewModelProvider).isLoading;

  Future<void> _loadProfile() =>
      ref.read(profileViewModelProvider.notifier).refresh();

  Future<void> _handleLogout() async {
    // Hiện dialog xác nhận trước khi đăng xuất
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
        ),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D4C41),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _openEditProfile() async {
    final name = _profile?['full_name'] ?? '';
    final phone = _profile?['phone'] ?? '';

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditProfileScreen(currentName: name, currentPhone: phone),
      ),
    );

    // Nếu cập nhật thành công, reload lại profile
    if (result == true) {
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileViewModelProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro',
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingProfile
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
            )
          : RefreshIndicator(
              onRefresh: _loadProfile,
              color: const Color(0xFFE07A5F),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildAccountSettingsSection(),
                    const SizedBox(height: 40),
                    _buildLogoutButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ─── Header: Avatar + Tên + Role ─────────────────────────────────────────
  Widget _buildProfileHeader() {
    final currentUser = ref.read(authRepositoryProvider).currentUser;

    final String rawName = _profile?['full_name'] ?? '';
    final String name = rawName.isEmpty
        ? (currentUser?.email?.split('@').first ?? 'Người dùng')
        : rawName;

    final String rawEmail = _profile?['email'] ?? '';
    final String email = rawEmail.isEmpty
        ? (currentUser?.email ?? 'Chưa cập nhật email')
        : rawEmail;

    final avatarUrl = _profile?['avatar_url'] as String?;
    final role = _profile?['role'] as String?;

    String roleLabel = 'Thành viên';
    if (role == 'customer') roleLabel = 'Khách hàng';
    if (role == 'host') roleLabel = 'Chủ nhà';
    if (role == 'author') roleLabel = 'Người viết bài';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar với nút camera
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFF7F4E1),
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFFBDBDBD),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _openEditProfile,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE07A5F),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 12),
          // Role badge
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
                Text(
                  roleLabel,
                  style: const TextStyle(
                    color: Color(0xFFE07A5F),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Thông tin liên hệ ────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    final currentUser = ref.read(authRepositoryProvider).currentUser;

    final String rawPhone = _profile?['phone'] ?? '';
    final String phone = rawPhone.isEmpty ? 'Chưa cập nhật SĐT' : rawPhone;

    final String rawEmail = _profile?['email'] ?? '';
    final String email = rawEmail.isEmpty
        ? (currentUser?.email ?? 'Chưa cập nhật email')
        : rawEmail;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Thông tin liên hệ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D4C41),
                ),
              ),
              const Spacer(),
              // Nút chỉnh sửa nhanh
              GestureDetector(
                onTap: _openEditProfile,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE07A5F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: Color(0xFFE07A5F),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Chỉnh sửa',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE07A5F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactRow(Icons.phone_iphone, 'Số điện thoại', phone),
          const Divider(height: 24),
          _buildContactRow(Icons.email_outlined, 'Email liên hệ', email),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String val) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F4E1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF6D4C41), size: 18),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              val,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF424242),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Cài đặt tài khoản ───────────────────────────────────────────────────
  Widget _buildAccountSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cài đặt tài khoản',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              _buildSettingItem(
                Icons.person_outline,
                'Thông tin cá nhân',
                'Tên, số điện thoại',
                onTap: _openEditProfile,
              ),
              const Divider(height: 1),
              _buildSettingItem(
                Icons.lock_outline,
                'Đổi mật khẩu',
                'Đặt lại qua email',
                onTap: () => Navigator.pushNamed(context, '/forgot-password'),
              ),
              const Divider(height: 1),
              _buildSettingItem(
                Icons.notifications_outlined,
                'Cài đặt thông báo',
                'Đặt phòng, khuyến mãi',
                onTap: () => Navigator.pushNamed(context, '/notifications'),
              ),
              const Divider(height: 1),
              _buildSettingItem(
                Icons.shield_outlined,
                'Bảo mật tài khoản',
                'Xác thực hai yếu tố',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4E1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF6D4C41), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }

  // ─── Nút đăng xuất ───────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: _handleLogout,
      icon: const Icon(Icons.logout, color: Colors.white, size: 20),
      label: const Text(
        'Đăng xuất',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
      ),
    );
  }

  // ─── Bottom Nav Bar ───────────────────────────────────────────────────────
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFE07A5F),
      unselectedItemColor: Colors.grey,
      currentIndex: 3,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Khám phá'),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Yêu thích',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Đặt chỗ',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
      ],
    );
  }
}
