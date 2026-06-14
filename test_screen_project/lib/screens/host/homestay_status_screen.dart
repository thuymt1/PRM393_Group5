import 'package:flutter/material.dart';

class HomestayStatusScreen extends StatefulWidget {
  const HomestayStatusScreen({super.key});

  @override
  State<HomestayStatusScreen> createState() => _HomestayStatusScreenState();
}

class _HomestayStatusScreenState extends State<HomestayStatusScreen>
    with SingleTickerProviderStateMixin {
  bool _isPublic = true;
  String _status = 'Đang hoạt động';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (_status) {
      case 'Đang hoạt động': return const Color(0xFF10B981);
      case 'Chờ duyệt': return Colors.orange;
      case 'Đã ẩn': return const Color(0xFF6B7280);
      default: return Colors.red;
    }
  }

  IconData get _statusIcon {
    switch (_status) {
      case 'Đang hoạt động': return Icons.check_circle_outline;
      case 'Chờ duyệt': return Icons.pending_actions;
      case 'Đã ẩn': return Icons.visibility_off_outlined;
      default: return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
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
          'Trạng thái bài đăng',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.history, color: Color(0xFF374151), size: 19),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPropertyPreview(),
            const SizedBox(height: 20),
            _buildStatusCard(),
            const SizedBox(height: 20),
            _buildInsightsRow(),
            const SizedBox(height: 20),
            _buildManagementActions(),
            const SizedBox(height: 20),
            _buildVisibilityToggle(),
            const SizedBox(height: 20),
            _buildDeleteSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://images.unsplash.com/photo-1510798831971-661eb04b3739?q=80&w=1000',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 6,
                left: 6,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (_, __) => Transform.scale(
                    scale: _isPublic ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: _statusColor.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The Terracotta Nest',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 3),
                    const Text('Đà Lạt, Lâm Đồng', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      '1.250.000đ',
                      style: TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const Text(' / đêm', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF59E0B), size: 13),
                        const Text(' 4.9', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
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

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _statusColor.withOpacity(0.08),
            _statusColor.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _statusColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            _status,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: _statusColor),
          ),
          const SizedBox(height: 8),
          Text(
            _isPublic
                ? 'Bài đăng đang hiển thị công khai\nvà sẵn sàng nhận đặt phòng.'
                : 'Bài đăng đang bị ẩn khỏi kết quả tìm kiếm.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsRow() {
    return Row(
      children: [
        _insightItem('1.240', 'Lượt xem\ntháng này', Icons.visibility_outlined, const Color(0xFF6366F1)),
        const SizedBox(width: 12),
        _insightItem('18', 'Đặt phòng\nhoàn thành', Icons.book_online_outlined, const Color(0xFFE07A5F)),
        const SizedBox(width: 12),
        _insightItem('98%', 'Tỷ lệ\nphản hồi', Icons.speed_outlined, const Color(0xFF10B981)),
      ],
    );
  }

  Widget _insightItem(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937))),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quản lý nhanh',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151), fontSize: 16),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                Icons.edit_outlined,
                'Chỉnh sửa',
                const Color(0xFF6366F1),
                () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                Icons.calendar_today_outlined,
                'Lịch trống',
                const Color(0xFFE07A5F),
                () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                Icons.preview_outlined,
                'Xem thử',
                const Color(0xFF10B981),
                () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _isPublic ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF6B7280).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isPublic ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: _isPublic ? const Color(0xFF10B981) : const Color(0xFF6B7280),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hiển thị bài đăng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 3),
                Text(
                  _isPublic ? 'Khách có thể tìm và đặt phòng' : 'Ẩn khỏi kết quả tìm kiếm',
                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isPublic,
            onChanged: (val) {
              setState(() {
                _isPublic = val;
                _status = _isPublic ? 'Đang hoạt động' : 'Đã ẩn';
              });
            },
            activeColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_amber_outlined, color: Colors.red, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Khu vực nguy hiểm',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Xóa bài đăng sẽ gỡ bỏ hoàn toàn homestay khỏi hệ thống. Bạn có thể hoàn tác trong vòng 30 ngày.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Xóa bài đăng (Xóa mềm)', style: TextStyle(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red, size: 24),
            SizedBox(width: 10),
            Text('Xác nhận xóa?', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          ],
        ),
        content: const Text(
          'Bạn có chắc muốn ẩn bài đăng này? Khách hàng sẽ không thể tìm thấy hoặc đặt phòng nữa.',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _status = 'Đã ẩn';
                _isPublic = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Bài đăng đã được ẩn'),
                  backgroundColor: const Color(0xFF374151),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}