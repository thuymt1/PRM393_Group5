import 'package:flutter/material.dart';

import '../../../../models/homestay_model.dart';
import '../host_dashboard_theme.dart';

class HostLoadingState extends StatelessWidget {
  const HostLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: hostOrange, strokeWidth: 2.5),
    );
  }
}

class HostErrorState extends StatelessWidget {
  const HostErrorState({required this.error, required this.onRetry, super.key});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
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
                color: hostText,
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
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Thử lại'),
              style: OutlinedButton.styleFrom(foregroundColor: hostBrown),
            ),
          ],
        ),
      ),
    );
  }
}

class HostEmptyState extends StatelessWidget {
  const HostEmptyState({required this.message, required this.icon, super.key});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
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
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8C8079), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class HostListSearch extends StatelessWidget {
  const HostListSearch({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFA19791), fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: hostOrange),
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
          borderSide: const BorderSide(color: hostOrange, width: 1.5),
        ),
      ),
    );
  }
}

class HostFilterChoice extends StatelessWidget {
  const HostFilterChoice({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
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
          color: selected ? hostOrange : const Color(0xFFE7DDD3),
        ),
        labelStyle: TextStyle(
          color: selected ? hostBrown : const Color(0xFF776C66),
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class HostSortButton<T> extends StatelessWidget {
  const HostSortButton({
    required this.label,
    required this.selected,
    required this.items,
    required this.onSelected,
    super.key,
  });

  final String label;
  final T selected;
  final List<PopupMenuEntry<T>> items;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
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
            const Icon(Icons.swap_vert_rounded, size: 18, color: hostBrown),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: hostBrown,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HostNoSearchResults extends StatelessWidget {
  const HostNoSearchResults({
    required this.message,
    required this.onReset,
    super.key,
  });

  final String message;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
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
            style: TextButton.styleFrom(foregroundColor: hostOrange),
          ),
        ),
      ],
    );
  }
}

class HostBookingCard extends StatelessWidget {
  const HostBookingCard({
    required this.booking,
    required this.isUpdating,
    required this.onOpen,
    required this.onUpdateStatus,
    super.key,
  });

  final Map<String, dynamic> booking;
  final bool isUpdating;
  final Future<void> Function() onOpen;
  final void Function(int bookingId, String status) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
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

    return InkWell(
      onTap: onOpen,
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
                _BookingAvatar(profile?['avatar_url']?.toString()),
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
                        : () => onUpdateStatus(bookingId, 'rejected'),
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
                        : () => onUpdateStatus(bookingId, 'confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hostBrown,
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
}

class HostHomestayCard extends StatelessWidget {
  const HostHomestayCard({required this.homestay, super.key});

  final Homestay homestay;

  @override
  Widget build(BuildContext context) {
    final imageUrl = homestay.images.isNotEmpty ? homestay.images.first : '';
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
                ? const _HomestayImageFallback(icon: Icons.cottage_outlined)
                : Image.network(
                    imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _HomestayImageFallback(
                      icon: Icons.broken_image_outlined,
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
                          color: hostText,
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
                      '${_formatPrice(homestay.pricePerNight)}đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: hostOrange,
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
}

class _BookingAvatar extends StatelessWidget {
  const _BookingAvatar(this.imageUrl);

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return const CircleAvatar(
        radius: 21,
        backgroundColor: Color(0xFFF2E8E1),
        child: Icon(Icons.person_outline, color: hostBrown, size: 22),
      );
    }

    return ClipOval(
      child: Image.network(
        imageUrl!,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(
          color: Color(0xFFF2E8E1),
          child: SizedBox.square(
            dimension: 42,
            child: Icon(Icons.person_outline, color: hostBrown, size: 22),
          ),
        ),
      ),
    );
  }
}

class _HomestayImageFallback extends StatelessWidget {
  const _HomestayImageFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: ColoredBox(
        color: const Color(0xFFF1E8DC),
        child: Icon(icon, color: const Color(0xFFB39A8B), size: 44),
      ),
    );
  }
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

String _formatPrice(double price) {
  return price.toInt().toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}
