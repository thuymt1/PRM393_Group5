import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/viewmodels/auth_view_model.dart';
import '../../../../features/host/viewmodels/host_dashboard_view_model.dart';
import '../host_dashboard_theme.dart';
import '../widgets/host_dashboard_common.dart';

class HostProfileTab extends ConsumerStatefulWidget {
  const HostProfileTab({super.key});

  @override
  ConsumerState<HostProfileTab> createState() => _HostProfileTabState();
}

class _HostProfileTabState extends ConsumerState<HostProfileTab> {
  Future<void> _refresh() {
    return ref.read(hostDashboardViewModelProvider.notifier).refresh();
  }

  Future<void> _confirmSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn sẽ cần đăng nhập lại để quản lý homestay.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Ở lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: hostBrown),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (shouldSignOut != true || !mounted) return;

    try {
      await ref.read(authViewModelProvider.notifier).signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đăng xuất thất bại: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSigningOut = ref.watch(authViewModelProvider).isLoading;

    return ref
        .watch(hostDashboardViewModelProvider)
        .when(
          loading: () => const HostLoadingState(),
          error: (error, _) => HostErrorState(error: error, onRetry: _refresh),
          data: (dashboard) {
            final profile = dashboard.profile;
            final accountEmail = dashboard.accountEmail;
            final rawName = profile?['full_name']?.toString() ?? '';
            final fullName = rawName.isEmpty
                ? (accountEmail?.split('@').first ?? 'Người dùng')
                : rawName;
            final rawEmail = profile?['email']?.toString() ?? '';
            final email = rawEmail.isEmpty
                ? (accountEmail ?? 'Chưa cập nhật email')
                : rawEmail;
            final rawPhone = profile?['phone']?.toString() ?? '';
            final phone = rawPhone.isEmpty ? 'Chưa cập nhật SĐT' : rawPhone;
            final avatarUrl = profile?['avatar_url']?.toString();

            return Scaffold(
              backgroundColor: hostBackground,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Menu & Hồ sơ',
                  style: TextStyle(
                    color: hostBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              body: RefreshIndicator(
                onRefresh: _refresh,
                color: hostOrange,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        children: [
                          _ProfileCard(
                            fullName: fullName,
                            email: email,
                            avatarUrl: avatarUrl,
                          ),
                          const SizedBox(height: 24),
                          _ContactCard(phone: phone, email: email),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: isSigningOut ? null : _confirmSignOut,
                            icon: isSigningOut
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
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
                              backgroundColor: hostBrown,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              shadowColor: hostBrown.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.fullName,
    required this.email,
    required this.avatarUrl,
  });

  final String fullName;
  final String email;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileAvatar(imageUrl: avatarUrl, fullName: fullName),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
          Text(email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: hostOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: hostOrange, size: 16),
                SizedBox(width: 8),
                Text(
                  'Chủ nhà',
                  style: TextStyle(
                    color: hostOrange,
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
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.phone, required this.email});

  final String phone;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _ContactRow(
            icon: Icons.phone_iphone,
            label: 'Số điện thoại',
            value: phone,
          ),
          const Divider(height: 24),
          _ContactRow(
            icon: Icons.email_outlined,
            label: 'Email liên hệ',
            value: email,
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: hostBrown, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl, required this.fullName});

  final String? imageUrl;
  final String fullName;

  @override
  Widget build(BuildContext context) {
    final initial = fullName.trim().isEmpty
        ? 'H'
        : fullName.trim()[0].toUpperCase();
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return CircleAvatar(
        radius: 52,
        backgroundColor: const Color(0xFFF1DDD4),
        child: Text(
          initial,
          style: const TextStyle(
            color: hostBrown,
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        imageUrl!,
        width: 104,
        height: 104,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => ColoredBox(
          color: const Color(0xFFF1DDD4),
          child: SizedBox.square(
            dimension: 104,
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: hostBrown,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
