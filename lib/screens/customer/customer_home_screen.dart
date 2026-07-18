import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../data/repositories/repository_providers.dart';
import '../../models/homestay_model.dart';
import '../../features/customer/viewmodels/customer_home_view_model.dart';
import '../../features/customer/models/customer_home_state.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int _currentIndex = 0;
  bool _initialized = false;

  CustomerHomeState get _homeState =>
      ref.read(customerHomeViewModelProvider).value ??
      const CustomerHomeState();
  Set<int> get _favoriteHomestayIds => _homeState.favoriteIds;
  List<Homestay> get _homestays => _homeState.homestays;
  bool get _isLoadingHomestays =>
      ref.read(customerHomeViewModelProvider).isLoading ||
      _homeState.isLoadingMore;
  bool get _hasMoreHomestays => _homeState.hasMore;
  String get _searchQuery => _homeState.searchQuery;
  String get _selectedCategory => _homeState.category;
  final ScrollController _exploreScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _exploreScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _exploreScrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_exploreScrollController.position.pixels >=
        _exploreScrollController.position.maxScrollExtent - 200) {
      _loadMoreHomestays();
    }
  }

  Future<void> _loadHomestays({bool reset = false}) async {
    if (reset) {
      await ref.read(customerHomeViewModelProvider.notifier).refresh();
    } else {
      await ref.read(customerHomeViewModelProvider.notifier).loadMore();
    }
  }

  void _loadMoreHomestays() {
    if (!_hasMoreHomestays || _isLoadingHomestays) return;
    _loadHomestays();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref
          .read(customerHomeViewModelProvider.notifier)
          .applyFilter(search: value);
    });
  }

  void _onCategoryChanged(String category) {
    ref
        .read(customerHomeViewModelProvider.notifier)
        .applyFilter(category: category);
  }

  void _onLocationChipTapped(String location) {
    _searchController.text = location;
    ref
        .read(customerHomeViewModelProvider.notifier)
        .applyFilter(search: location);
  }

  Future<void> _loadFavorites() =>
      ref.read(customerHomeViewModelProvider.notifier).refresh();

  Future<void> _toggleFavorite(Homestay homestay) async {
    try {
      await ref
          .read(customerHomeViewModelProvider.notifier)
          .toggleFavorite(homestay);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật yêu thích: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Hàm chuyển đổi tab của Container chính
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _openEditProfile(String name, String phone) async {
    final navigator = Navigator.of(context);
    final result = await navigator.pushNamed(
      '/edit-profile',
      arguments: {'name': name, 'phone': phone},
    );

    if (result == true && mounted) {
      // Tải lại thông tin cá nhân
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(customerHomeViewModelProvider);
    if (!_initialized) {
      final initialTab = ModalRoute.of(context)?.settings.arguments as int?;
      if (initialTab != null) {
        _currentIndex = initialTab;
      }
      _initialized = true;
    }

    // 4 tab tương ứng: Khám phá, Yêu thích, Chuyến đi, Hồ sơ
    final List<Widget> tabs = [
      _buildExploreTab(),
      _buildFavoritesTab(),
      _buildBookingsTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(
        0xFFFDFAE7,
      ), // Surface color từ design system
      body: SafeArea(child: tabs[_currentIndex]),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildExploreTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadHomestays(reset: true);
        await _loadFavorites();
      },
      color: const Color(0xFFE07A5F),
      child: CustomScrollView(
        controller: _exploreScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildWelcomeHeader()),
          SliverToBoxAdapter(child: _buildSearchSection()),
          SliverToBoxAdapter(child: _buildLocationChips()),
          SliverToBoxAdapter(child: _buildCategoryFilter()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Homestay nổi bật',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6D4C41),
                    ),
                  ),
                  Text(
                    '${_homestays.length} kết quả',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          if (_homestays.isEmpty && !_isLoadingHomestays)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                  child: Text(
                    'Không tìm thấy homestay phù hợp.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index < _homestays.length) {
                    return _buildHomestayCard(_homestays[index]);
                  }
                  return null;
                }, childCount: _homestays.length),
              ),
            ),
          if (_isLoadingHomestays)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
                ),
              ),
            ),
          if (!_hasMoreHomestays && _homestays.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'Đã hiển thị tất cả kết quả',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final user = ref.read(authRepositoryProvider).currentUser;
    final String displayName = user?.email?.split('@').first ?? 'Alexandria';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chào $displayName,',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tìm kiếm homestay hoàn hảo cho kỳ nghỉ của bạn.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Tìm theo tên, thành phố, khu vực...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: Color(0xFFE07A5F)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.tune, color: Color(0xFF6D4C41)),
                    onPressed: () {
                      Navigator.pushNamed(context, '/filter');
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationChips() {
    final locations = [
      'Đà Lạt',
      'Đà Nẵng',
      'Hà Nội',
      'Phú Quốc',
      'Nha Trang',
      'Hội An',
    ];
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          final isActive = _searchQuery == location;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(
                location,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? Colors.white : const Color(0xFF6D4C41),
                ),
              ),
              avatar: Icon(
                Icons.location_on_outlined,
                size: 16,
                color: isActive ? Colors.white : const Color(0xFFE07A5F),
              ),
              backgroundColor: isActive
                  ? const Color(0xFFE07A5F)
                  : const Color(0xFFF7F4E1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isActive
                      ? const Color(0xFFE07A5F)
                      : Colors.transparent,
                ),
              ),
              onPressed: () {
                if (isActive) {
                  _searchController.clear();
                  _onSearchChanged('');
                } else {
                  _onLocationChipTapped(location);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'icon': Icons.grid_view_rounded, 'label': 'Tất cả'},
      {'icon': Icons.beach_access, 'label': 'Biển'},
      {'icon': Icons.terrain, 'label': 'Núi'},
      {'icon': Icons.apartment, 'label': 'Thành phố'},
      {'icon': Icons.forest, 'label': 'Rừng'},
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final label = categories[index]['label'] as String;
          final isSelected = _selectedCategory == label;

          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => _onCategoryChanged(label),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE07A5F).withOpacity(0.1)
                          : const Color(0xFFF7F4E1),
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(color: const Color(0xFFE07A5F))
                          : null,
                    ),
                    child: Icon(
                      categories[index]['icon'] as IconData,
                      color: isSelected
                          ? const Color(0xFFE07A5F)
                          : const Color(0xFF6D4C41),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFE07A5F)
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // _buildFeaturedSection removed - integrated directly into _buildExploreTab as SliverList

  Widget _buildHomestayCard(Homestay homestay) {
    final isFav = _favoriteHomestayIds.contains(homestay.id);
    final String imageUrl = homestay.images.isNotEmpty
        ? homestay.images.first
        : 'https://images.unsplash.com/photo-1510798831971-661eb04b3739?q=80&w=1000';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
        onTap: () {
          Navigator.pushNamed(
            context,
            '/homestay-detail',
            arguments: homestay,
          ).then((_) {
            _loadFavorites();
          });
        },
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white70,
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.black,
                        ),
                        onPressed: () => _toggleFavorite(homestay),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          homestay.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF424242),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
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
                                '${homestay.address}, ${homestay.city}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${homestay.pricePerNight.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ',
                          style: const TextStyle(
                            color: Color(0xFFE07A5F),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const TextSpan(
                          text: '/đêm',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. TAB YÊU THÍCH (FAVORITES TAB) ---
  Widget _buildFavoritesTab() {
    return ref
        .watch(customerHomeViewModelProvider)
        .when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
          ),
          error: (error, _) => Center(child: Text('Lỗi tải dữ liệu: $error')),
          data: (homeState) {
            final allHomestays = homeState.homestays;
            final favHomestays = allHomestays
                .where((h) => _favoriteHomestayIds.contains(h.id))
                .toList();

            return Scaffold(
              backgroundColor: const Color(0xFFFDFAE7),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Danh sách yêu thích',
                  style: TextStyle(
                    color: Color(0xFF6D4C41),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              body: favHomestays.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có homestay yêu thích nào.',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: favHomestays.length,
                      itemBuilder: (context, index) {
                        return _buildHomestayCard(favHomestays[index]);
                      },
                    ),
            );
          },
        );
  }

  // --- 3. TAB CHUYẾN ĐI (BOOKINGS TAB) ---
  Widget _buildBookingsTab() {
    return ref
        .watch(customerHomeViewModelProvider)
        .when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
          ),
          error: (error, _) => Center(child: Text('Lỗi tải dữ liệu: $error')),
          data: (homeState) {
            final bookings = homeState.bookings;

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
              body: bookings.isEmpty
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
                          const Text(
                            'Chưa có lịch sử đặt phòng nào',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
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
                        final checkOut = DateTime.parse(booking['check_out']);
                        final double totalPrice =
                            (booking['total_price'] ?? 0.0).toDouble();

                        // Xác định ảnh homestay từ liên kết
                        String imageUrl =
                            'https://images.unsplash.com/photo-1510798831971-661eb04b3739';
                        if (homestay != null &&
                            homestay['homestay_images'] != null &&
                            (homestay['homestay_images'] as List).isNotEmpty) {
                          imageUrl = homestay['homestay_images'][0]['url'];
                        }
                        Color statusColor = Colors.orange;
                        String statusText = 'Đang xử lý';

                        if (booking['status'] == 'confirmed') {
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
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/customer-booking-detail',
                                arguments: booking,
                              ).then((_) {
                                setState(() {});
                              });
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        imageUrl,
                                        height: 140,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            homestay?['name'] ??
                                                'The Terracotta Nest',
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF424242),
                                            ),
                                          ),
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
                                          Text(
                                            '${homestay?['address'] ?? ''}, ${homestay?['city'] ?? ''}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
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
                                          if (booking['status'] == 'confirmed')
                                            TextButton(
                                              onPressed: () {
                                                ref
                                                    .read(
                                                      bookingRepositoryProvider,
                                                    )
                                                    .updateStatus(
                                                      booking['id'],
                                                      'cancelled',
                                                    )
                                                    .then((_) {
                                                      setState(() {});
                                                    });
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
                                                  fontWeight: FontWeight.bold,
                                                ),
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
            );
          },
        );
  }

  // --- 4. TAB HỒ SƠ (PROFILE TAB) ---
  Widget _buildProfileTab() {
    return ref
        .watch(customerHomeViewModelProvider)
        .when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
          ),
          error: (error, _) => Center(child: Text('Lỗi tải dữ liệu: $error')),
          data: (homeState) {
            final profile = homeState.profile;
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
              backgroundColor: const Color(0xFFFDFAE7),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Hồ sơ cá nhân',
                  style: TextStyle(
                    color: Color(0xFF6D4C41),
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
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage:
                                    avatarUrl != null && avatarUrl.isNotEmpty
                                    ? NetworkImage(avatarUrl)
                                    : const NetworkImage(
                                        'https://i.pravatar.cc/150?u=alexandria',
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE07A5F),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                              color: const Color(0xFFE07A5F).withOpacity(0.1),
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
                                Text(
                                  profile?['role'] == 'customer'
                                      ? 'Khách hàng'
                                      : (profile?['role'] == 'host'
                                            ? 'Chủ nhà'
                                            : 'Tác giả'),
                                  style: const TextStyle(
                                    color: Color(0xFFE07A5F),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => _openEditProfile(fullName, phone),
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Color(0xFF6D4C41),
                            ),
                            label: const Text(
                              'Chỉnh sửa hồ sơ',
                              style: TextStyle(
                                color: Color(0xFF6D4C41),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF6D4C41)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Các thông tin chi tiết liên hệ
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
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await ref.read(authRepositoryProvider).signOut();
                        navigator.pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                      },
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
                        shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
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

  // --- MENU ĐIỀU HƯỚNG BOTTOMNAVBAR ---
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFE07A5F),
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Khám phá'),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Yêu thích',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Đặt chỗ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Hồ sơ',
        ),
      ],
    );
  }
}
