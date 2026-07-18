import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/repository_providers.dart';
import '../../features/auth/viewmodels/auth_view_model.dart';
import '../../utils/validators.dart';

/// Màn hình đặt lại mật khẩu mới – được mở khi người dùng click link trong email
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool get _isLoading => ref.read(authViewModelProvider).isLoading;
  bool _passwordChanged = false;
  int _passwordStrength = 0;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Supabase tự động dùng session từ deep link để cập nhật mật khẩu
      await ref
          .read(authViewModelProvider.notifier)
          .updatePassword(_passwordController.text);

      if (!mounted) return;
      setState(() {
        _passwordChanged = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _signOutAndGoToLogin() async {
    try {
      await ref.read(authViewModelProvider.notifier).signOut();
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authViewModelProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
          onPressed: _signOutAndGoToLogin,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _passwordChanged ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  // ─── Form đặt mật khẩu mới ───────────────────────────────────────────────
  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildHeader(),
          const SizedBox(height: 40),
          _buildPasswordField(),
          const SizedBox(height: 20),
          _buildConfirmField(),
          const SizedBox(height: 40),
          _buildSubmitButton(),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: _signOutAndGoToLogin,
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                size: 14,
                color: Color(0xFFE07A5F),
              ),
              label: const Text(
                'Quay lại đăng nhập',
                style: TextStyle(
                  color: Color(0xFFE07A5F),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final userEmail = ref.read(authRepositoryProvider).currentUser?.email ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE07A5F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.lock_open_rounded,
            size: 40,
            color: Color(0xFFE07A5F),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Đặt mật khẩu mới',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontFamily: 'BeVietnamPro',
          ),
        ),
        if (userEmail.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: 'Đang thay đổi mật khẩu cho tài khoản: ',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              children: [
                TextSpan(
                  text: userEmail,
                  style: const TextStyle(
                    color: Color(0xFFE07A5F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          'Tạo mật khẩu mạnh để bảo vệ tài khoản của bạn.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ─── Password field với strength bar ─────────────────────────────────────
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mật khẩu mới',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 15),
            validator: Validators.validatePassword,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (val) {
              setState(
                () => _passwordStrength = Validators.passwordStrength(val),
              );
            },
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Color(0xFFE07A5F),
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE07A5F),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              errorStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        // Strength bar
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildStrengthBar(),
        ],
      ],
    );
  }

  Widget _buildStrengthBar() {
    final labels = ['Yếu', 'Trung bình', 'Mạnh'];
    final colors = [
      Colors.red.shade400,
      Colors.orange.shade400,
      Colors.green.shade500,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            3,
            (i) => Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 5,
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                decoration: BoxDecoration(
                  color: i <= _passwordStrength
                      ? colors[_passwordStrength]
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Độ mạnh: ${labels[_passwordStrength]}',
          style: TextStyle(
            fontSize: 12,
            color: colors[_passwordStrength],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ─── Confirm password field ───────────────────────────────────────────────
  Widget _buildConfirmField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Xác nhận mật khẩu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            style: const TextStyle(fontSize: 15),
            validator: (val) => Validators.validateConfirmPassword(
              val,
              _passwordController.text,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(
                Icons.lock_reset_outlined,
                color: Color(0xFFE07A5F),
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE07A5F),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              errorStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleResetPassword,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : const Text(
              'Xác nhận mật khẩu mới',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
    );
  }

  // ─── Màn hình thành công ──────────────────────────────────────────────────
  Widget _buildSuccessView() {
    return Column(
      children: [
        const SizedBox(height: 80),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 72,
            color: Colors.green.shade500,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Đổi mật khẩu thành công!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontFamily: 'BeVietnamPro',
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Mật khẩu của bạn đã được cập nhật.\nHãy đăng nhập lại để tiếp tục.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: _signOutAndGoToLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6D4C41),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Đăng nhập ngay',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
