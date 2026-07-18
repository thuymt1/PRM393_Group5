import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/customer/viewmodels/cancellation_view_model.dart';

class AdminFinanceTab extends ConsumerWidget {
  const AdminFinanceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(cancellationViewModelProvider);
    if (requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.currency_exchange, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Chưa có yêu cầu hủy và hoàn tiền trong phiên này.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _CancellationCard(request: requests[index]),
    );
  }
}

class _CancellationCard extends ConsumerWidget {
  const _CancellationCard({required this.request});

  final CancellationWorkflowRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = request.booking;
    final homestay = booking['homestays'] as Map?;
    final amount = request.refundAmount.toInt().toString().replaceAllMapped(
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
                        'Booking #${request.bookingId}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(request: request),
              ],
            ),
            const SizedBox(height: 12),
            Text('Lý do: ${request.reason}'),
            Text('Mức hoàn: ${request.refundPercent}%'),
            Text(
              'Số tiền hoàn: $amountđ',
              style: const TextStyle(
                color: Color(0xFFE07A5F),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (!request.adminApproved)
              _actionButton(
                label: 'Xác nhận yêu cầu hủy',
                icon: Icons.fact_check_outlined,
                color: const Color(0xFF6D4C41),
                onPressed: () {
                  ref
                      .read(cancellationViewModelProvider.notifier)
                      .adminApprove(request.bookingId);
                  _message(context, 'Admin đã xác nhận yêu cầu hủy.');
                },
              )
            else if (!request.refundSent)
              _actionButton(
                label: request.refundAmount > 0
                    ? 'Xác nhận đã hoàn tiền'
                    : 'Xác nhận không phát sinh hoàn tiền',
                icon: Icons.payments_outlined,
                color: Colors.green,
                onPressed: () {
                  ref
                      .read(cancellationViewModelProvider.notifier)
                      .adminMarkRefundSent(request.bookingId);
                  _message(context, 'Đã chuyển sang chờ Customer xác nhận.');
                },
              )
            else if (!request.customerReceived)
              const _WaitingBox(
                text: 'Đang chờ Customer xác nhận đã nhận tiền hoàn.',
              )
            else if (!request.adminNotifiedHost)
              _actionButton(
                label: 'Gửi thông báo cho Host xác nhận hủy',
                icon: Icons.notifications_active_outlined,
                color: Colors.blue,
                onPressed: () {
                  ref
                      .read(cancellationViewModelProvider.notifier)
                      .adminNotifyHost(request.bookingId);
                  _message(context, 'Đã gửi thông báo xác nhận hủy cho Host.');
                },
              )
            else if (!request.hostCompleted)
              const _WaitingBox(
                text: 'Đã báo Host. Đang chờ Host xác nhận hủy cuối cùng.',
              )
            else
              const _WaitingBox(
                text: 'Đã hoàn tất. Host có thể mở lại lịch phòng.',
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );

  void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.request});

  final CancellationWorkflowRequest request;

  @override
  Widget build(BuildContext context) {
    final (label, color) = request.hostCompleted
        ? ('Hoàn tất', Colors.green)
        : request.adminNotifiedHost
        ? ('Chờ Host', Colors.blue)
        : request.customerReceived
        ? ('Khách đã nhận', Colors.green)
        : request.refundSent
        ? ('Chờ Customer', Colors.blue)
        : request.adminApproved
        ? ('Chờ hoàn tiền', Colors.orange)
        : ('Chờ Admin', Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _WaitingBox extends StatelessWidget {
  const _WaitingBox({required this.text, this.color = Colors.orange});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text, style: TextStyle(color: color)),
  );
}
