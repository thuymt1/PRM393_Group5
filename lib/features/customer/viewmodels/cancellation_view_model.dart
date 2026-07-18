import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../payments/models/refund_policy.dart';

class CancellationWorkflowRequest {
  const CancellationWorkflowRequest({
    required this.bookingId,
    required this.booking,
    required this.reason,
    required this.refundPercent,
    required this.refundAmount,
    required this.requestedAt,
    this.hostAcknowledged = false,
    this.adminApproved = false,
    this.refundSent = false,
    this.customerReceived = false,
    this.adminNotifiedHost = false,
    this.hostCompleted = false,
  });

  final int bookingId;
  final Map<String, dynamic> booking;
  final String reason;
  final int refundPercent;
  final double refundAmount;
  final DateTime requestedAt;
  final bool hostAcknowledged;
  final bool adminApproved;
  final bool refundSent;
  final bool customerReceived;
  final bool adminNotifiedHost;
  final bool hostCompleted;

  bool get isCompleted => hostCompleted;

  CancellationWorkflowRequest copyWith({
    bool? hostAcknowledged,
    bool? adminApproved,
    bool? refundSent,
    bool? customerReceived,
    bool? adminNotifiedHost,
    bool? hostCompleted,
  }) => CancellationWorkflowRequest(
    bookingId: bookingId,
    booking: booking,
    reason: reason,
    refundPercent: refundPercent,
    refundAmount: refundAmount,
    requestedAt: requestedAt,
    hostAcknowledged: hostAcknowledged ?? this.hostAcknowledged,
    adminApproved: adminApproved ?? this.adminApproved,
    refundSent: refundSent ?? this.refundSent,
    customerReceived: customerReceived ?? this.customerReceived,
    adminNotifiedHost: adminNotifiedHost ?? this.adminNotifiedHost,
    hostCompleted: hostCompleted ?? this.hostCompleted,
  );
}

class CancellationViewModel
    extends Notifier<List<CancellationWorkflowRequest>> {
  @override
  List<CancellationWorkflowRequest> build() => const [];

  CancellationWorkflowRequest requestCancellation({
    required Map<String, dynamic> booking,
    required String reason,
  }) {
    final bookingId = (booking['id'] as num).toInt();
    final existing = findByBookingId(bookingId);
    if (existing != null) return existing;

    final quote = RefundPolicy.calculate(
      checkIn: DateTime.parse(booking['check_in'].toString()),
      totalPrice: (booking['total_price'] as num?)?.toDouble() ?? 0,
    );
    final request = CancellationWorkflowRequest(
      bookingId: bookingId,
      booking: Map<String, dynamic>.from(booking),
      reason: reason,
      refundPercent: quote.percent,
      refundAmount: quote.amount,
      requestedAt: DateTime.now(),
    );
    state = [...state, request];
    return request;
  }

  CancellationWorkflowRequest? findByBookingId(int bookingId) {
    for (final request in state) {
      if (request.bookingId == bookingId) return request;
    }
    return null;
  }

  void hostAcknowledge(int bookingId) {
    _update(bookingId, (request) => request.copyWith(hostAcknowledged: true));
  }

  void adminApprove(int bookingId) {
    _update(bookingId, (request) => request.copyWith(adminApproved: true));
  }

  void adminMarkRefundSent(int bookingId) {
    final request = findByBookingId(bookingId);
    if (request == null || !request.adminApproved) return;
    _update(bookingId, (item) => item.copyWith(refundSent: true));
  }

  void customerConfirmReceived(int bookingId) {
    final request = findByBookingId(bookingId);
    if (request == null || !request.refundSent) return;
    _update(bookingId, (item) => item.copyWith(customerReceived: true));
  }

  void adminNotifyHost(int bookingId) {
    final request = findByBookingId(bookingId);
    if (request == null || !request.customerReceived) return;
    _update(bookingId, (item) => item.copyWith(adminNotifiedHost: true));
  }

  void hostCompleteCancellation(int bookingId) {
    final request = findByBookingId(bookingId);
    if (request == null ||
        !request.hostAcknowledged ||
        !request.customerReceived ||
        !request.adminNotifiedHost) {
      return;
    }
    _update(bookingId, (item) => item.copyWith(hostCompleted: true));
  }

  void _update(
    int bookingId,
    CancellationWorkflowRequest Function(CancellationWorkflowRequest) update,
  ) {
    state = [
      for (final request in state)
        if (request.bookingId == bookingId) update(request) else request,
    ];
  }
}

final cancellationViewModelProvider =
    NotifierProvider<CancellationViewModel, List<CancellationWorkflowRequest>>(
      CancellationViewModel.new,
    );
