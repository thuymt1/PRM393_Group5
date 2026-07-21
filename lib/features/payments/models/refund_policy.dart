class RefundQuote {
  const RefundQuote({
    required this.daysUntilCheckIn,
    required this.percent,
    required this.totalPrice,
  });

  final int daysUntilCheckIn;
  final int percent;
  final double totalPrice;

  double get amount => totalPrice * percent / 100;

  bool get requiresTransfer => amount > 0;
}

abstract final class RefundPolicy {
  static RefundQuote calculate({
    required DateTime checkIn,
    required double totalPrice,
    DateTime? requestedAt,
  }) {
    final requestTime = requestedAt ?? DateTime.now();
    final requestDate = DateTime(
      requestTime.year,
      requestTime.month,
      requestTime.day,
    );
    final checkInDate = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final days = checkInDate.difference(requestDate).inDays;

    final percent = switch (days) {
      > 10 => 100,  // x > 10: hoàn 100%
      >= 7 => 70,   // 7 <= x <= 10: hoàn 70%
      >= 5 => 50,   // 5 <= x < 7: hoàn 50%
      >= 4 => 30,   // 3 < x < 5 (tức x = 4): hoàn 30%
      _ => 0,       // x <= 3: không hoàn tiền
    };

    return RefundQuote(
      daysUntilCheckIn: days,
      percent: percent,
      totalPrice: totalPrice,
    );
  }
}
