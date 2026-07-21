import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/homestay_model.dart';
import '../../features/customer/viewmodels/booking_form_view_model.dart';

class BookingFormScreen extends ConsumerStatefulWidget {
  const BookingFormScreen({super.key});

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  DateTimeRange? _selectedDateRange;
  int _guests = 2;
  bool get _isCheckingAvailability =>
      ref.read(bookingFormViewModelProvider).isCheckingAvailability;
  bool get _isDateAvailable =>
      ref.read(bookingFormViewModelProvider).isDateAvailable;
  List<DateTimeRange>? get _bookedDates => ref
      .read(bookingFormViewModelProvider)
      .bookedDates
      ?.map((range) => DateTimeRange(start: range.start, end: range.end))
      .toList();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bookedDates == null) {
      final homestay = ModalRoute.of(context)!.settings.arguments as Homestay;
      _loadBookedDates(homestay.id);
    }
  }

  Future<void> _loadBookedDates(int homestayId) async {
    await ref
        .read(bookingFormViewModelProvider.notifier)
        .loadBookedDates(homestayId);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(bookingFormViewModelProvider);
    final homestay = ModalRoute.of(context)!.settings.arguments as Homestay;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Surface color
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đặt phòng',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHomestayBrief(homestay),
            const SizedBox(height: 32),
            _buildDatePickerSection(),
            const SizedBox(height: 24),
            _buildGuestSelector(),
            const SizedBox(height: 32),
            _buildPricePreview(homestay),
            const SizedBox(height: 40),
            _buildSubmitButton(homestay),
          ],
        ),
      ),
    );
  }

  Widget _buildHomestayBrief(Homestay homestay) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            homestay.images.isNotEmpty
                ? homestay.images[0]
                : 'https://via.placeholder.com/150',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 100,
              height: 100,
              color: Colors.grey.shade300,
              child: const Icon(Icons.home, color: Colors.white, size: 40),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                homestay.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D4C41),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    homestay.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6D4C41),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_formatPrice(homestay.pricePerNight)}đ / đêm',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE07A5F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildDatePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Thời gian ở',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D4C41),
              ),
            ),
            if (_isCheckingAvailability)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFE07A5F),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '* Chú thích: Những ngày tô màu xám nhạt là ngày đã có người đặt trước.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            if (_bookedDates == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang tải dữ liệu ngày trống, vui lòng đợi...'),
                ),
              );
              return;
            }
            _showCustomDatePicker();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isDateAvailable ? Colors.grey.shade200 : Colors.red,
                width: _isDateAvailable ? 1 : 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Color(0xFFE07A5F)),
                const SizedBox(width: 12),
                Text(
                  _selectedDateRange != null
                      ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}'
                      : 'Chọn ngày nhận và trả phòng',
                  style: TextStyle(
                    color: _selectedDateRange == null
                        ? Colors.grey.shade400
                        : Colors.black,
                    fontWeight: _selectedDateRange == null
                        ? FontWeight.normal
                        : FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCustomDatePicker() async {
    final homestay = ModalRoute.of(context)!.settings.arguments as Homestay;

    // Normalize date to ignore time component when comparing
    DateTime normalizeDate(DateTime date) =>
        DateTime(date.year, date.month, date.day);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate:
          (
            DateTime day,
            DateTime? currentSelectionStart,
            DateTime? currentSelectionEnd,
          ) {
            if (_bookedDates == null) return true; // Safety check
            final targetDay = normalizeDate(day);

            for (var range in _bookedDates!) {
              final start = normalizeDate(range.start);
              final end = normalizeDate(range.end);
              if (targetDay.isAfter(start.subtract(const Duration(days: 1))) &&
                  targetDay.isBefore(end)) {
                return false; // Day is disabled (greyed out)
              }
            }
            return true; // Available
          },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE07A5F),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF6D4C41),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });

      final available = await ref
          .read(bookingFormViewModelProvider.notifier)
          .checkAvailability(
            homestayId: homestay.id,
            checkIn: picked.start,
            checkOut: picked.end,
          );

      if (!mounted) return;

      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Homestay đã có người đặt trong khoảng ngày này. Vui lòng chọn ngày khác.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        setState(() => _selectedDateRange = null);
      }
    }
  }

  Widget _buildGuestSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số lượng khách',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Người lớn / Trẻ em',
                style: TextStyle(color: Colors.grey),
              ),
              Row(
                children: [
                  _circleActionButton(
                    Icons.remove,
                    () =>
                        setState(() => _guests = _guests > 1 ? _guests - 1 : 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_guests',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF6D4C41),
                      ),
                    ),
                  ),
                  _circleActionButton(
                    Icons.add,
                    () => setState(() => _guests++),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _circleActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF6D4C41)),
      ),
    );
  }

  Widget _buildPricePreview(Homestay homestay) {
    if (_selectedDateRange == null) return const SizedBox();
    int nights = _selectedDateRange!.duration.inDays;
    if (nights == 0) nights = 1; // Tối thiểu 1 đêm

    final double rawRoomPrice = homestay.pricePerNight * nights;
    final double serviceFee = 50000;
    final double totalPrice = rawRoomPrice + serviceFee;

    final String roomPriceStr = rawRoomPrice
        .toInt()
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    final String serviceFeeStr = serviceFee.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    final String totalPriceStr = totalPrice.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    final String basePriceStr = homestay.pricePerNight
        .toInt()
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE07A5F).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _priceRow('${basePriceStr}đ x $nights đêm', '${roomPriceStr}đ'),
          const SizedBox(height: 10),
          _priceRow('Phí dịch vụ', '${serviceFeeStr}đ'),
          const Divider(height: 32, color: Color(0xFFE07A5F)),
          _priceRow('Tổng cộng', '${totalPriceStr}đ', isBold: true),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.black : Colors.grey.shade700,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: isBold ? 20 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? const Color(0xFFE07A5F) : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(Homestay homestay) {
    final hasSelectedDate =
        _selectedDateRange != null &&
        _isDateAvailable &&
        !_isCheckingAvailability;

    return ElevatedButton(
      onPressed: hasSelectedDate
          ? () {
              int nights = _selectedDateRange!.duration.inDays;
              if (nights == 0) nights = 1;
              final double totalPrice =
                  (homestay.pricePerNight * nights) + 50000;

              // Truyền thông tin đặt phòng qua route arguments
              Navigator.pushNamed(
                context,
                '/booking-confirmation',
                arguments: {
                  'homestay': homestay,
                  'checkIn': _selectedDateRange!.start,
                  'checkOut': _selectedDateRange!.end,
                  'guests': _guests,
                  'totalPrice': totalPrice,
                },
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41),
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade500,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
      ),
      child: const Text(
        'Tiếp tục xác nhận',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
