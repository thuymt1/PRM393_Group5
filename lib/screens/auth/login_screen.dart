import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';

import '../../utils/url_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isRedirecting = false;
  final ApiService _apiService = ApiService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    // 1. Kiểm tra trực tiếp URL (hữu ích cho Web khi Supabase tự đổi code ở URL nhưng chưa kích hoạt AuthChangeEvent ngay)
    _checkAndRedirectRecovery();

    // 2. Lắng nghe sự kiện Auth để điều hướng (bao gồm cả đăng nhập Google)
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      // LoginScreen vẫn còn trong navigator khi người dùng mở trang đăng ký.
      // Không xử lý signedIn phát ra từ verify OTP của RegisterScreen, nếu không
      // role mặc định "customer" sẽ điều hướng trước màn hình chọn vai trò.
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
      if (!mounted || !isCurrentRoute) return;
      if (data.event == AuthChangeEvent.passwordRecovery) {
        if (mounted) {
          UrlHelper.clearQueryParameters();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/reset-password',
            (route) => false,
          );
        }
      } else if (data.event == AuthChangeEvent.signedIn) {
        _handlePostSignIn();
      }
    });
  }

  void _checkAndRedirectRecovery() {
    final uri = Uri.base;
    if (uri.queryParameters['type'] == 'recovery' ||
        uri.toString().contains('type=recovery')) {
      // Xoá tham số URL ngay lập tức để tránh vòng lặp nếu quay lại hoặc tải lại
      UrlHelper.clearQueryParameters();
      _waitForSessionAndRedirect();
    }
  }

  void _waitForSessionAndRedirect([int retries = 0]) {
    // Dừng thử lại sau 40 lần (khoảng 6 giây) nếu không tải được session
    if (retries > 40) return;

    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/reset-password',
          (route) => false,
        );
      } else {
        // Tiếp tục đợi đến khi Supabase tải xong session
        _waitForSessionAndRedirect(retries + 1);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
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
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 48),
              _buildLoginForm(),
              const SizedBox(height: 8),
              _buildForgotPassword(),
              const SizedBox(height: 32),
              _buildLoginButton(),
              const SizedBox(height: 40),
              _buildSignUpLink(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chào mừng trở lại!',
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
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildFormField(
          label: 'Email',
          hint: 'alexandria.b@example.com',
          icon: Icons.email_outlined,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          label: 'Mật khẩu',
          hint: '••••••••',
          icon: Icons.lock_outline,
          controller: _passwordController,
          isPassword: true,
          validator: Validators.validatePassword,
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
            controller: controller,
            obscureText: isPassword ? _obscureText : false,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15),
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFFE07A5F), size: 22),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    )
                  : null,
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

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
        child: const Text(
          'Quên mật khẩu?',
          style: TextStyle(
            color: Color(0xFFE07A5F),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
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
              'Đăng nhập',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
    );
  }

  Future<void> _handlePostSignIn() async {
    if (_isRedirecting || !mounted) return;
    _isRedirecting = true;

    setState(() => _isLoading = true);

    try {
      final profile = await _apiService.getMyProfile();
      if (!mounted) return;

      // Profile is created only after the registration OTP succeeds. A valid
      // Auth session without a profile must not be allowed into role setup.
      if (profile == null) {
        await _apiService.signOut();
        throw Exception('Tài khoản chưa hoàn tất đăng ký bằng mã OTP');
      }

      if (profile['role'] != null) {
        final role = profile['role'];
        if (role == 'admin') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/admin-dashboard',
            (route) => false,
          );
        } else if (role == 'customer') {
          // Tài khoản đã chọn role trước đó thì đăng nhập thẳng vào trang tương ứng.
          final app = await _apiService.getMyHostApplication();
          if (!mounted) return;
          if (app != null &&
              (app.status == 'pending' || app.status == 'rejected')) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/host-pending',
              (route) => false,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/customer-home',
              (route) => false,
            );
          }
        } else if (role == 'host') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/host-dashboard',
            (route) => false,
          );
        } else if (role == 'author') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/author-dashboard',
            (route) => false,
          );
        } else if (role == 'pending_host') {
          // Dự phòng cho trường hợp role DB vẫn là pending_host
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/host-pending',
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/choose-role',
            (route) => false,
          );
        }
      } else {
        // Profile exists but has no role: this is the only valid route to role setup.
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/choose-role',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('OTP')
                  ? 'Tài khoản chưa hoàn tất xác minh OTP.'
                  : 'Không thể tải thông tin tài khoản.',
            ),
          ),
        );
      }
    } finally {
      _isRedirecting = false;
    }
  }

  void _handleLogin() async {
    // Chạy validation toàn form trước khi gửi request
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      // Không cho session cũ làm người dùng vượt qua bước kiểm tra tài khoản.
      await _apiService.signOut();
      final response = await _apiService.login(email, password);
      if (response.user == null || response.session == null) {
        throw const AuthException('Không tạo được phiên đăng nhập');
      }
      if (response.user!.emailConfirmedAt == null) {
        await _apiService.signOut();
        throw const AuthException('Email chưa được xác minh');
      }
      // Sau khi đăng nhập thành công, _handlePostSignIn sẽ được gọi
      await _handlePostSignIn();
    } catch (e) {
      if (!mounted) return;
      final error = e.toString().toLowerCase();
      final message =
          error.contains('email chưa được xác minh') ||
              error.contains('email not confirmed')
          ? 'Email chưa được xác minh. Vui lòng đăng ký và nhập mã OTP trước.'
          : 'Tài khoản không tồn tại hoặc mật khẩu không chính xác';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
            _socialIcon(
              'https://img.icons8.com/color/48/000000/google-logo.png',
              onTap: _handleGoogleSignIn,
            ),
            const SizedBox(width: 24),
            _socialIcon(
              'https://upload.wikimedia.org/wikipedia/commons/0/05/Facebook_Logo_%282019%29.png',
              onTap: () {
                // Future implementation for Facebook
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      final errorText = e.toString();
      final isProviderDisabled =
          errorText.contains('provider is not enabled') ||
          errorText.contains('Unsupported provider');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isProviderDisabled
                ? 'Google chưa được bật trong Supabase. Hãy bật Authentication > Providers > Google.'
                : 'Lỗi đăng nhập Google: $e',
          ),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 6),
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  Widget _socialIcon(String url, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Image.network(url, width: 24, height: 24),
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
            Navigator.pushNamed(context, '/register');
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
