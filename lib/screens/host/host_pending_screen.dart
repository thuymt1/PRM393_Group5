import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/api_service.dart';
import '../../models/host_application_model.dart';

/// Màn hình hiển thị trạng thái đơn đăng ký host đang chờ duyệt
class HostPendingScreen extends StatefulWidget {
  const HostPendingScreen({super.key});

  @override
  State<HostPendingScreen> createState() => _HostPendingScreenState();
}

class _HostPendingScreenState extends State<HostPendingScreen> {
  final ApiService _apiService = ApiService();
  HostApplication? _application;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  Future<void> _loadApplication() async {
    setState(() => _isLoading = true);
    try {
      final app = await _apiService.getMyHostApplication();
      if (mounted) {
        setState(() {
          _application = app;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _handleReapply() {
    Navigator.pushReplacementNamed(context, '/host-registration-form');
  }

  void _handleBecomeCustomer() async {
    // Cho phép người dùng chuyển sang dùng như customer
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'role': 'customer'})
          .eq('id', Supabase.instance.client.auth.currentUser!.id);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/customer-home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE07A5F)))
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final app = _application;
    final isPending = app == null || app.isPending;
    final isRejected = app?.isRejected ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 48),

          // Icon trạng thái
          _buildStatusIcon(isPending: isPending, isRejected: isRejected),
          const SizedBox(height: 32),

          // Tiêu đề trạng thái
          _buildStatusTitle(isPending: isPending, isRejected: isRejected),
          const SizedBox(height: 16),

          // Mô tả / ghi chú admin
          _buildStatusDescription(app: app, isPending: isPending, isRejected: isRejected),
          const SizedBox(height: 32),

          // Thông tin đơn (nếu có)
          if (app != null) _buildApplicationInfo(app),
          const Spacer(),

          // Các nút hành động
          _buildActionButtons(isPending: isPending, isRejected: isRejected),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatusIcon({required bool isPending, required bool isRejected}) {
    IconData icon;
    Color color;
    Color bgColor;

    if (isPending) {
      icon = Icons.hourglass_top_rounded;
      color = const Color(0xFFF59E0B);
      bgColor = const Color(0xFFFEF3C7);
    } else if (isRejected) {
      icon = Icons.cancel_outlined;
      color = Colors.red.shade500;
      bgColor = Colors.red.shade50;
    } else {
      icon = Icons.check_circle_outline_rounded;
      color = Colors.green.shade500;
      bgColor = Colors.green.shade50;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Icon(icon, size: 52, color: color),
    );
  }

  Widget _buildStatusTitle({required bool isPending, required bool isRejected}) {
    String title;
    if (isPending) {
      title = 'Đơn đang chờ xét duyệt';
    } else if (isRejected) {
      title = 'Đơn bị từ chối';
    } else {
      title = 'Đơn đã được phê duyệt!';
    }

    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6D4C41),
      ),
    );
  }

  Widget _buildStatusDescription({
    required HostApplication? app,
    required bool isPending,
    required bool isRejected,
  }) {
    String desc;
    if (isPending) {
      desc = 'Chúng tôi đã nhận được đơn đăng ký của bạn. Admin sẽ xem xét và phản hồi trong vòng 1-3 ngày làm việc.';
    } else if (isRejected) {
      desc = 'Rất tiếc, đơn đăng ký của bạn chưa được chấp thuận lần này. Bạn có thể gửi lại đơn sau khi điều chỉnh thông tin.';
    } else {
      desc = 'Chúc mừng! Bạn đã được phê duyệt làm Chủ nhà. Hãy đăng nhập lại để bắt đầu quản lý homestay của bạn.';
    }

    return Text(
      desc,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
        height: 1.6,
      ),
    );
  }

  Widget _buildApplicationInfo(HostApplication app) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _infoRow(Icons.calendar_today_outlined, 'Ngày gửi đơn',
              _formatDate(app.createdAt)),
          const Divider(height: 20),
          _infoRow(Icons.info_outline, 'Trạng thái', app.statusLabel),
          if (app.isRejected && app.adminNote != null) ...[
            const Divider(height: 20),
            _infoRow(Icons.comment_outlined, 'Lý do từ chối', app.adminNote!),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE07A5F)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF424242),
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons({required bool isPending, required bool isRejected}) {
    final isApproved = _application?.isApproved ?? false;

    return Column(
      children: [
        if (isApproved)
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/host-dashboard', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.space_dashboard_outlined, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Truy cập giao diện Chủ nhà',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
        if (isApproved) const SizedBox(height: 12),

        if (isRejected)
          ElevatedButton(
            onPressed: _handleReapply,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE07A5F),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Gửi lại đơn đăng ký',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
            ),
          ),
        if (isRejected) const SizedBox(height: 12),

        // Nút sử dụng như khách hàng (chỉ hiện khi chưa được duyệt)
        if (!isApproved)
          OutlinedButton(
            onPressed: _handleBecomeCustomer,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: const BorderSide(color: Color(0xFF6D4C41), width: 1.5),
            ),
            child: const Text(
              'Tiếp tục với vai trò Khách hàng',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF6D4C41)),
            ),
          ),
        if (!isApproved) const SizedBox(height: 12),

        // Nút đăng xuất
        TextButton(
          onPressed: _handleLogout,
          child: Text(
            'Đăng xuất',
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
