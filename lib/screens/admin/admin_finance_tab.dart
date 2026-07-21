import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repository_providers.dart';
import '../../features/admin/viewmodels/admin_dashboard_view_model.dart';

class AdminFinanceTab extends StatelessWidget {
  const AdminFinanceTab({super.key, required this.bookings});

  final List<dynamic> bookings;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Column(
        children: [
          Material(
            color: Colors.white,
            child: TabBar(
              labelColor: const Color(0xFFE07A5F),
              unselectedLabelColor: Colors.grey.shade500,
              indicatorColor: const Color(0xFFE07A5F),
              tabs: const [
                Tab(text: 'Đơn đặt phòng'),
                Tab(text: 'Hủy / hoàn tiền'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _BookingsList(bookings: bookings),
                _CancellationsList(bookings: bookings),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingsList extends ConsumerWidget {
  const _BookingsList({required this.bookings});

  final List<dynamic> bookings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _RefreshableBookingList(
      bookings: bookings,
      emptyIcon: Icons.book_online_outlined,
      emptyMessage: 'Chưa có đơn đặt phòng nào.',
      itemBuilder: (booking) => _BookingCard(booking: booking),
    );
  }
}

class _CancellationsList extends ConsumerWidget {
  const _CancellationsList({required this.bookings});

  final List<dynamic> bookings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cancellations = bookings
        .map((item) => Map<String, dynamic>.from(item as Map))
        .where(
          (booking) => const {
            'cancel_pending',
            'refunded',
            'cancelled',
          }.contains(booking['status']),
        )
        .toList();

    return _RefreshableBookingList(
      bookings: cancellations,
      emptyIcon: Icons.currency_exchange,
      emptyMessage: 'Chưa có yêu cầu hủy và hoàn tiền.',
      itemBuilder: (booking) => _CancellationCard(booking: booking),
    );
  }
}

class _RefreshableBookingList extends ConsumerWidget {
  const _RefreshableBookingList({
    required this.bookings,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.itemBuilder,
  });

  final List<dynamic> bookings;
  final IconData emptyIcon;
  final String emptyMessage;
  final Widget Function(Map<String, dynamic>) itemBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> refresh() =>
        ref.read(adminDashboardViewModelProvider.notifier).refresh();

    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          children: [
            const SizedBox(height: 180),
            Icon(emptyIcon, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Center(child: Text(emptyMessage)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            itemBuilder(Map<String, dynamic>.from(bookings[index] as Map)),
      ),
    );
  }
}

class _BookingCard extends ConsumerStatefulWidget {
  const _BookingCard({required this.booking});

  final Map<String, dynamic> booking;

  @override
  ConsumerState<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends ConsumerState<_BookingCard> {
  bool _updating = false;

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final status = booking['status']?.toString() ?? 'unknown';
    final canReview = status == 'payment_pending' || status == 'pending';
    final approvedStatus = status == 'payment_pending'
        ? 'pending'
        : 'confirmed';

    return _BookingInfoCard(
      booking: booking,
      footer: canReview
          ? Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _updating
                        ? null
                        : () => _updateStatus('rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updating
                        ? null
                        : () => _updateStatus(approvedStatus),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D4C41),
                    ),
                    child: _updating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Xác nhận đơn',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _updating = true);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateStatus((widget.booking['id'] as num).toInt(), status);
      await ref.read(adminDashboardViewModelProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'rejected'
                ? 'Đã từ chối đơn đặt phòng.'
                : 'Đã xác nhận đơn đặt phòng.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể cập nhật đơn: $error')));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }
}

class _CancellationCard extends ConsumerStatefulWidget {
  const _CancellationCard({required this.booking});

  final Map<String, dynamic> booking;

  @override
  ConsumerState<_CancellationCard> createState() => _CancellationCardState();
}

class _CancellationCardState extends ConsumerState<_CancellationCard> {
  bool _updating = false;

  @override
  Widget build(BuildContext context) {
    final isPending = widget.booking['status'] == 'cancel_pending';
    return _BookingInfoCard(
      booking: widget.booking,
      footer: isPending
          ? SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _updating ? null : _confirmCancellation,
                icon: const Icon(Icons.currency_exchange, color: Colors.white),
                label: Text(
                  _updating ? 'Đang xử lý...' : 'Xác nhận đã hoàn/hủy',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            )
          : null,
    );
  }

  Future<void> _confirmCancellation() async {
    setState(() => _updating = true);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateStatus((widget.booking['id'] as num).toInt(), 'refunded');
      await ref.read(adminDashboardViewModelProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xác nhận hoàn/hủy đơn.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể xác nhận: $error')));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }
}

class _BookingInfoCard extends StatelessWidget {
  const _BookingInfoCard({required this.booking, this.footer});

  final Map<String, dynamic> booking;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final homestay = booking['homestays'] as Map?;
    final customer = booking['profiles'] as Map?;
    final status = booking['status']?.toString() ?? 'unknown';
    final (statusLabel, statusColor) = switch (status) {
      'payment_pending' => ('Chờ Admin xác minh', Colors.orange),
      'pending' => ('Chờ xác nhận', Colors.blue),
      'confirmed' => ('Đã xác nhận', Colors.green),
      'rejected' => ('Đã từ chối', Colors.red),
      'cancel_pending' => ('Chờ xử lý hủy', Colors.deepOrange),
      'refunded' => ('Đã hoàn/hủy', Colors.indigo),
      'cancelled' => ('Đã hủy', Colors.grey),
      _ => (status, Colors.grey),
    };
    final total = ((booking['total_price'] as num?) ?? 0)
        .toInt()
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    homestay?['name']?.toString() ??
                        'Booking #${booking['id']}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _LabelChip(label: statusLabel, color: statusColor),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Khách: ${customer?['full_name'] ?? customer?['email'] ?? 'Không rõ'}',
            ),
            Text('Nhận phòng: ${booking['check_in']}'),
            Text('Trả phòng: ${booking['check_out']}'),
            Text(
              'Tổng tiền: $totalđ',
              style: const TextStyle(
                color: Color(0xFFE07A5F),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (footer != null) ...[const SizedBox(height: 16), footer!],
          ],
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
    ),
  );
}
