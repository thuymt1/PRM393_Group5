import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/homestay_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/homestay_model.dart';
import '../../repositories/homestay_repository.dart';
import '../common/profile_page.dart';
import '../customer/my_bookings_screen.dart';

// Provider cho categories tu backend
final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return HomestayRepository().getCategories();
});

class CustomerHomeScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const CustomerHomeScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  late int _currentIndex;
  int? _selectedCategoryId;
  int _selectedCategoryIndex = -1; // -1 = "Tất cả"
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _favoriteIds = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    Future.microtask(() {
      ref.read(homestayViewModelProvider.notifier).loadHomestays();
      ref.read(profileViewModelProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(homestayViewModelProvider.notifier).loadHomestays(
      search: query.isEmpty ? null : query,
      categoryId: _selectedCategoryId,
    );
  }

  void _onCategoryTap(int index, int? categoryId) {
    if (_selectedCategoryIndex == index) {
      // Bam lai → bỏ filter
      setState(() {
        _selectedCategoryIndex = -1;
        _selectedCategoryId = null;
      });
      ref.read(homestayViewModelProvider.notifier).loadHomestays();
    } else {
      setState(() {
        _selectedCategoryIndex = index;
        _selectedCategoryId = categoryId;
      });
      ref.read(homestayViewModelProvider.notifier).filterByCategory(categoryId);
    }
  }

  void _toggleFavorite(int homestayId) {
    setState(() {
      if (_favoriteIds.contains(homestayId)) {
        _favoriteIds.remove(homestayId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa khỏi yêu thích'), duration: Duration(seconds: 1)),
        );
      } else {
        _favoriteIds.add(homestayId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm vào yêu thích ❤️'), duration: Duration(seconds: 1)),
        );
      }
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref.read(authViewModelProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.push('/filter'),
              backgroundColor: const Color(0xFF6D4C41),
              tooltip: 'Bộ lọc nâng cao',
              child: const Icon(Icons.tune, color: Colors.white),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final profile = ref.watch(profileViewModelProvider).profile;
    return AppBar(
      key: const ValueKey('customer_app_bar'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Color(0xFF6D4C41)),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        tooltip: 'Mở menu',
      ),
      title: const Text(
        'Hearth & Horizon',
        style: TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Color(0xFF6D4C41)),
          onPressed: () => context.push('/notifications'),
          tooltip: 'Thông báo',
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () => setState(() => _currentIndex = 3),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE07A5F).withOpacity(0.2),
              backgroundImage: (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty)
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: (profile?.avatarUrl == null || profile!.avatarUrl!.isEmpty)
                  ? Text(
                      (profile?.fullName ?? '?').isNotEmpty
                          ? (profile?.fullName ?? '?')[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    final profile = ref.watch(profileViewModelProvider).profile;
    return Drawer(
      backgroundColor: const Color(0xFFFDFAE7),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE07A5F), Color(0xFF6D4C41)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    backgroundImage: (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty)
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: (profile?.avatarUrl == null || profile!.avatarUrl!.isEmpty)
                        ? Text(
                            (profile?.fullName ?? '?').isNotEmpty
                                ? (profile?.fullName ?? '?')[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile?.fullName ?? 'Đang tải...',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    profile?.email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _drawerItem(Icons.explore, 'Khám phá', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            }),
            _drawerItem(Icons.favorite_border, 'Yêu thích', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 1);
            }),
            _drawerItem(Icons.receipt_long, 'Đặt chỗ của tôi', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 2);
            }),
            _drawerItem(Icons.person_outline, 'Hồ sơ cá nhân', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            }),
            _drawerItem(Icons.notifications_none, 'Thông báo', () {
              Navigator.pop(context);
              context.push('/notifications');
            }),
            const Divider(indent: 16, endIndent: 16),
            const Spacer(),
            _drawerItem(Icons.logout, 'Đăng xuất', () {
              Navigator.pop(context);
              _logout();
            }, color: Colors.red),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF6D4C41)),
      title: Text(label, style: TextStyle(color: color ?? const Color(0xFF424242), fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildExploreTab();
      case 1: return _buildFavoritesTab();
      default: return _buildExploreTab();
    }
  }

  Widget _buildExploreTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          _buildSearchSection(),
          _buildCategoryFilter(),
          _buildFeaturedSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final profileState = ref.watch(profileViewModelProvider);
    final profile = profileState.profile;
    final name = (profile?.fullName != null && profile!.fullName.isNotEmpty)
        ? profile.fullName
        : 'bạn';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profileState.isLoading)
            const SizedBox(height: 32, child: LinearProgressIndicator(color: Color(0xFFE07A5F)))
          else
            Text('Chào $name 👋',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF424242))),
          const SizedBox(height: 4),
          const Text('Tìm kiếm homestay hoàn hảo cho kỳ nghỉ của bạn.',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: _onSearch,
          onChanged: (v) { if (v.isEmpty) _onSearch(''); },
          decoration: InputDecoration(
            hintText: 'Bạn muốn đi đâu?',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: Color(0xFFE07A5F)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox(
        height: 90,
        child: Center(child: CircularProgressIndicator(color: Color(0xFFE07A5F), strokeWidth: 2)),
      ),
      error: (_, __) => _buildDefaultCategoryFilter(),
      data: (categories) {
        if (categories.isEmpty) return _buildDefaultCategoryFilter();

        // Map icon cho category theo name
        final iconMap = <String, IconData>{
          'Biển': Icons.beach_access,
          'Núi': Icons.terrain,
          'Thành phố': Icons.apartment,
          'Rừng': Icons.forest,
          'Đồng quê': Icons.agriculture,
          'Hồ': Icons.water,
        };

        return SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final catId = cat['id'] as int?;
              final catName = cat['name'] as String? ?? '';
              final isSelected = _selectedCategoryIndex == index;
              final icon = iconMap[catName] ?? Icons.home_work_outlined;

              return GestureDetector(
                onTap: () => _onCategoryTap(index, catId),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE07A5F).withOpacity(0.1) : const Color(0xFFF7F4E1),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected ? Border.all(color: const Color(0xFFE07A5F)) : null,
                        ),
                        child: Icon(icon, color: isSelected ? const Color(0xFFE07A5F) : const Color(0xFF6D4C41)),
                      ),
                      const SizedBox(height: 6),
                      Text(catName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFFE07A5F) : Colors.grey,
                        )),
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

  // Fallback hardcode categories neu API that bai
  Widget _buildDefaultCategoryFilter() {
    final categories = [
      {'icon': Icons.beach_access, 'label': 'Biển'},
      {'icon': Icons.terrain, 'label': 'Núi'},
      {'icon': Icons.apartment, 'label': 'Thành phố'},
      {'icon': Icons.forest, 'label': 'Rừng'},
    ];
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategoryIndex = isSelected ? -1 : index);
              if (!isSelected) {
                ref.read(homestayViewModelProvider.notifier)
                    .search(categories[index]['label'] as String);
              } else {
                ref.read(homestayViewModelProvider.notifier).clearFilters();
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE07A5F).withOpacity(0.1) : const Color(0xFFF7F4E1),
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected ? Border.all(color: const Color(0xFFE07A5F)) : null,
                    ),
                    child: Icon(categories[index]['icon'] as IconData,
                      color: isSelected ? const Color(0xFFE07A5F) : const Color(0xFF6D4C41)),
                  ),
                  const SizedBox(height: 6),
                  Text(categories[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFFE07A5F) : Colors.grey,
                    )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSection() {
    final homestayState = ref.watch(homestayViewModelProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Homestay nổi bật',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41))),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() { _selectedCategoryIndex = -1; _selectedCategoryId = null; });
                  ref.read(homestayViewModelProvider.notifier).clearFilters();
                },
                child: const Text('Xem tất cả', style: TextStyle(color: Color(0xFFE07A5F))),
              ),
            ],
          ),
        ),
        if (homestayState.isLoading)
          const Padding(padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator(color: Color(0xFFE07A5F))))
        else if (homestayState.error != null)
          _buildErrorState(homestayState.error!)
        else if (homestayState.homestays.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: homestayState.homestays.length,
            itemBuilder: (context, index) =>
                _buildHomestayCard(homestayState.homestays[index]),
          ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Không thể tải homestay', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(error, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(homestayViewModelProvider.notifier).loadHomestays(),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE07A5F), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Icon(Icons.home_work_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Chưa có homestay nào', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Hãy thử thay đổi bộ lọc tìm kiếm', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() { _selectedCategoryIndex = -1; _selectedCategoryId = null; });
              _searchController.clear();
              ref.read(homestayViewModelProvider.notifier).clearFilters();
            },
            child: const Text('Xóa bộ lọc', style: TextStyle(color: Color(0xFFE07A5F))),
          ),
        ],
      ),
    );
  }

  Widget _buildHomestayCard(Homestay homestay) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final imageUrl = homestay.images.isNotEmpty
        ? homestay.images[0]
        : 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?q=80&w=1000';
    final isFav = _favoriteIds.contains(homestay.id);

    return GestureDetector(
      onTap: () => context.push('/homestay-detail', extra: homestay),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 200, color: const Color(0xFFF7F4E1),
                      child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey))),
                    loadingBuilder: (_, child, progress) => progress == null ? child
                        : Container(height: 200, color: const Color(0xFFF7F4E1),
                            child: const Center(child: CircularProgressIndicator(color: Color(0xFFE07A5F)))),
                  ),
                  // Category badge
                  if (homestay.category.isNotEmpty)
                    Positioned(top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6D4C41).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(homestay.category,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  // Nút yêu thích
                  Positioned(top: 12, right: 12,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(homestay.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: isFav ? const Color(0xFFE07A5F).withOpacity(0.95) : Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.white : const Color(0xFFE07A5F),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  // Rating badge
                  Positioned(bottom: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            homestay.rating > 0 ? homestay.rating.toStringAsFixed(1) : 'Mới',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(homestay.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                          const SizedBox(width: 2),
                          Expanded(child: Text('${homestay.address}, ${homestay.city}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ]),
                        if (homestay.maxGuests != null || homestay.numBedrooms != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(children: [
                              if (homestay.maxGuests != null) ...[
                                const Icon(Icons.people_outline, size: 12, color: Colors.grey),
                                const SizedBox(width: 2),
                                Text('${homestay.maxGuests} khách', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                const SizedBox(width: 8),
                              ],
                              if (homestay.numBedrooms != null) ...[
                                const Icon(Icons.bed_outlined, size: 12, color: Colors.grey),
                                const SizedBox(width: 2),
                                Text('${homestay.numBedrooms} phòng', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ]),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatCurrency.format(homestay.pricePerNight),
                        style: const TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold, fontSize: 15)),
                      const Text('/đêm', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    final homestayState = ref.watch(homestayViewModelProvider);
    final favorites = homestayState.homestays.where((h) => _favoriteIds.contains(h.id)).toList();

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Chưa có homestay yêu thích',
              style: TextStyle(color: Color(0xFF424242), fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Nhấn ❤️ trên các homestay để thêm vào đây',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 0),
              child: const Text('Khám phá homestay', style: TextStyle(color: Color(0xFFE07A5F))),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: favorites.length,
      itemBuilder: (context, index) => _buildHomestayCard(favorites[index]),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFE07A5F),
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index == 0 || index == 1) {
          setState(() => _currentIndex = index);
        } else if (index == 2) {
          context.go('/my-bookings');
        } else if (index == 3) {
          context.go('/profile');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Khám phá'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Yêu thích'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Đặt chỗ'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
      ],
    );
  }
}