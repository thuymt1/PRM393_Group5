import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/homestay_model.dart';
import '../../viewmodels/booking_viewmodel.dart';

class BookingFormScreen extends ConsumerStatefulWidget {
  final Homestay? homestay;
  const BookingFormScreen({super.key, this.homestay});

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  DateTimeRange? _selectedDateRange;
  int _guests = 2;

  @override
  Widget build(BuildContext context) {
    final homestay = widget.homestay;
    if (homestay == null) return const Scaffold(body: Center(child: Text('Lỗi: Không tìm thấy homestay')));

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Surface color
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
          onPressed: () => context.pop(),
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
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final imageUrl = homestay.images.isNotEmpty ? homestay.images[0] : 'https://images.unsplash.com/photo-1510798831971-661eb04b3739?q=80&w=1000';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homestay.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${homestay.address}, ${homestay.city}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${formatCurrency.format(homestay.pricePerNight)} / đêm',
                  style: const TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thời gian lưu trú',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showCustomDatePicker,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Color(0xFFE07A5F), size: 20),
                const SizedBox(width: 16),
                Text(
                  _selectedDateRange == null
                      ? 'Chọn ngày nhận & trả phòng'
                      : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                  style: TextStyle(
                    color: _selectedDateRange == null ? Colors.grey.shade400 : Colors.black,
                    fontWeight: _selectedDateRange == null ? FontWeight.normal : FontWeight.bold,
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
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  Widget _buildGuestSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số lượng khách',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
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
              const Text('Người lớn / Trẻ em', style: TextStyle(color: Colors.grey)),
              Row(
                children: [
                  _circleActionButton(Icons.remove, () => setState(() => _guests = _guests > 1 ? _guests - 1 : 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('$_guests', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6D4C41))),
                  ),
                  _circleActionButton(Icons.add, () => setState(() => _guests++)),
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

    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final basePrice = homestay.pricePerNight * nights;
    final serviceFee = 50000.0;
    final totalPrice = basePrice + serviceFee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE07A5F).withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _priceRow('${formatCurrency.format(homestay.pricePerNight)} x $nights đêm', formatCurrency.format(basePrice)),
          const SizedBox(height: 10),
          _priceRow('Phí dịch vụ', formatCurrency.format(serviceFee)),
          const Divider(height: 32, color: Color(0xFFE07A5F)),
          _priceRow('Tổng cộng', formatCurrency.format(totalPrice), isBold: true),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? Colors.black : Colors.grey.shade700, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
        Text(val, style: TextStyle(fontSize: isBold ? 20 : 15, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: isBold ? const Color(0xFFE07A5F) : Colors.black)),
      ],
    );
  }

  Widget _buildSubmitButton(Homestay homestay) {
    return ElevatedButton(
      onPressed: _selectedDateRange != null ? () {
        int nights = _selectedDateRange!.duration.inDays;
        if (nights == 0) nights = 1;
        final basePrice = homestay.pricePerNight * nights;
        final serviceFee = 50000.0;
        final totalPrice = basePrice + serviceFee;

        final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        final checkIn = dateFormat.format(_selectedDateRange!.start);
        final checkOut = dateFormat.format(_selectedDateRange!.end);

        final payload = {
          'homestayId': homestay.id,
          'homestayName': homestay.name,
          'checkIn': checkIn,
          'checkOut': checkOut,
          'guests': _guests,
          'basePrice': basePrice,
          'serviceFee': serviceFee,
          'totalPrice': totalPrice,
        };

        context.push('/booking-confirmation', extra: payload);
      } : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: const Color(0xFF6D4C41).withValues(alpha: 0.3),
      ),
      child: const Text(
        'Tiếp tục xác nhận',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
