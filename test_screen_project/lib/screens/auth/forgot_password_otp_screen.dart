import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF6D4C41)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _buildBrandMark(),
            const SizedBox(height: 28),
            _buildHeader(),
            const SizedBox(height: 28),
            _buildCard(
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Email nhận mã',
                    hint: 'your@email.com',
                    icon: Icons.mail_outline_rounded,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Mã OTP',
                    hint: 'Nhập 6 chữ số',
                    icon: Icons.lock_reset_rounded,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Mật khẩu mới',
                    hint: 'Nhập mật khẩu mới',
                    icon: Icons.key_rounded,
                    controller: _newPasswordController,
                    isPassword: true,
                    obscureText: _obscureNewPassword,
                    onToggleObscure: () {
                      setState(() => _obscureNewPassword = !_obscureNewPassword);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Xác nhận mật khẩu',
                    hint: 'Nhập lại mật khẩu mới',
                    icon: Icons.verified_user_outlined,
                    controller: _confirmPasswordController,
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onToggleObscure: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Gửi lại mã',
                        style: TextStyle(
                          color: Color(0xFFE07A5F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButton(),
            const SizedBox(height: 16),
            _buildBackToLogin(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandMark() {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE07A5F).withValues(alpha: 0.14),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            'https://cdn-icons-png.flaticon.com/512/619/619153.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.holiday_village_rounded,
                  color: Color(0xFFE07A5F),
                  size: 46,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Lấy lại mật khẩu',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontFamily: 'BeVietnamPro',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Nhập mã OTP đã được gửi qua email để đặt lại mật khẩu.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? obscureText : false,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4E1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFE07A5F), size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 56, minHeight: 56),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: Color(0xFFE07A5F), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: const Color(0xFF6D4C41).withValues(alpha: 0.3),
      ),
      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
      label: const Text(
        'Xác nhận OTP',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return Center(
      child: TextButton(
        onPressed: () => context.pop(),
        child: const Text(
          'Quay lại đăng nhập',
          style: TextStyle(
            color: Color(0xFFE07A5F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
