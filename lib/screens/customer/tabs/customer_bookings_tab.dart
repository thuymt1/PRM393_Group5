import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/customer/viewmodels/customer_home_view_model.dart';
import '../cancel_booking_page.dart';

class CustomerBookingsTab extends ConsumerStatefulWidget {
  const CustomerBookingsTab({super.key});

  @override
  ConsumerState<CustomerBookingsTab> createState() => _CustomerBookingsTabState();
}

class _CustomerBookingsTabState extends ConsumerState<CustomerBookingsTab> {
  String? _bookingFilter; // null = Tất cả

  Widget _buildBookingFilterChip(String label, String? statusValue) {
    final isSelected = _bookingFilter == statusValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _bookingFilter = statusValue;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6D4C41) : const Color(0xFFF5F0E8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6D4C41),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(customerHomeViewModelProvider).when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
          ),
          error: (error, _) => Center(child: Text('Lỗi tải dữ liệu: $error')),
          data: (homeState) {
            final allBookings = homeState.bookings;
            final bookings = _bookingFilter == null
                ? allBookings
                : allBookings
                    .where((b) => b['status'] == _bookingFilter)
                    .toList();

            return Scaffold(
              backgroundColor: const Color(0xFFFDFAE7),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                title: const Text(
                  'Chuyến đi của tôi',
                  style: TextStyle(
                    color: Color(0xFF6D4C41),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
              ),
              body: Column(
                children: [
                  // Thanh cuộn các tab lọc trạng thái đơn
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          _buildBookingFilterChip('Tất cả', null),
                          const SizedBox(width: 8),
                          _buildBookingFilterChip('Chờ xác nhận', 'pending'),
                          const SizedBox(width: 8),
                          _buildBookingFilterChip('Đã xác nhận', 'confirmed'),
                          const SizedBox(width: 8),
                          _buildBookingFilterChip('Chờ hoàn tiền', 'cancel_pending'),
                          const SizedBox(width: 8),
                          _buildBookingFilterChip('Đã hủy', 'cancelled'),
                          const SizedBox(width: 8),
                          _buildBookingFilterChip('Đã hoàn tiền', 'refunded'),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  // Danh sách booking đã lọc
                  Expanded(
                    child: bookings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_note_outlined,
                                  size: 80,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _bookingFilter == null
                                      ? 'Chưa có lịch sử đặt phòng nào'
                                      : 'Không có đơn nào trong mục này',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              final booking = bookings[index];
                              final homestay = booking['homestays'];
                              final checkIn = DateTime.parse(booking['check_in']);
                              final checkOut =
                                  DateTime.parse(booking['check_out']);
                              final double totalPrice =
                                  (booking['total_price'] ?? 0.0).toDouble();

                              String imageUrl =
                                  'https://images.unsplash.com/photo-1510798831971-661eb04b3739';
                              if (homestay != null &&
                                  homestay['homestay_images'] != null &&
                                  (homestay['homestay_images'] as List)
                                      .isNotEmpty) {
                                imageUrl = homestay['homestay_images'][0]['url'];
                              }

                              Color statusColor = Colors.orange;
                              String statusText = 'Đang xử lý';

                              if (booking['status'] == 'payment_pending') {
                                statusColor = Colors.orange;
                                statusText = 'Chờ Admin xác minh';
                              } else if (booking['status'] == 'pending') {
                                statusColor = Colors.blue;
                                statusText = 'Chờ xác nhận';
                              } else if (booking['status'] == 'confirmed') {
                                statusColor = Colors.green;
                                statusText = 'Đã xác nhận';
                              } else if (booking['status'] == 'cancelled') {
                                statusColor = Colors.red;
                                statusText = 'Đã hủy';
                              } else if (booking['status'] == 'cancel_pending') {
                                statusColor = Colors.deepOrange;
                                statusText = 'Chờ hoàn tiền';
                              } else if (booking['status'] == 'refunded') {
                                statusColor = Colors.blue;
                                statusText = 'Đã hoàn tiền';
                              }

                              final String checkInStr =
                                  '${checkIn.day}/${checkIn.month}/${checkIn.year}';
                              final String checkOutStr =
                                  '${checkOut.day}/${checkOut.month}/${checkOut.year}';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    final changed = await Navigator.pushNamed(
                                      context,
                                      '/customer-booking-detail',
                                      arguments: booking,
                                    );
                                    if (changed == true) {
                                      await ref
                                          .read(
                                            customerHomeViewModelProvider
                                                .notifier,
                                          )
                                          .refresh();
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(24),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(24),
                                        ),
                                        child: Stack(
                                          children: [
                                            Image.network(
                                              imageUrl,
                                              height: 140,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                height: 140,
                                                color: const Color(0xFFF7F4E1),
                                                child: const Icon(
                                                  Icons.home_outlined,
                                                  color: Color(0xFF6D4C41),
                                                  size: 48,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 12,
                                              right: 12,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  statusText,
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    homestay?['name'] ??
                                                        'The Terracotta Nest',
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF424242),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFE07A5F),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    '${homestay?['address'] ?? ''}, ${homestay?['city'] ?? ''}',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(height: 24),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 14,
                                                  color: Color(0xFF6D4C41),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '$checkInStr - $checkOutStr',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                    color: Color(0xFF6D4C41),
                                                  ),
                                                ),
                                                const Spacer(),
                                                // Chưa tới ngày check-out: hiện Hủy phòng
                                                if (booking['status'] ==
                                                        'confirmed' &&
                                                    checkOut.isAfter(
                                                        DateTime.now()))
                                                  TextButton(
                                                    onPressed: () async {
                                                      final changed =
                                                          await Navigator.push<
                                                              bool>(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              CancelBookingPage(
                                                            booking: Map<
                                                                    String,
                                                                    dynamic>.from(
                                                                booking as Map),
                                                          ),
                                                        ),
                                                      );
                                                      if (changed == true) {
                                                        ref
                                                            .read(
                                                              customerHomeViewModelProvider
                                                                  .notifier,
                                                            )
                                                            .refresh();
                                                      }
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size.zero,
                                                    ),
                                                    child: const Text(
                                                      'Hủy phòng',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                // Đã qua ngày check-out: hiện Đánh giá
                                                if (booking['status'] ==
                                                        'confirmed' &&
                                                    checkOut.isBefore(
                                                        DateTime.now()))
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/create-review',
                                                        arguments: booking,
                                                      );
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size.zero,
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.star_rounded,
                                                          color: Colors.amber,
                                                          size: 16,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          'Đánh giá',
                                                          style: TextStyle(
                                                            color:
                                                                Color(0xFFE07A5F),
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
  }
}
