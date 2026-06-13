import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedFilterIndex = 0;

  final List<_NotificationFilter> _filters = const [
    _NotificationFilter(label: 'Tất cả', icon: Icons.notifications_none_rounded),
    _NotificationFilter(label: 'Giao dịch', icon: Icons.payments_outlined),
    _NotificationFilter(label: 'Đặt phòng', icon: Icons.event_available_outlined),
    _NotificationFilter(label: 'Khuyến mãi', icon: Icons.local_offer_outlined),
  ];

  final List<_NotificationItemData> _items = const [
    _NotificationItemData(
      group: 'Hôm nay',
      title: 'Đặt phòng đã được xác nhận',
      description: 'Đơn BK123456 tại The Pine Hill đã được chủ nhà xác nhận thành công.',
      time: '2 giờ trước',
      icon: Icons.receipt_long_rounded,
      accentColor: Color(0xFFE07A5F),
      unread: true,
    ),
    _NotificationItemData(
      group: 'Hôm nay',
      title: 'Thanh toán hoàn tất',
      description: 'Giao dịch 3.450.000đ đã được hệ thống ghi nhận.',
      time: '5 giờ trước',
      icon: Icons.payments_rounded,
      accentColor: Color(0xFF4CAF50),
      unread: false,
    ),
    _NotificationItemData(
      group: 'Hôm qua',
      title: 'Ưu đãi mới dành cho bạn',
      description: 'Giảm ngay 20% cho chuyến đi tiếp theo tại Đà Lạt. Khám phá ngay.',
      time: '1 ngày trước',
      icon: Icons.local_offer_rounded,
      accentColor: Color(0xFFFF9800),
      unread: false,
    ),
    _NotificationItemData(
      group: 'Hôm qua',
      title: 'Nhắc đánh giá trải nghiệm',
      description: 'Hãy để lại đánh giá cho homestay bạn vừa đặt để giúp cộng đồng lựa chọn tốt hơn.',
      time: '1 ngày trước',
      icon: Icons.rate_review_rounded,
      accentColor: Color(0xFF8E24AA),
      unread: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final groupedItems = _items.where((item) {
      if (_selectedFilterIndex == 0) return true;
      if (_selectedFilterIndex == 1) return item.icon == Icons.payments_rounded;
      if (_selectedFilterIndex == 2) return item.icon == Icons.receipt_long_rounded;
      return item.icon == Icons.local_offer_rounded;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF6D4C41)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.w800,
            fontSize: 20,
            fontFamily: 'BeVietnamPro',
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.done_all_rounded, size: 18, color: Color(0xFFE07A5F)),
            label: const Text(
              'Đánh dấu đọc',
              style: TextStyle(
                color: Color(0xFFE07A5F),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderSummary(),
          _buildFilterTabs(),
          Expanded(
            child: groupedItems.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    itemCount: groupedItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = groupedItems[index];
                      final showGroupLabel = index == 0 || groupedItems[index - 1].group != item.group;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showGroupLabel) ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 10),
                              child: Text(
                                item.group,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          _buildNotificationCard(item),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF7F1D8), Color(0xFFFFF8EC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Color(0xFFE07A5F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_active_rounded, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cập nhật từ app',
                    style: TextStyle(
                      color: Color(0xFF6D4C41),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Theo dõi thông báo đặt phòng, thanh toán và ưu đãi mới nhất.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.4,
                      fontSize: 13,
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

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final selected = index == _selectedFilterIndex;
          final filter = _filters[index];
          return ChoiceChip(
            selected: selected,
            onSelected: (_) => setState(() => _selectedFilterIndex = index),
            label: Text(filter.label),
            avatar: Icon(
              filter.icon,
              size: 18,
              color: selected ? Colors.white : const Color(0xFFE07A5F),
            ),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF6D4C41),
              fontWeight: FontWeight.w700,
            ),
            selectedColor: const Color(0xFFE07A5F),
            backgroundColor: Colors.white,
            side: BorderSide(color: selected ? Colors.transparent : Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemCount: _filters.length,
      ),
    );
  }

  Widget _buildNotificationCard(_NotificationItemData item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.unread ? const Color(0xFFF7F4E1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: item.unread ? const Color(0xFFEADFB8) : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: item.unread ? FontWeight.w800 : FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF424242),
                        ),
                      ),
                    ),
                    if (item.unread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8, top: 6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE07A5F),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.time,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.notifications_off_rounded, color: Color(0xFFE07A5F), size: 40),
            ),
            const SizedBox(height: 18),
            const Text(
              'Chưa có thông báo nào',
              style: TextStyle(
                color: Color(0xFF6D4C41),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Khi có cập nhật về đặt phòng, thanh toán hoặc khuyến mãi, bạn sẽ thấy ở đây.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationFilter {
  final String label;
  final IconData icon;

  const _NotificationFilter({
    required this.label,
    required this.icon,
  });
}

class _NotificationItemData {
  final String group;
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color accentColor;
  final bool unread;

  const _NotificationItemData({
    required this.group,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.accentColor,
    required this.unread,
  });
}
