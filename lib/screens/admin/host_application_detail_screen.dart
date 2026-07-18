import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/repository_providers.dart';
import '../../models/host_application_model.dart';

/// Màn hình chi tiết đơn đăng ký host - Admin xem thông tin và phê duyệt/từ chối
class HostApplicationDetailScreen extends ConsumerStatefulWidget {
  final HostApplication application;

  const HostApplicationDetailScreen({super.key, required this.application});

  @override
  ConsumerState<HostApplicationDetailScreen> createState() =>
      _HostApplicationDetailScreenState();
}

class _HostApplicationDetailScreenState
    extends ConsumerState<HostApplicationDetailScreen> {
  final _noteController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleApprove() async {
    final confirm = await _showConfirmDialog(
      title: 'Phê duyệt đơn?',
      content:
          'Người dùng "${widget.application.fullName}" sẽ được cấp quyền Chủ nhà và có thể đăng tin homestay.',
      confirmLabel: 'Phê duyệt',
      confirmColor: Colors.green.shade600,
    );
    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .reviewApplication(
            applicationId: widget.application.id,
            userId: widget.application.userId,
            status: 'approved',
            adminNote: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã phê duyệt đơn thành công! ✅'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleReject() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập lý do từ chối trước khi xác nhận'),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final confirm = await _showConfirmDialog(
      title: 'Từ chối đơn?',
      content:
          'Đơn của "${widget.application.fullName}" sẽ bị từ chối. Người dùng sẽ nhận được lý do bạn đã nhập.',
      confirmLabel: 'Từ chối',
      confirmColor: Colors.red.shade600,
    );
    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .reviewApplication(
            applicationId: widget.application.id,
            userId: widget.application.userId,
            status: 'rejected',
            adminNote: _noteController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã từ chối đơn.'),
          backgroundColor: Colors.grey.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242),
          ),
        ),
        content: Text(
          content,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final isPending = app.isPending;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D4C41),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết đơn đăng ký',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildApplicantCard(app),
                const SizedBox(height: 16),
                _buildApplicationContent(app),
                const SizedBox(height: 16),
                if (isPending) _buildAdminNoteField(),
                if (!isPending && app.adminNote != null)
                  _buildExistingNote(app),
                const SizedBox(height: 24),
                if (isPending) _buildActionButtons(),
                if (!isPending) _buildStatusBadge(app),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(HostApplication app) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFFF7F4E1),
            child: Text(
              app.fullName.isNotEmpty ? app.fullName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Color(0xFFE07A5F),
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 4),
                _contactRow(Icons.email_outlined, app.email),
                const SizedBox(height: 2),
                _contactRow(Icons.phone_outlined, app.phone),
                const SizedBox(height: 6),
                Text(
                  'Ngày gửi: ${_formatDate(app.createdAt)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildApplicationContent(HostApplication app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentSection(
          title: 'Lý do đăng ký',
          icon: Icons.lightbulb_outline,
          content: app.reason ?? 'Người dùng chưa cung cấp lý do.',
        ),
        if (app.experience != null && app.experience!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildContentSection(
            title: 'Kinh nghiệm',
            icon: Icons.workspace_premium_outlined,
            content: app.experience!,
          ),
        ],
      ],
    );
  }

  Widget _buildContentSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFFE07A5F)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF6D4C41),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ghi chú Admin',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF6D4C41),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '(Bắt buộc khi từ chối, hiển thị cho người dùng)',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Nhập lý do hoặc ghi chú cho người dùng...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE07A5F),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingNote(HostApplication app) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.comment_outlined, color: Colors.orange.shade600, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ghi chú Admin:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  app.adminNote!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF78350F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isProcessing ? null : _handleReject,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: BorderSide(color: Colors.red.shade400, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cancel_outlined,
                  color: Colors.red.shade500,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Từ chối',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.red.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _handleApprove,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Phê duyệt',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(HostApplication app) {
    final isApproved = app.isApproved;
    final color = isApproved ? Colors.green.shade600 : Colors.red.shade600;
    final bgColor = isApproved ? Colors.green.shade50 : Colors.red.shade50;
    final icon = isApproved ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Text(
            app.statusLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (app.reviewedAt != null) ...[
            const SizedBox(width: 8),
            Text(
              '— ${_formatDate(app.reviewedAt!)}',
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
