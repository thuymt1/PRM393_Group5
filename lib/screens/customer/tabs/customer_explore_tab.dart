import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repository_providers.dart';
import '../../../features/customer/viewmodels/customer_home_view_model.dart';
import '../../../models/homestay_model.dart';

class CustomerExploreTab extends ConsumerStatefulWidget {
  const CustomerExploreTab({super.key});

  @override
  ConsumerState<CustomerExploreTab> createState() => _CustomerExploreTabState();
}

class _CustomerExploreTabState extends ConsumerState<CustomerExploreTab> {
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
      final state = ref.read(customerHomeViewModelProvider).value;
      final isLoading = ref.read(customerHomeViewModelProvider).isLoading ||
          (state?.isLoadingMore ?? false);
      final hasMore = state?.hasMore ?? false;
      if (hasMore && !isLoading) {
        ref.read(customerHomeViewModelProvider.notifier).loadMore();
      }
    }
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

  Future<void> _toggleFavorite(Homestay homestay) async {
    try {
      await ref
          .read(customerHomeViewModelProvider.notifier)
          .toggleFavorite(homestay);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi yêu thích: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(customerHomeViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      body: asyncState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi tải dữ liệu: $error'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(customerHomeViewModelProvider.notifier).refresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE07A5F),
                ),
                child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        data: (homeState) {
          final homestays = homeState.homestays;
          final favoriteIds = homeState.favoriteIds;
          final isLoading = asyncState.isLoading || homeState.isLoadingMore;
          final hasMore = homeState.hasMore;
          final selectedCategory = homeState.category;

          return RefreshIndicator(
            color: const Color(0xFFE07A5F),
            onRefresh: () =>
                ref.read(customerHomeViewModelProvider.notifier).refresh(),
            child: CustomScrollView(
              controller: _exploreScrollController,
              slivers: [
                SliverToBoxAdapter(child: _buildWelcomeHeader()),
                SliverToBoxAdapter(child: _buildSearchSection()),
                SliverToBoxAdapter(child: _buildQuickLocationChips()),
                SliverToBoxAdapter(
                  child: _buildCategoriesSection(selectedCategory),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Text(
                      'Gợi ý homestay nổi bật',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF424242),
                      ),
                    ),
                  ),
                ),
                if (homestays.isEmpty && !isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: Text(
                          'Không tìm thấy homestay phù hợp',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < homestays.length) {
                            return _buildHomestayCard(
                              homestays[index],
                              favoriteIds.contains(homestays[index].id),
                            );
                          }
                          return null;
                        },
                        childCount: homestays.length,
                      ),
                    ),
                  ),
                if (isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE07A5F),
                        ),
                      ),
                    ),
                  ),
                if (!hasMore && homestays.isNotEmpty)
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
        },
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final user = ref.read(authRepositoryProvider).currentUser;
    final String displayName = user?.email?.split('@').first ?? 'Alexandria';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
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
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF6D4C41),
                size: 26,
              ),
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              tooltip: 'Thông báo',
            ),
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
                    onPressed: () async {
                      final filterResult = await Navigator.pushNamed(
                        context,
                        '/filter',
                      );
                      if (filterResult is Map<String, dynamic>) {
                        final city = filterResult['city'] as String?;
                        if (city != null && city.isNotEmpty) {
                          _searchController.text = city;
                          _onSearchChanged(city);
                        }
                      }
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLocationChips() {
    final locations = ['Đà Lạt', 'Đà Nẵng', 'Hà Nội', 'Nha Trang', 'Phú Quốc'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(locations[index]),
              backgroundColor: const Color(0xFFF7F4E1),
              labelStyle: const TextStyle(
                color: Color(0xFF6D4C41),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide.none,
              ),
              onPressed: () => _onLocationChipTapped(locations[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesSection(String selectedCategory) {
    final categories = [
      {'name': 'Tất cả', 'icon': Icons.grid_view},
      {'name': 'Biệt thự', 'icon': Icons.villa},
      {'name': 'Căn hộ', 'icon': Icons.apartment},
      {'name': 'Nhà gỗ', 'icon': Icons.cabin},
      {'name': 'Gần biển', 'icon': Icons.beach_access},
    ];

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final String catName = cat['name'] as String;
          final bool isSelected =
              (selectedCategory.isEmpty && catName == 'Tất cả') ||
                  (selectedCategory == catName);

          return GestureDetector(
            onTap: () => _onCategoryChanged(catName == 'Tất cả' ? '' : catName),
            child: Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE07A5F)
                          : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      color: isSelected ? Colors.white : const Color(0xFF6D4C41),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    catName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected ? const Color(0xFFE07A5F) : Colors.grey,
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

  Widget _buildHomestayCard(Homestay homestay, bool isFavorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/homestay-detail',
            arguments: homestay,
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Image.network(
                    homestay.images.isNotEmpty
                        ? homestay.images.first
                        : 'https://images.unsplash.com/photo-1510798831971-661eb04b3739',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: const Color(0xFFF7F4E1),
                      child: const Icon(
                        Icons.home_outlined,
                        color: Color(0xFF6D4C41),
                        size: 48,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => _toggleFavorite(homestay),
                    ),
                  ),
                ),
                if (homestay.category.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6D4C41).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        homestay.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          homestay.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF424242),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
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
                          '${homestay.address}, ${homestay.city}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${homestay.pricePerNight.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE07A5F),
                              ),
                            ),
                            const TextSpan(
                              text: ' / đêm',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F4E1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Đặt ngay',
                          style: TextStyle(
                            color: Color(0xFF6D4C41),
                            fontSize: 12,
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
  }
}
