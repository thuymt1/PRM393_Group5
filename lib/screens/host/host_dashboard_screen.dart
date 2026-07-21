import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/repository_providers.dart';
import '../../models/homestay_model.dart';
import '../../features/host/viewmodels/host_dashboard_view_model.dart';

const _hostBackground = Color(0xFFFAF6EA);
const _hostBrown = Color(0xFF6D4C41);
const _hostOrange = Color(0xFFE07A5F);
const _hostText = Color(0xFF3F3733);

enum _BookingSort { newest, oldest, guestName, priceHigh }

enum _HomestaySort { newest, nameAsc, nameDesc, priceLow, priceHigh }

// Màn hình bảng điều khiển chính dành cho luồng giao diện Chủ nhà (Host Dashboard)
class HostDashboardScreen extends ConsumerStatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  ConsumerState<HostDashboardScreen> createState() =>
      _HostDashboardScreenState();
}

class _HostDashboardScreenState extends ConsumerState<HostDashboardScreen> {
  int _currentIndex = 0;
  final Set<int> _updatingBookingIds = <int>{};
  final TextEditingController _bookingSearchController =
      TextEditingController();
  final TextEditingController _homestaySearchController =
      TextEditingController();
  String _bookingQuery = '';
  String _bookingStatusFilter = 'all';
  _BookingSort _bookingSort = _BookingSort.newest;
  String _homestayQuery = '';
  String _homestayStatusFilter = 'all';
  _HomestaySort _homestaySort = _HomestaySort.newest;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _refreshDashboard() async {
    await ref.read(hostDashboardViewModelProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _bookingSearchController.dispose();
    _homestaySearchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterBookings(
    List<Map<String, dynamic>> bookings,
  ) {
    final query = _bookingQuery.trim().toLowerCase();
    final filtered = bookings
        .where((booking) {
          final status = booking['status']?.toString() ?? '';
          final matchesStatus = switch (_bookingStatusFilter) {
            'cancel' => const {
              'cancel_pending',
              'cancelled',
              'refunded',
            }.contains(status),
            'all' => true,
            _ => status == _bookingStatusFilter,
          };
          if (!matchesStatus) return false;
          if (query.isEmpty) return true;

          final profile = booking['profiles'] is Map
              ? booking['profiles'] as Map
              : const <String, dynamic>{};
          final homestay = booking['homestays'] is Map
              ? booking['homestays'] as Map
              : const <String, dynamic>{};
          final searchableText = [
            booking['id'],
            profile['full_name'],
            profile['email'],
            homestay['name'],
            booking['check_in'],
            booking['check_out'],
          ].whereType<Object>().join(' ').toLowerCase();
          return searchableText.contains(query);
        })
        .toList(growable: false);

    final sorted = [...filtered];
    int compareCreatedAt(
      Map<String, dynamic> left,
      Map<String, dynamic> right,
    ) {
      final leftDate = DateTime.tryParse(left['created_at']?.toString() ?? '');
      final rightDate = DateTime.tryParse(
        right['created_at']?.toString() ?? '',
      );
      return (leftDate ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
        rightDate ?? DateTime.fromMillisecondsSinceEpoch(0),
      );
    }

    double priceOf(Map<String, dynamic> booking) {
      final price = booking['total_price'];
      return price is num
          ? price.toDouble()
          : double.tryParse(price?.toString() ?? '') ?? 0;
    }

    String guestNameOf(Map<String, dynamic> booking) {
      final profile = booking['profiles'];
      if (profile is! Map) return '';
      return profile['full_name']?.toString().toLowerCase() ?? '';
    }

    sorted.sort(
      (left, right) => switch (_bookingSort) {
        _BookingSort.oldest => compareCreatedAt(left, right),
        _BookingSort.guestName => guestNameOf(
          left,
        ).compareTo(guestNameOf(right)),
        _BookingSort.priceHigh => priceOf(right).compareTo(priceOf(left)),
        _BookingSort.newest => compareCreatedAt(right, left),
      },
    );
    return sorted;
  }

  List<Homestay> _filterHomestays(List<Homestay> homestays) {
    final query = _homestayQuery.trim().toLowerCase();
    final filtered = homestays
        .where((homestay) {
          final matchesStatus = switch (_homestayStatusFilter) {
            'active' => homestay.status == 'active',
            'hidden' => homestay.status != 'active',
            _ => true,
          };
          if (!matchesStatus) return false;
          if (query.isEmpty) return true;

          return [
            homestay.name,
            homestay.address,
            homestay.city,
            homestay.category,
          ].join(' ').toLowerCase().contains(query);
        })
        .toList(growable: false);

    final sorted = [...filtered];
    sorted.sort(
      (left, right) => switch (_homestaySort) {
        _HomestaySort.nameAsc => left.name.toLowerCase().compareTo(
          right.name.toLowerCase(),
        ),
        _HomestaySort.nameDesc => right.name.toLowerCase().compareTo(
          left.name.toLowerCase(),
        ),
        _HomestaySort.priceLow => left.pricePerNight.compareTo(
          right.pricePerNight,
        ),
        _HomestaySort.priceHigh => right.pricePerNight.compareTo(
          left.pricePerNight,
        ),
        _HomestaySort.newest => right.id.compareTo(left.id),
      },
    );
    return sorted;
  }

  Widget _buildLoadingState() => const Center(
    child: CircularProgressIndicator(color: _hostOrange, strokeWidth: 2.5),
  );

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Color(0xFFB39A8B),
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              'Chưa thể tải dữ liệu',
              style: TextStyle(
                color: _hostText,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF8C8079), fontSize: 12),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _refreshDashboard,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Thử lại'),
              style: OutlinedButton.styleFrom(foregroundColor: _hostBrown),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    return switch (_currentIndex) {
      1 => _buildBookingRequestsTab(),
      2 => _buildMyHomestaysTab(),
      3 => _buildProfileTab(),
      _ => _buildDashboardTab(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _hostBackground,
      body: SafeArea(child: _buildCurrentTab()),
      // Nút nổi thêm homestay mới (được hiển thị trên Tab 0 và Tab 2)
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 2)
          ? FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, '/add-homestay-basic-info'),
              backgroundColor: _hostOrange,
              elevation: 2,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Đăng homestay',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- 1. TAB BẢNG ĐIỀU KHIỂN (DASHBOARD TAB) ---
  Widget _buildDashboardTab() {
    return ref
        .watch(hostDashboardViewModelProvider)
        .when(
          loading: _buildLoadingState,
          error: (error, _) => _buildErrorState(error),
          data: (dashboard) {
            final bookings = dashboard.bookings
                .whereType<Map>()
                .map(Map<String, dynamic>.from)
                .toList(growable: false);
            final homestays = dashboard.homestays;

            double monthlyEarnings = 0.0;
            var confirmedBookings = 0;
            var pendingBookings = 0;
            var cancellationBookings = 0;
            for (final booking in bookings) {
              if (booking['status'] == 'confirmed') {
                final price = booking['total_price'];
                monthlyEarnings += price is num
                    ? price.toDouble()
                    : double.tryParse(price?.toString() ?? '') ?? 0;
                confirmedBookings++;
              } else if (booking['status'] == 'pending') {
                pendingBookings++;
              } else if (booking['status'] == 'cancel_pending') {
                cancellationBookings++;
              }
            }

            final highlightedBooking = bookings.firstWhere(
              (booking) => booking['status'] == 'pending',
              orElse: () =>
                  bookings.isNotEmpty ? bookings.first : <String, dynamic>{},
            );

            final String formattedEarnings = monthlyEarnings
                .toInt()
                .toString()
                .replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]}.',
                );

            return RefreshIndicator(
              onRefresh: _refreshDashboard,
              color: const Color(0xFFE07A5F),
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
                          _buildHeader('Không gian chủ nhà'),
                          const SizedBox(height: 18),
                          _buildEarningsCard(
                            formattedEarnings,
                            pendingBookings,
                          ),
                          const SizedBox(height: 20),
                          _buildStatsGrid(
                            confirmedBookings,
                            homestays.length,
                            pendingBookings,
                            cancellationBookings,
                          ),
                          const SizedBox(height: 28),
                          _buildSectionHeader(
                            pendingBookings > 0
                                ? 'Cần bạn xử lý'
                                : 'Đơn đặt gần đây',
                            () => _onTabTapped(1),
                          ),
                          const SizedBox(height: 10),
                          highlightedBooking.isEmpty
                              ? _buildEmptyState(
                                  'Chưa có yêu cầu đặt phòng nào.',
                                  Icons.event_available_outlined,
                                )
                              : _buildBookingRequestItem(highlightedBooking),
                          const SizedBox(height: 28),
                          _buildSectionHeader(
                            'Homestay của tôi',
                            () => _onTabTapped(2),
                          ),
                          const SizedBox(height: 10),
                          homestays.isEmpty
                              ? _buildEmptyState(
                                  'Bạn chưa đăng homestay nào.',
                                  Icons.add_home_work_outlined,
                                )
                              : _buildMyHomestayCard(homestays.first),
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

  Widget _buildHeader(String title) {
    final user = ref.read(authRepositoryProvider).currentUser;
    final String email = user?.email ?? 'host@example.com';
    final initial = email.trim().isEmpty ? 'H' : email.trim()[0].toUpperCase();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _hostBrown,
                  fontWeight: FontWeight.w700,
                  fontSize: 23,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
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
                  color: _hostBrown,
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
                  color: _hostBrown,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningsCard(String earningsStr, int pendingBookings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _hostBrown,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _hostBrown.withValues(alpha: 0.18),
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
            '$earningsStr đ',
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

  Widget _buildStatsGrid(
    int confirmedBookings,
    int homestaysCount,
    int pendingBookings,
    int cancellationBookings,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: constraints.maxWidth >= 720 ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: constraints.maxWidth >= 720 ? 1.35 : 1.45,
        children: [
          _statItem('Homestay', '$homestaysCount', Icons.home_work_outlined),
          _statItem('Chờ duyệt', '$pendingBookings', Icons.schedule_outlined),
          _statItem(
            'Đã xác nhận',
            '$confirmedBookings',
            Icons.check_circle_outline,
          ),
          _statItem(
            'Chờ hoàn tiền',
            '$cancellationBookings',
            Icons.currency_exchange_outlined,
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String val, IconData icon) {
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
          Icon(icon, color: _hostOrange, size: 22),
          const SizedBox(height: 8),
          Text(
            val,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _hostText,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text(
            'Xem tất cả',
            style: TextStyle(
              color: Color(0xFFE07A5F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE4D8)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFC9B8AD), size: 30),
          const SizedBox(height: 10),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8C8079), fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _bookingStatusLabel(String status) => switch (status) {
    'pending' => 'Chờ Host duyệt',
    'confirmed' => 'Đã xác nhận',
    'rejected' => 'Đã từ chối',
    'cancel_pending' => 'Admin đang xử lý',
    'cancelled' => 'Đã hủy',
    'refunded' => 'Đã hoàn tiền',
    _ => 'Đang xử lý',
  };

  Color _bookingStatusColor(String status) => switch (status) {
    'confirmed' => const Color(0xFF3F7D5A),
    'rejected' || 'cancelled' => const Color(0xFFB6534D),
    'refunded' => const Color(0xFF4F7194),
    'cancel_pending' => const Color(0xFFB56635),
    _ => const Color(0xFFC46C35),
  };

  Widget _buildAvatar(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return const CircleAvatar(
        radius: 21,
        backgroundColor: Color(0xFFF2E8E1),
        child: Icon(Icons.person_outline, color: _hostBrown, size: 22),
      );
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(
          color: Color(0xFFF2E8E1),
          child: SizedBox.square(
            dimension: 42,
            child: Icon(Icons.person_outline, color: _hostBrown, size: 22),
          ),
        ),
      ),
    );
  }

  // Khối vẽ Item yêu cầu đặt phòng (booking)
  Widget _buildBookingRequestItem(Map<String, dynamic> booking) {
    final profile = booking['profiles'] is Map
        ? Map<String, dynamic>.from(booking['profiles'] as Map)
        : null;
    final homestay = booking['homestays'] is Map
        ? Map<String, dynamic>.from(booking['homestays'] as Map)
        : null;
    final clientName = profile?['full_name']?.toString().trim();
    final homestayName = homestay?['name']?.toString().trim();
    final status = booking['status']?.toString() ?? 'pending';
    final statusColor = _bookingStatusColor(status);
    final checkIn = DateTime.tryParse(booking['check_in']?.toString() ?? '');
    final checkOut = DateTime.tryParse(booking['check_out']?.toString() ?? '');
    final nights = checkIn == null || checkOut == null
        ? 0
        : checkOut.difference(checkIn).inDays;
    final bookingId = int.tryParse(booking['id']?.toString() ?? '');
    final isUpdating =
        bookingId != null && _updatingBookingIds.contains(bookingId);

    return InkWell(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          '/host-booking-detail',
          arguments: booking,
        );
        if (result == true) {
          await _refreshDashboard();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDE4D8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(profile?['avatar_url']?.toString()),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clientName == null || clientName.isEmpty
                            ? 'Khách hàng ẩn danh'
                            : clientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${nights > 0 ? '$nights đêm' : 'Chưa rõ thời gian'} • ${homestayName == null || homestayName.isEmpty ? 'Homestay' : homestayName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _bookingStatusLabel(status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: bookingId == null || isUpdating
                        ? null
                        : () => _updateStatus(bookingId, 'rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Từ chối',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: bookingId == null || isUpdating
                        ? null
                        : () => _updateStatus(bookingId, 'confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hostBrown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isUpdating
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Phê duyệt',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateStatus(int bookingId, String status) async {
    if (_updatingBookingIds.contains(bookingId)) return;
    setState(() => _updatingBookingIds.add(bookingId));
    try {
      await ref
          .read(hostDashboardViewModelProvider.notifier)
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cập nhật thất bại: $e')));
    } finally {
      if (mounted) {
        setState(() => _updatingBookingIds.remove(bookingId));
      }
    }
  }

  Widget _buildMyHomestayCard(Homestay homestay) {
    final String imageUrl = homestay.images.isNotEmpty
        ? homestay.images.first
        : '';
    final isActive = homestay.status == 'active';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE4D8)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            child: imageUrl.isEmpty
                ? const SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: ColoredBox(
                      color: Color(0xFFF1E8DC),
                      child: Icon(
                        Icons.cottage_outlined,
                        color: Color(0xFFB39A8B),
                        size: 44,
                      ),
                    ),
                  )
                : Image.network(
                    imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: ColoredBox(
                        color: Color(0xFFF1E8DC),
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Color(0xFFB39A8B),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homestay.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: _hostText,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: isActive
                                ? const Color(0xFF4D8664)
                                : const Color(0xFF9B8F88),
                            size: 8,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isActive ? 'Đang hoạt động' : 'Tạm ẩn',
                            style: TextStyle(
                              color: isActive
                                  ? const Color(0xFF4D8664)
                                  : const Color(0xFF776C66),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${homestay.pricePerNight.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _hostOrange,
                      ),
                    ),
                    const Text(
                      'mỗi đêm',
                      style: TextStyle(color: Color(0xFF948780), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSearch({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    required VoidCallback onClear,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFA19791), fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: _hostOrange),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Xóa tìm kiếm',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 19),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE7DDD3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE7DDD3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _hostOrange, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFilterChoice({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        selectedColor: const Color(0xFFF1DDD4),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? _hostOrange : const Color(0xFFE7DDD3),
        ),
        labelStyle: TextStyle(
          color: selected ? _hostBrown : const Color(0xFF776C66),
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSortButton<T>({
    required String label,
    required T selected,
    required List<PopupMenuEntry<T>> items,
    required ValueChanged<T> onSelected,
  }) {
    return PopupMenuButton<T>(
      initialValue: selected,
      onSelected: onSelected,
      itemBuilder: (_) => items,
      tooltip: 'Sắp xếp',
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFE7DDD3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded, size: 18, color: _hostBrown),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: _hostBrown,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _bookingSortLabel => switch (_bookingSort) {
    _BookingSort.newest => 'Mới nhất',
    _BookingSort.oldest => 'Cũ nhất',
    _BookingSort.guestName => 'Tên A–Z',
    _BookingSort.priceHigh => 'Giá cao',
  };

  String get _homestaySortLabel => switch (_homestaySort) {
    _HomestaySort.newest => 'Mới nhất',
    _HomestaySort.nameAsc => 'Tên A–Z',
    _HomestaySort.nameDesc => 'Tên Z–A',
    _HomestaySort.priceLow => 'Giá thấp',
    _HomestaySort.priceHigh => 'Giá cao',
  };

  Widget _buildBookingListTools(int visibleCount, int totalCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildListSearch(
            controller: _bookingSearchController,
            hint: 'Tìm khách, homestay hoặc mã đơn...',
            onChanged: (value) => setState(() => _bookingQuery = value),
            onClear: () {
              _bookingSearchController.clear();
              setState(() => _bookingQuery = '');
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChoice(
                        label: 'Tất cả',
                        selected: _bookingStatusFilter == 'all',
                        onSelected: () =>
                            setState(() => _bookingStatusFilter = 'all'),
                      ),
                      _buildFilterChoice(
                        label: 'Chờ duyệt',
                        selected: _bookingStatusFilter == 'pending',
                        onSelected: () =>
                            setState(() => _bookingStatusFilter = 'pending'),
                      ),
                      _buildFilterChoice(
                        label: 'Đã xác nhận',
                        selected: _bookingStatusFilter == 'confirmed',
                        onSelected: () =>
                            setState(() => _bookingStatusFilter = 'confirmed'),
                      ),
                      _buildFilterChoice(
                        label: 'Hủy/hoàn tiền',
                        selected: _bookingStatusFilter == 'cancel',
                        onSelected: () =>
                            setState(() => _bookingStatusFilter = 'cancel'),
                      ),
                      _buildFilterChoice(
                        label: 'Đã từ chối',
                        selected: _bookingStatusFilter == 'rejected',
                        onSelected: () =>
                            setState(() => _bookingStatusFilter = 'rejected'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildSortButton<_BookingSort>(
                label: _bookingSortLabel,
                selected: _bookingSort,
                onSelected: (value) => setState(() => _bookingSort = value),
                items: const [
                  PopupMenuItem(
                    value: _BookingSort.newest,
                    child: Text('Mới nhất'),
                  ),
                  PopupMenuItem(
                    value: _BookingSort.oldest,
                    child: Text('Cũ nhất'),
                  ),
                  PopupMenuItem(
                    value: _BookingSort.guestName,
                    child: Text('Tên khách A–Z'),
                  ),
                  PopupMenuItem(
                    value: _BookingSort.priceHigh,
                    child: Text('Giá cao nhất'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$visibleCount/$totalCount đơn đặt phòng',
            style: const TextStyle(color: Color(0xFF8C8079), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHomestayListTools(int visibleCount, int totalCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildListSearch(
            controller: _homestaySearchController,
            hint: 'Tìm tên, địa chỉ hoặc thành phố...',
            onChanged: (value) => setState(() => _homestayQuery = value),
            onClear: () {
              _homestaySearchController.clear();
              setState(() => _homestayQuery = '');
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChoice(
                        label: 'Tất cả',
                        selected: _homestayStatusFilter == 'all',
                        onSelected: () =>
                            setState(() => _homestayStatusFilter = 'all'),
                      ),
                      _buildFilterChoice(
                        label: 'Đang hoạt động',
                        selected: _homestayStatusFilter == 'active',
                        onSelected: () =>
                            setState(() => _homestayStatusFilter = 'active'),
                      ),
                      _buildFilterChoice(
                        label: 'Tạm ẩn',
                        selected: _homestayStatusFilter == 'hidden',
                        onSelected: () =>
                            setState(() => _homestayStatusFilter = 'hidden'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildSortButton<_HomestaySort>(
                label: _homestaySortLabel,
                selected: _homestaySort,
                onSelected: (value) => setState(() => _homestaySort = value),
                items: const [
                  PopupMenuItem(
                    value: _HomestaySort.newest,
                    child: Text('Mới đăng'),
                  ),
                  PopupMenuItem(
                    value: _HomestaySort.nameAsc,
                    child: Text('Tên A–Z'),
                  ),
                  PopupMenuItem(
                    value: _HomestaySort.nameDesc,
                    child: Text('Tên Z–A'),
                  ),
                  PopupMenuItem(
                    value: _HomestaySort.priceLow,
                    child: Text('Giá thấp đến cao'),
                  ),
                  PopupMenuItem(
                    value: _HomestaySort.priceHigh,
                    child: Text('Giá cao đến thấp'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$visibleCount/$totalCount homestay',
            style: const TextStyle(color: Color(0xFF8C8079), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults({
    required String message,
    required VoidCallback onReset,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 68, 24, 24),
      children: [
        const Icon(
          Icons.manage_search_rounded,
          size: 58,
          color: Color(0xFFC8B8AE),
        ),
        const SizedBox(height: 14),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF776C66), fontSize: 14),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Xóa bộ lọc'),
            style: TextButton.styleFrom(foregroundColor: _hostOrange),
          ),
        ),
      ],
    );
  }

  // --- 2. TAB YÊU CẦU ĐẶT PHÒNG (BOOKINGS TAB) ---
  Widget _buildBookingRequestsTab() {
    return ref
        .watch(hostDashboardViewModelProvider)
        .when(
          loading: _buildLoadingState,
          error: (error, _) => _buildErrorState(error),
          data: (dashboard) {
            final bookings = dashboard.bookings
                .whereType<Map>()
                .map(Map<String, dynamic>.from)
                .toList(growable: false);
            final visibleBookings = _filterBookings(bookings);

            return Scaffold(
              backgroundColor: _hostBackground,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Đơn đặt phòng',
                  style: TextStyle(
                    color: _hostBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    children: [
                      _buildBookingListTools(
                        visibleBookings.length,
                        bookings.length,
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refreshDashboard,
                          color: _hostOrange,
                          child: bookings.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    72,
                                    20,
                                    20,
                                  ),
                                  children: [
                                    Icon(
                                      Icons.event_note_outlined,
                                      size: 64,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Chưa nhận được yêu cầu nào.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF8C8079),
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                )
                              : visibleBookings.isEmpty
                              ? _buildNoSearchResults(
                                  message:
                                      'Không tìm thấy đơn phù hợp với điều kiện hiện tại.',
                                  onReset: () {
                                    _bookingSearchController.clear();
                                    setState(() {
                                      _bookingQuery = '';
                                      _bookingStatusFilter = 'all';
                                      _bookingSort = _BookingSort.newest;
                                    });
                                  },
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    4,
                                    20,
                                    96,
                                  ),
                                  itemCount: visibleBookings.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    return _buildBookingRequestItem(
                                      visibleBookings[index],
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
  }

  // --- 3. TAB NHÀ CỦA TÔI (MY HOMESTAYS TAB) ---
  Widget _buildMyHomestaysTab() {
    return ref
        .watch(hostDashboardViewModelProvider)
        .when(
          loading: _buildLoadingState,
          error: (error, _) => _buildErrorState(error),
          data: (dashboard) {
            final homestays = dashboard.homestays;
            final visibleHomestays = _filterHomestays(homestays);

            return Scaffold(
              backgroundColor: _hostBackground,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Homestay của tôi',
                  style: TextStyle(
                    color: _hostBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    children: [
                      _buildHomestayListTools(
                        visibleHomestays.length,
                        homestays.length,
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refreshDashboard,
                          color: _hostOrange,
                          child: homestays.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    68,
                                    20,
                                    20,
                                  ),
                                  children: [
                                    Icon(
                                      Icons.add_home_work_outlined,
                                      size: 64,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Bạn chưa đăng homestay nào.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF8C8079),
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                )
                              : visibleHomestays.isEmpty
                              ? _buildNoSearchResults(
                                  message:
                                      'Không tìm thấy homestay phù hợp với điều kiện hiện tại.',
                                  onReset: () {
                                    _homestaySearchController.clear();
                                    setState(() {
                                      _homestayQuery = '';
                                      _homestayStatusFilter = 'all';
                                      _homestaySort = _HomestaySort.newest;
                                    });
                                  },
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    4,
                                    20,
                                    96,
                                  ),
                                  itemCount: visibleHomestays.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: _buildMyHomestayCard(
                                        visibleHomestays[index],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
  }

  // --- 4. TAB HỒ SƠ & MENU (PROFILE TAB) ---
  Widget _buildProfileTab() {
    return ref
        .watch(hostDashboardViewModelProvider)
        .when(
          loading: _buildLoadingState,
          error: (error, _) => _buildErrorState(error),
          data: (dashboard) {
            final profile = dashboard.profile;
            final currentUser = ref.read(authRepositoryProvider).currentUser;

            final String rawName = profile?['full_name'] ?? '';
            final String fullName = rawName.isEmpty
                ? (currentUser?.email?.split('@').first ?? 'Người dùng')
                : rawName;

            final String rawEmail = profile?['email'] ?? '';
            final String email = rawEmail.isEmpty
                ? (currentUser?.email ?? 'Chưa cập nhật email')
                : rawEmail;

            final String rawPhone = profile?['phone'] ?? '';
            final String phone = rawPhone.isEmpty
                ? 'Chưa cập nhật SĐT'
                : rawPhone;

            final String? avatarUrl = profile?['avatar_url'];

            return Scaffold(
              backgroundColor: _hostBackground,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Menu & Hồ sơ',
                  style: TextStyle(
                    color: _hostBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildProfileAvatar(avatarUrl, fullName),
                          const SizedBox(height: 16),
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF424242),
                            ),
                          ),
                          Text(
                            email,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _hostOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified,
                                  color: Color(0xFFE07A5F),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Chủ nhà',
                                  style: TextStyle(
                                    color: Color(0xFFE07A5F),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildContactRow(
                            Icons.phone_iphone,
                            'Số điện thoại',
                            phone,
                          ),
                          const Divider(height: 24),
                          _buildContactRow(
                            Icons.email_outlined,
                            'Email liên hệ',
                            email,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _confirmSignOut,
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Đăng xuất',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4C41),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        shadowColor: _hostBrown.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
  }

  Widget _buildContactRow(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6D4C41), size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              val,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF424242),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(String? imageUrl, String fullName) {
    final initial = fullName.trim().isEmpty
        ? 'H'
        : fullName.trim()[0].toUpperCase();
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return CircleAvatar(
        radius: 52,
        backgroundColor: const Color(0xFFF1DDD4),
        child: Text(
          initial,
          style: const TextStyle(
            color: _hostBrown,
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 104,
        height: 104,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => ColoredBox(
          color: const Color(0xFFF1DDD4),
          child: SizedBox.square(
            dimension: 104,
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: _hostBrown,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn sẽ cần đăng nhập lại để quản lý homestay.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Ở lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: _hostBrown),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (shouldSignOut != true || !mounted) return;

    await ref.read(authRepositoryProvider).signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // --- BOTOMNAVBAR DÀNH CHO HOST ---
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 10,
      selectedItemColor: _hostOrange,
      unselectedItemColor: const Color(0xFF9C928C),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Tổng quan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Đơn đặt',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_work_outlined),
          activeIcon: Icon(Icons.home_work),
          label: 'Chỗ nghỉ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
    );
  }
}
