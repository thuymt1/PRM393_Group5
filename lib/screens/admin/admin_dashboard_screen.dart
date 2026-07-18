import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/repository_providers.dart';
import '../../features/admin/viewmodels/admin_dashboard_view_model.dart';
import '../../models/host_application_model.dart';
import '../../models/homestay_model.dart';
import 'host_application_detail_screen.dart';
import 'admin_finance_tab.dart';

/// Admin Dashboard - 4 tab chính + Tab Người dùng có sub-tab theo role
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _mainTabController;

  String _applicationFilter = 'pending';

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 5, vsync: this);
    _mainTabController.addListener(() {
      setState(() => _currentIndex = _mainTabController.index);
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    await ref.read(authRepositoryProvider).signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _refreshAll() {
    ref.read(adminDashboardViewModelProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _mainTabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildOverviewTab(),
          _buildApplicationsTab(),
          _buildHomestaysTab(),
          _buildUsersTab(),
          const AdminFinanceTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // APP BAR & BOTTOM NAV
  // ─────────────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF6D4C41),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Quản trị hệ thống',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _refreshAll,
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          tooltip: 'Làm mới',
        ),
        IconButton(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          tooltip: 'Đăng xuất',
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.dashboard_rounded, 'label': 'Tổng quan'},
      {'icon': Icons.assignment_rounded, 'label': 'Đơn Host'},
      {'icon': Icons.home_work_rounded, 'label': 'Homestay'},
      {'icon': Icons.people_rounded, 'label': 'Người dùng'},
      {'icon': Icons.currency_exchange, 'label': 'Hủy/hoàn'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 65,
          child: Row(
            children: List.generate(items.length, (i) {
              final isSelected = _currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _mainTabController.animateTo(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        color: isSelected
                            ? const Color(0xFFE07A5F)
                            : Colors.grey.shade400,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFFE07A5F)
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 1: TỔNG QUAN
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildOverviewTab() {
    return ref
        .watch(adminDashboardViewModelProvider)
        .when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
          ),
          error: (error, _) => Center(child: Text('Lỗi tải dữ liệu: $error')),
          data: (dashboard) {
            final stats = dashboard.stats;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Thống kê hệ thống',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6D4C41),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsGrid(stats),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                ],
              ),
            );
          },
        );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D4C41), Color(0xFF8D6E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4C41).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, Admin!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hearth & Horizon — Bảng điều khiển quản trị',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, int> stats) {
    final items = [
      {
        'label': 'Người dùng',
        'value': stats['total_users'] ?? 0,
        'icon': Icons.people_rounded,
        'color': const Color(0xFF3B82F6),
        'bg': const Color(0xFFEFF6FF),
      },
      {
        'label': 'HS Hoạt động',
        'value': stats['active_homestays'] ?? 0,
        'icon': Icons.home_work_rounded,
        'color': const Color(0xFF10B981),
        'bg': const Color(0xFFECFDF5),
      },
      {
        'label': 'HS Tắt',
        'value': stats['inactive_homestays'] ?? 0,
        'icon': Icons.home_work_outlined,
        'color': Colors.grey.shade600,
        'bg': Colors.grey.shade100,
      },
      {
        'label': 'Đặt phòng',
        'value': stats['total_bookings'] ?? 0,
        'icon': Icons.book_online_rounded,
        'color': const Color(0xFFF59E0B),
        'bg': const Color(0xFFFEF3C7),
      },
      {
        'label': 'Đơn chờ duyệt',
        'value': stats['pending_applications'] ?? 0,
        'icon': Icons.pending_actions_rounded,
        'color': const Color(0xFFEF4444),
        'bg': const Color(0xFFFEF2F2),
      },
      {
        'label': 'Tổng Homestay',
        'value':
            (stats['active_homestays'] ?? 0) +
            (stats['inactive_homestays'] ?? 0),
        'icon': Icons.apartment_rounded,
        'color': const Color(0xFF8B5CF6),
        'bg': const Color(0xFFF5F3FF),
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: items.map((item) => _buildStatCard(item)).toList(),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item['bg'] as Color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item['icon'] as IconData,
              color: item['color'] as Color,
              size: 20,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item['value']}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: item['color'] as Color,
                ),
              ),
              Text(
                item['label'] as String,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thao tác nhanh',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
        ),
        const SizedBox(height: 12),
        _quickActionTile(
          icon: Icons.assignment_turned_in_rounded,
          title: 'Xét duyệt đơn Host',
          subtitle: 'Xem và phê duyệt đơn đang chờ',
          color: const Color(0xFFE07A5F),
          onTap: () => _mainTabController.animateTo(1),
        ),
        const SizedBox(height: 8),
        _quickActionTile(
          icon: Icons.home_work_rounded,
          title: 'Quản lý Homestay',
          subtitle: 'Bật/tắt trạng thái hoạt động',
          color: const Color(0xFF10B981),
          onTap: () => _mainTabController.animateTo(2),
        ),
        const SizedBox(height: 8),
        _quickActionTile(
          icon: Icons.payments_rounded,
          title: 'Xử lý hủy và hoàn tiền',
          subtitle: 'Xác nhận yêu cầu và gửi thông báo cho Host',
          color: const Color(0xFF3B82F6),
          onTap: () => _mainTabController.animateTo(4),
        ),
      ],
    );
  }

  Widget _quickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF424242),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 2: XÉT DUYỆT ĐƠN HOST
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildApplicationsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildApplicationFilterBar(),
        Expanded(
          child: ref
              .watch(adminDashboardViewModelProvider)
              .when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
                ),
                error: (error, _) =>
                    Center(child: Text('Lỗi tải dữ liệu: $error')),
                data: (dashboard) {
                  final list = _applicationFilter == 'all'
                      ? dashboard.applications
                      : dashboard.applications
                            .where((app) => app.status == _applicationFilter)
                            .toList();

                  if (list.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.assignment_outlined,
                      message: 'Không có đơn nào',
                      subtitle: 'Chưa có đơn đăng ký host trong trạng thái này',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(adminDashboardViewModelProvider.notifier)
                        .refresh(),
                    color: const Color(0xFFE07A5F),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) =>
                          _buildApplicationCard(list[i]),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildApplicationFilterBar() {
    final filters = [
      {'key': 'pending', 'label': 'Chờ duyệt'},
      {'key': 'approved', 'label': 'Đã duyệt'},
      {'key': 'rejected', 'label': 'Từ chối'},
      {'key': 'all', 'label': 'Tất cả'},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isActive = _applicationFilter == f['key'];
            return GestureDetector(
              onTap: () => setState(() {
                _applicationFilter = f['key']!;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE07A5F)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildApplicationCard(HostApplication app) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (app.status) {
      case 'approved':
        statusColor = Colors.green.shade600;
        statusBg = Colors.green.shade50;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = Colors.red.shade600;
        statusBg = Colors.red.shade50;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusBg = const Color(0xFFFEF3C7);
        statusIcon = Icons.hourglass_top_rounded;
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HostApplicationDetailScreen(application: app),
          ),
        );
        await ref.read(adminDashboardViewModelProvider.notifier).refresh();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFF7F4E1),
                  child: Text(
                    app.fullName.isNotEmpty
                        ? app.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Color(0xFFE07A5F),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF424242),
                        ),
                      ),
                      Text(
                        app.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        app.statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (app.reason != null && app.reason!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Text(
                app.reason!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  _formatDate(app.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
                const Spacer(),
                if (app.isPending)
                  Row(
                    children: [
                      const Text(
                        'Xét duyệt',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE07A5F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 3: QUẢN LÝ HOMESTAY (có search)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHomestaysTab() {
    return ref
        .watch(adminDashboardViewModelProvider)
        .when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
          ),
          error: (error, _) => Center(child: Text('Lỗi tải dữ liệu: $error')),
          data: (dashboard) {
            final allList = dashboard.homestays;

            return _HomestaysTabContent(
              allHomestays: allList,
              onRefresh: () =>
                  ref.read(adminDashboardViewModelProvider.notifier).refresh(),
            );
          },
        );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 4: QUẢN LÝ NGƯỜI DÙNG (sub-tab theo role + search + pagination)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildUsersTab() {
    return ref
        .watch(adminDashboardViewModelProvider)
        .when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
          ),
          error: (error, _) => Center(child: Text('Lỗi tải dữ liệu: $error')),
          data: (dashboard) {
            final allUsers = dashboard.users;

            return _UsersTabContent(
              allUsers: allUsers,
              onRefresh: () =>
                  ref.read(adminDashboardViewModelProvider.notifier).refresh(),
            );
          },
        );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHARED HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// USERS TAB — Widget riêng để dùng StatefulWidget cho sub-tabs + pagination
// ─────────────────────────────────────────────────────────────────────────────
class _UsersTabContent extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> allUsers;
  final VoidCallback onRefresh;

  const _UsersTabContent({required this.allUsers, required this.onRefresh});

  @override
  ConsumerState<_UsersTabContent> createState() => _UsersTabContentState();
}

class _UsersTabContentState extends ConsumerState<_UsersTabContent>
    with SingleTickerProviderStateMixin {
  late TabController _roleTabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  static const int _pageSize = 15;

  // Pages per tab
  final Map<int, int> _currentPage = {0: 0, 1: 0, 2: 0, 3: 0};

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'Tất cả', 'role': null, 'icon': Icons.people_rounded},
    {'label': 'KH', 'role': 'customer', 'icon': Icons.person_rounded},
    {'label': 'Chủ nhà', 'role': 'host', 'icon': Icons.home_work_rounded},
    {'label': 'Tác giả', 'role': 'author', 'icon': Icons.edit_note_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _roleTabController = TabController(length: _tabs.length, vsync: this);
    _roleTabController.addListener(
      () => setState(() {
        for (int i = 0; i < _tabs.length; i++) {
          _currentPage[i] = 0;
        }
      }),
    );
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        for (int i = 0; i < _tabs.length; i++) {
          _currentPage[i] = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _roleTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredUsers(String? roleFilter) {
    var users = widget.allUsers;

    // Filter by role
    if (roleFilter != null) {
      users = users.where((u) => u['role'] == roleFilter).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      users = users.where((u) {
        final name = (u['full_name'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        final phone = (u['phone'] ?? '').toString().toLowerCase();
        return name.contains(_searchQuery) ||
            email.contains(_searchQuery) ||
            phone.contains(_searchQuery);
      }).toList();
    }

    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search bar
        _buildSearchBar(),
        // Role tab bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _roleTabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: const Color(0xFFE07A5F),
            unselectedLabelColor: Colors.grey.shade500,
            indicatorColor: const Color(0xFFE07A5F),
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            tabs: _tabs.map((t) {
              final role = t['role'] as String?;
              final count = _getFilteredUsers(role).length;
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t['icon'] as IconData, size: 14),
                    const SizedBox(width: 4),
                    Text(t['label'] as String),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        // Content
        Expanded(
          child: TabBarView(
            controller: _roleTabController,
            children: List.generate(_tabs.length, (tabIdx) {
              final role = _tabs[tabIdx]['role'] as String?;
              final users = _getFilteredUsers(role);
              final page = _currentPage[tabIdx] ?? 0;
              final totalPages = (users.length / _pageSize).ceil().clamp(
                1,
                9999,
              );
              final start = page * _pageSize;
              final end = (start + _pageSize).clamp(0, users.length);
              final pageUsers = users.sublist(start, end);

              if (users.isEmpty) {
                return _buildEmpty(role);
              }

              return RefreshIndicator(
                onRefresh: () async => widget.onRefresh(),
                color: const Color(0xFFE07A5F),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        itemCount: pageUsers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) =>
                            _buildUserCard(pageUsers[i]),
                      ),
                    ),
                    // Pagination
                    if (totalPages > 1)
                      _buildPagination(tabIdx, page, totalPages),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, email, số điện thoại...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade400,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildEmpty(String? role) {
    String message = role == null
        ? 'Chưa có người dùng'
        : 'Chưa có người dùng trong nhóm này';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Thử tìm với từ khóa khác',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPagination(int tabIdx, int currentPage, int totalPages) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Prev
          IconButton(
            onPressed: currentPage > 0
                ? () => setState(() => _currentPage[tabIdx] = currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
            iconSize: 22,
            color: currentPage > 0
                ? const Color(0xFFE07A5F)
                : Colors.grey.shade300,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          // Pages
          ...List.generate(totalPages, (i) {
            final isActive = i == currentPage;
            // Show only current page ±2
            if (totalPages > 7 &&
                (i - currentPage).abs() > 2 &&
                i != 0 &&
                i != totalPages - 1) {
              if (i == 1 && currentPage > 3) return const Text(' ... ');
              if (i == totalPages - 2 && currentPage < totalPages - 4)
                return const Text(' ... ');
              if ((i - currentPage).abs() > 2) return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () => setState(() => _currentPage[tabIdx] = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 32,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE07A5F)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isActive
                      ? null
                      : Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            );
          }),
          // Next
          IconButton(
            onPressed: currentPage < totalPages - 1
                ? () => setState(() => _currentPage[tabIdx] = currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
            iconSize: 22,
            color: currentPage < totalPages - 1
                ? const Color(0xFFE07A5F)
                : Colors.grey.shade300,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = user['role'] ?? 'customer';
    final roleConfig = _getRoleConfig(role);
    final isLocked = user['is_locked'] == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isLocked ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLocked ? Colors.red.shade200 : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: user['avatar_url'] != null
                    ? NetworkImage(user['avatar_url'])
                    : null,
                backgroundColor: const Color(0xFFF7F4E1),
                child: user['avatar_url'] == null
                    ? Text(
                        (user['full_name'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFE07A5F),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (isLocked)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.lock, size: 8, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user['full_name'] ?? 'Chưa cập nhật',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isLocked
                              ? Colors.red.shade700
                              : const Color(0xFF424242),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLocked)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Đã khóa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  user['email'] ?? '',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                Text(
                  user['phone'] ?? 'Chưa có SĐT',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Role badge + lock button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: roleConfig['bg'] as Color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  roleConfig['label'] as String,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: roleConfig['color'] as Color,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Lock/Unlock button
              GestureDetector(
                onTap: () => _toggleLockUser(user),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isLocked
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                        size: 11,
                        color: isLocked
                            ? Colors.green.shade700
                            : Colors.red.shade600,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isLocked ? 'Mở khóa' : 'Khóa',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isLocked
                              ? Colors.green.shade700
                              : Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLockUser(Map<String, dynamic> user) async {
    final isLocked = user['is_locked'] == true;
    final userName = user['full_name'] ?? 'người dùng này';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isLocked ? 'Mở khóa tài khoản?' : 'Khóa tài khoản?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isLocked
              ? '$userName sẽ có thể đăng nhập bình thường trở lại.'
              : '$userName sẽ bị chặn đăng nhập. Họ sẽ thấy thông báo tài khoản bị khóa.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLocked
                  ? Colors.green.shade600
                  : Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isLocked ? 'Mở khóa' : 'Khóa',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref
            .read(adminRepositoryProvider)
            .setUserLocked(user['id'], !isLocked);
        widget.onRefresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Map<String, dynamic> _getRoleConfig(String role) {
    switch (role) {
      case 'admin':
        return {
          'label': 'Admin',
          'color': Colors.purple.shade700,
          'bg': Colors.purple.shade50,
        };
      case 'host':
        return {
          'label': 'Chủ nhà',
          'color': Colors.green.shade700,
          'bg': Colors.green.shade50,
        };
      case 'author':
        return {
          'label': 'Tác giả',
          'color': Colors.blue.shade700,
          'bg': Colors.blue.shade50,
        };
      case 'pending_host':
        return {
          'label': 'Chờ Host',
          'color': const Color(0xFFF59E0B),
          'bg': const Color(0xFFFEF3C7),
        };
      default:
        return {
          'label': 'Khách hàng',
          'color': Colors.grey.shade700,
          'bg': Colors.grey.shade100,
        };
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOMESTAYS TAB — Widget riêng để cô lập trạng thái search và điều hướng chi tiết
// ─────────────────────────────────────────────────────────────────────────────
class _HomestaysTabContent extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> allHomestays;
  final VoidCallback onRefresh;

  const _HomestaysTabContent({
    required this.allHomestays,
    required this.onRefresh,
  });

  @override
  ConsumerState<_HomestaysTabContent> createState() =>
      _HomestaysTabContentState();
}

class _HomestaysTabContentState extends ConsumerState<_HomestaysTabContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredHomestays() {
    final list = widget.allHomestays;
    if (_searchQuery.isEmpty) return list;

    return list.where((h) {
      final name = (h['name'] ?? '').toString().toLowerCase();
      final city = (h['city'] ?? '').toString().toLowerCase();
      final hostName = (h['profiles']?['full_name'] ?? '')
          .toString()
          .toLowerCase();
      return name.contains(_searchQuery) ||
          city.contains(_searchQuery) ||
          hostName.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredHomestays();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search bar
        _buildSearchBar(),
        // Stats summary
        _buildStatsSummary(),
        // List
        Expanded(
          child: filteredList.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: () async => widget.onRefresh(),
                  color: const Color(0xFFE07A5F),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _buildCard(filteredList[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, thành phố, chủ nhà...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade400,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    final list = widget.allHomestays;
    final activeCount = list.where((h) => h['status'] == 'active').length;
    final inactiveCount = list.where((h) => h['status'] != 'active').length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _miniStatChip(
            label: 'Tất cả: ${list.length}',
            color: Colors.grey.shade600,
            bg: Colors.grey.shade100,
          ),
          const SizedBox(width: 8),
          _miniStatChip(
            label: 'Hoạt động: $activeCount',
            color: Colors.green.shade700,
            bg: Colors.green.shade50,
          ),
          const SizedBox(width: 8),
          _miniStatChip(
            label: 'Tắt: $inactiveCount',
            color: Colors.red.shade600,
            bg: Colors.red.shade50,
          ),
        ],
      ),
    );
  }

  Widget _miniStatChip({
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> homestay) {
    final isActive = homestay['status'] == 'active';
    final images = (homestay['homestay_images'] as List?) ?? [];
    final imageUrl = images.isNotEmpty ? images[0]['url'] as String : null;

    return Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final homestayObj = Homestay.fromJson(homestay);
              Navigator.pushNamed(
                context,
                '/homestay-detail',
                arguments: homestayObj,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (imageUrl != null)
                  Stack(
                    children: [
                      Image.network(
                        imageUrl,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        color: isActive
                            ? null
                            : Colors.white.withValues(alpha: 0.5),
                        colorBlendMode: isActive ? null : BlendMode.lighten,
                        errorBuilder: (_, __, ___) => Container(
                          height: 110,
                          color: Colors.grey.shade100,
                          child: const Icon(
                            Icons.home,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      ),
                      if (!isActive)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Đã tắt',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              homestay['name'] ?? 'Homestay',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isActive
                                    ? const Color(0xFF424242)
                                    : Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  homestay['city'] ?? '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 12,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  homestay['profiles']?['full_name'] ??
                                      'Không rõ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildStatusToggle(homestay, isActive),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusToggle(Map<String, dynamic> homestay, bool isActive) {
    return GestureDetector(
      onTap: () async {
        final newStatus = isActive ? 'inactive' : 'active';
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(isActive ? 'Tắt Homestay?' : 'Kích hoạt Homestay?'),
            content: Text(
              isActive
                  ? 'Homestay sẽ không còn hiển thị với khách hàng.'
                  : 'Homestay sẽ được hiển thị trở lại.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE07A5F),
                ),
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await ref
              .read(adminRepositoryProvider)
              .updateHomestayStatus(homestay['id'], newStatus);
          widget.onRefresh();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? Colors.green.shade500 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isActive ? 'Hoạt động' : 'Tắt',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.home_work_outlined,
            size: 64,
            color: Color(0xFFE07A5F),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Chưa có homestay nào'
                : 'Không tìm thấy kết quả',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Thử tìm với từ khóa khác',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
        ],
      ),
    );
  }
}
