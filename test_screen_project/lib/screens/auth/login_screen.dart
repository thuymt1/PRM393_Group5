import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            const SizedBox(height: 32),
            _buildCard(
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Email',
                    hint: 'alexandria.b@example.com',
                    icon: Icons.alternate_email_rounded,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Mật khẩu',
                    hint: '••••••••',
                    icon: Icons.key_rounded,
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 6),
                  _buildForgotPassword(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildLoginButton(),
            const SizedBox(height: 24),
            _buildSocialLogin(),
            const SizedBox(height: 24),
            _buildSignUpLink(),
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
          'Chào mừng trở lại!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontFamily: 'BeVietnamPro',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Đăng nhập để tiếp tục hành trình khám phá những chân trời mới.',
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
    bool isPassword = false,
    required TextEditingController controller,
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
          obscureText: isPassword ? _obscureText : false,
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
                      _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
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

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () {
          context.push('/forgot-password-otp');
        },
        icon: const Icon(
          Icons.help_outline_rounded,
          size: 18,
          color: Color(0xFFE07A5F),
        ),
        label: const Text(
          'Quên mật khẩu?',
          style: TextStyle(
            color: Color(0xFFE07A5F),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final authState = ref.watch(authViewModelProvider);

    return ElevatedButton.icon(
      onPressed: authState.isLoading 
        ? null 
        : () async {
          final email = _emailController.text.trim();
          final password = _passwordController.text.trim();
          
          if (email.isEmpty || password.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vui lòng nhập đầy đủ email và mật khẩu')),
            );
            return;
          }

          final role = await ref.read(authViewModelProvider.notifier).login(email, password);
          
          if (!mounted) return;
          
          final currentError = ref.read(authViewModelProvider).error;
          if (currentError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(currentError)),
            );
            ref.read(authViewModelProvider.notifier).clearError();
            return;
          }

          // Dieu huong theo role
          if (role == 'customer') {
            context.pushReplacement('/customer-home');
          } else if (role == 'host') {
            context.pushReplacement('/host-dashboard');
          } else {
            context.pushReplacement('/choose-role');
          }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41),
        disabledBackgroundColor: const Color(0xFF6D4C41).withValues(alpha: 0.6),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: const Color(0xFF6D4C41).withValues(alpha: 0.3),
      ),
      icon: authState.isLoading 
          ? const SizedBox() 
          : const Icon(Icons.login_rounded, color: Colors.white, size: 20),
      label: authState.isLoading
          ? const SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            )
          : const Text(
              'Đăng nhập',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Hoặc đăng nhập với',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialButton(
              icon: Icons.public_rounded,
              name: 'Google',
              accent: const Color(0xFFEA4335),
            ),
            const SizedBox(width: 20),
            _socialButton(
              icon: Icons.facebook,
              name: 'Facebook',
              accent: const Color(0xFF1877F2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String name,
    required Color accent,
  }) {
    return Semantics(
      label: name,
      button: true,
      child: Container(
        width: 68,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: accent, size: 26),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chưa có tài khoản? ',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        GestureDetector(
          onTap: () {
            context.push('/register');
          },
          child: const Text(
            'Đăng ký ngay',
            style: TextStyle(
              color: Color(0xFFE07A5F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
