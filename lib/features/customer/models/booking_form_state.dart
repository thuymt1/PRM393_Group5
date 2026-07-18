class BookedDateRange {
  const BookedDateRange({required this.start, required this.end});
  final DateTime start;
  final DateTime end;
}

class BookingFormState {
  const BookingFormState({
    this.bookedDates,
    this.isCheckingAvailability = false,
    this.isDateAvailable = true,
  });

  final List<BookedDateRange>? bookedDates;
  final bool isCheckingAvailability;
  final bool isDateAvailable;

  BookingFormState copyWith({
    List<BookedDateRange>? bookedDates,
    bool? isCheckingAvailability,
    bool? isDateAvailable,
  }) => BookingFormState(
    bookedDates: bookedDates ?? this.bookedDates,
    isCheckingAvailability:
        isCheckingAvailability ?? this.isCheckingAvailability,
    isDateAvailable: isDateAvailable ?? this.isDateAvailable,
  );
}
