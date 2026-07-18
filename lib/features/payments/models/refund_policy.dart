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
      >= 7 => 100,
      >= 3 => 70,
      >= 1 => 30,
      _ => 0,
    };

    return RefundQuote(
      daysUntilCheckIn: days,
      percent: percent,
      totalPrice: totalPrice,
    );
  }
}
