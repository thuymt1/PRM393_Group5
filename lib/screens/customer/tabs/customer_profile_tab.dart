import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repository_providers.dart';
import '../../../features/customer/viewmodels/customer_home_view_model.dart';

class CustomerProfileTab extends ConsumerWidget {
  const CustomerProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(customerHomeViewModelProvider).when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
          ),
          error: (error, _) => Center(child: Text('Lỗi tải dữ liệu: $error')),
          data: (homeState) {
            final profile = homeState.profile;
            final currentUser = ref.read(authRepositoryProvider).currentUser;

            final String rawName = profile?['full_name'] ?? '';
            final String fullName = rawName.isEmpty
                ? (currentUser?.email?.split('@').first ?? 'Người dùng')
                : rawName;

            final String rawEmail = profile?['email'] ?? '';
            final String email = rawEmail.isEmpty
                ? (currentUser?.email ?? 'Chưa cập nhật email')
                : rawEmail;

            final String rawPhone = profile?['phone'] ?? '';
            final String phone =
                rawPhone.isEmpty ? 'Chưa cập nhật SĐT' : rawPhone;

            final String? avatarUrl = profile?['avatar_url'];

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
                  ),
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Khung Avatar & Thông tin cá nhân cơ bản
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFFF7F4E1),
                                backgroundImage: avatarUrl != null &&
                                        avatarUrl.isNotEmpty
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                child: avatarUrl == null || avatarUrl.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Color(0xFF6D4C41),
                                      )
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE07A5F),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF424242),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F4E1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_user,
                                  size: 14,
                                  color: Color(0xFFE07A5F),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  profile?['role'] == 'customer'
                                      ? 'Khách hàng'
                                      : (profile?['role'] == 'host'
                                          ? 'Chủ nhà'
                                          : 'Tác giả'),
                                  style: const TextStyle(
                                    color: Color(0xFFE07A5F),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/profile');
                            },
                            icon: const Icon(
                              Icons.settings_outlined,
                              color: Color(0xFF6D4C41),
                            ),
                            label: const Text(
                              'Chỉnh sửa hồ sơ',
                              style: TextStyle(
                                color: Color(0xFF6D4C41),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF6D4C41)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Các thông tin chi tiết liên hệ
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          _buildContactRow(
                            Icons.phone_iphone,
                            'Số điện thoại',
                            phone,
                          ),
                          const Divider(height: 24),
                          _buildContactRow(
                            Icons.email_outlined,
                            'Email liên hệ',
                            email,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Nút đăng xuất khỏi ứng dụng
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await ref.read(authRepositoryProvider).signOut();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Đăng xuất',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }

  Widget _buildContactRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F4E1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF6D4C41), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF424242),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
