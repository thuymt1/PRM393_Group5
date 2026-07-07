import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomestayListScreen extends StatefulWidget {
  const HomestayListScreen({super.key});

  @override
  State<HomestayListScreen> createState() => _HomestayListScreenState();
}

class _HomestayListScreenState extends State<HomestayListScreen>
    with SingleTickerProviderStateMixin {
  int _selectedFilter = 0;
  bool _isGridView = true;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['Gần đây', 'Phổ biến', 'Giá thấp', 'Đánh giá cao'];

  final List<Map<String, dynamic>> _homestays = [
    {
      'name': 'The Pine Hill',
      'location': 'Phường 4, Đà Lạt',
      'price': '1.200.000',
      'rating': 4.8,
      'reviews': 124,
      'status': 'Hoạt động',
      'image': 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'name': 'Minimalist Villa',
      'location': 'Hồ Tuyền Lâm',
      'price': '2.500.000',
      'rating': 4.9,
      'reviews': 87,
      'status': 'Hoạt động',
      'image': 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'name': 'Ocean Breeze Loft',
      'location': 'Sơn Trà, Đà Nẵng',
      'price': '1.850.000',
      'rating': 4.7,
      'reviews': 63,
      'status': 'Tạm ẩn',
      'image': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'name': 'Vintage Garden',
      'location': 'Mai Anh Đào, Đà Lạt',
      'price': '850.000',
      'rating': 4.6,
      'reviews': 39,
      'status': 'Hoạt động',
      'image': 'https://images.unsplash.com/photo-1449156001437-3a1441df910b?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'name': 'A-Frame Escape',
      'location': 'Trại Mát, Đà Lạt',
      'price': '1.550.000',
      'rating': 4.9,
      'reviews': 201,
      'status': 'Hoạt động',
      'image': 'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'name': 'Forest Cabin',
      'location': 'Sapa, Lào Cai',
      'price': '1.100.000',
      'rating': 4.5,
      'reviews': 55,
      'status': 'Chờ duyệt',
      'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1000&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF374151), size: 20),
          ),
        ),
        title: const Text(
          'Homestay của tôi',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          // Toggle grid/list
          GestureDetector(
            onTap: () => setState(() => _isGridView = !_isGridView),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined,
                color: const Color(0xFF374151),
                size: 19,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune_outlined, color: Color(0xFF374151), size: 19),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: _buildSearchAndFilter(),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isGridView ? _buildGridView() : _buildListView(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-homestay-basic-info'),
        backgroundColor: const Color(0xFFE07A5F),
        elevation: 3,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm homestay...',
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFE07A5F), size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF), size: 18),
                          onPressed: () => setState(() => _searchController.clear()),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: List.generate(_filters.length, (i) {
                final isSelected = _selectedFilter == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF5D3A2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      _filters[i],
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      key: const ValueKey('grid'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemCount: _homestays.length,
      itemBuilder: (context, index) {
        return _buildGridCard(_homestays[index]);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      key: const ValueKey('list'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _homestays.length,
      itemBuilder: (context, index) {
        return _buildListCard(_homestays[index]);
      },
    );
  }

  Widget _buildGridCard(Map<String, dynamic> homestay) {
    final isActive = homestay['status'] == 'Hoạt động';
    final isPending = homestay['status'] == 'Chờ duyệt';

    Color statusColor = isActive ? Colors.green : isPending ? Colors.orange : Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    homestay['image'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      homestay['status'],
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF59E0B), size: 10),
                        const SizedBox(width: 2),
                        Text(
                          '${homestay['rating']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    homestay['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 10, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          homestay['location'],
                          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${homestay['price']}đ',
                                style: const TextStyle(
                                  color: Color(0xFFE07A5F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const TextSpan(text: '/đêm', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9)),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F0E8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.more_vert, size: 15, color: Color(0xFF6B7280)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(Map<String, dynamic> homestay) {
    final isActive = homestay['status'] == 'Hoạt động';
    final isPending = homestay['status'] == 'Chờ duyệt';
    Color statusColor = isActive ? Colors.green : isPending ? Colors.orange : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            child: Image.network(
              homestay['image'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          homestay['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(homestay['location'], style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFF59E0B), size: 12),
                      Text(' ${homestay['rating']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      const SizedBox(width: 6),
                      Text('(${homestay['reviews']} đánh giá)', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
                      const Spacer(),
                      Text(
                        '${homestay['price']}đ',
                        style: const TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}