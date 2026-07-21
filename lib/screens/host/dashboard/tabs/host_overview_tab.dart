import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/host/viewmodels/host_bookings_view_model.dart';
import '../../../../features/host/viewmodels/host_dashboard_view_model.dart';
import '../host_dashboard_theme.dart';
import '../widgets/host_dashboard_common.dart';

class HostOverviewTab extends ConsumerStatefulWidget {
  const HostOverviewTab({required this.onSelectTab, super.key});

  final ValueChanged<int> onSelectTab;

  @override
  ConsumerState<HostOverviewTab> createState() => _HostOverviewTabState();
}

class _HostOverviewTabState extends ConsumerState<HostOverviewTab> {
  Future<void> _refresh() {
    return ref.read(hostDashboardViewModelProvider.notifier).refresh();
  }

  Future<void> _openBooking(Map<String, dynamic> booking) async {
    final result = await Navigator.pushNamed(
      context,
      '/host-booking-detail',
      arguments: booking,
    );
    if (result == true) await _refresh();
  }

  Future<void> _updateStatus(int bookingId, String status) async {
    try {
      await ref
          .read(hostBookingsViewModelProvider.notifier)
          .updateBooking(bookingId, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'confirmed'
                ? 'Đã xác nhận đơn đặt phòng.'
                : 'Đã từ chối đơn đặt phòng.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cập nhật thất bại: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(hostBookingsViewModelProvider);

    return ref
        .watch(hostDashboardViewModelProvider)
        .when(
          loading: () => const HostLoadingState(),
          error: (error, _) => HostErrorState(error: error, onRetry: _refresh),
          data: (dashboard) {
            final summary = dashboard.summary;
            final highlightedBooking = summary.highlightedBooking;
            final highlightedBookingId = int.tryParse(
              highlightedBooking['id']?.toString() ?? '',
            );
            final formattedEarnings = _formatCurrency(
              summary.totalConfirmedEarnings,
            );

            return RefreshIndicator(
              onRefresh: _refresh,
              color: hostOrange,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _OverviewHeader(email: dashboard.accountEmail),
                          const SizedBox(height: 18),
                          _EarningsCard(
                            earnings: formattedEarnings,
                            pendingBookings: summary.pendingBookings,
                          ),
                          const SizedBox(height: 20),
                          _StatsGrid(
                            confirmedBookings: summary.confirmedBookings,
                            homestaysCount: dashboard.homestays.length,
                            pendingBookings: summary.pendingBookings,
                            cancellationBookings: summary.cancellationBookings,
                          ),
                          const SizedBox(height: 28),
                          _SectionHeader(
                            title: summary.pendingBookings > 0
                                ? 'Cần bạn xử lý'
                                : 'Đơn đặt gần đây',
                            onTap: () => widget.onSelectTab(1),
                          ),
                          const SizedBox(height: 10),
                          highlightedBooking.isEmpty
                              ? const HostEmptyState(
                                  message: 'Chưa có yêu cầu đặt phòng nào.',
                                  icon: Icons.event_available_outlined,
                                )
                              : HostBookingCard(
                                  booking: highlightedBooking,
                                  isUpdating:
                                      highlightedBookingId != null &&
                                      bookingsState.updatingIds.contains(
                                        highlightedBookingId,
                                      ),
                                  onOpen: () =>
                                      _openBooking(highlightedBooking),
                                  onUpdateStatus: _updateStatus,
                                ),
                          const SizedBox(height: 28),
                          _SectionHeader(
                            title: 'Homestay của tôi',
                            onTap: () => widget.onSelectTab(2),
                          ),
                          const SizedBox(height: 10),
                          dashboard.homestays.isEmpty
                              ? const HostEmptyState(
                                  message: 'Bạn chưa đăng homestay nào.',
                                  icon: Icons.add_home_work_outlined,
                                )
                              : HostHomestayCard(
                                  homestay: dashboard.homestays.first,
                                ),
                          const SizedBox(height: 72),
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

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final resolvedEmail = email ?? 'host@example.com';
    final initial = resolvedEmail.trim().isEmpty
        ? 'H'
        : resolvedEmail.trim()[0].toUpperCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Không gian chủ nhà',
                style: TextStyle(
                  color: hostBrown,
                  fontWeight: FontWeight.w700,
                  fontSize: 23,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Theo dõi hoạt động hôm nay',
                style: TextStyle(color: Color(0xFF8C8079), fontSize: 13),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                tooltip: 'Thông báo',
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: hostBrown,
                ),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFF1DDD4),
              child: Text(
                initial,
                style: const TextStyle(
                  color: hostBrown,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.earnings, required this.pendingBookings});

  final String earnings;
  final int pendingBookings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: hostBrown,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: hostBrown.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
            '$earnings đ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: Color(0xFFFFD8C8),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  pendingBookings == 0
                      ? 'Không có đơn đang chờ duyệt'
                      : '$pendingBookings đơn đang chờ bạn duyệt',
                  style: const TextStyle(
                    color: Color(0xFFFFE8DF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.confirmedBookings,
    required this.homestaysCount,
    required this.pendingBookings,
    required this.cancellationBookings,
  });

  final int confirmedBookings;
  final int homestaysCount;
  final int pendingBookings;
  final int cancellationBookings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: constraints.maxWidth >= 720 ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: constraints.maxWidth >= 720 ? 1.35 : 1.45,
        children: [
          _StatItem(
            label: 'Homestay',
            value: '$homestaysCount',
            icon: Icons.home_work_outlined,
          ),
          _StatItem(
            label: 'Chờ duyệt',
            value: '$pendingBookings',
            icon: Icons.schedule_outlined,
          ),
          _StatItem(
            label: 'Đã xác nhận',
            value: '$confirmedBookings',
            icon: Icons.check_circle_outline,
          ),
          _StatItem(
            label: 'Chờ hoàn tiền',
            value: '$cancellationBookings',
            icon: Icons.currency_exchange_outlined,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE4D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: hostOrange, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: hostText,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: hostBrown,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text(
            'Xem tất cả',
            style: TextStyle(color: hostOrange, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

String _formatCurrency(double amount) {
  return amount.toInt().toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}
