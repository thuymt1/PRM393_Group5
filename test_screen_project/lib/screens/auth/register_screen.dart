import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Trạng thái ẩn/hiện mật khẩu
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Đồng ý điều khoản
  bool _agreeToTerms = false;
  bool _isLoading = false;

  // Password strength tracking
  int _passwordStrength = 0; // 0=Yếu, 1=Trung bình, 2=Mạnh

  final ApiService _apiService = ApiService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildRegisterForm(),
              const SizedBox(height: 16),
              _buildTermsCheckbox(),
              const SizedBox(height: 32),
              _buildRegisterButton(),
              const SizedBox(height: 32),
              _buildLoginLink(),
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
          'Tạo tài khoản mới',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontFamily: 'BeVietnamPro',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tham gia cùng Hearth & Horizon để bắt đầu những hành trình đầy cảm hứng.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        // ─── Họ và tên ───────────────────────────────────────────────────
        _buildFormField(
          label: 'Họ và tên',
          hint: 'Nguyễn Văn A',
          icon: Icons.person_outline,
          controller: _nameController,
          validator: Validators.validateFullName,
        ),
        const SizedBox(height: 20),
        // ─── Email ───────────────────────────────────────────────────────
        _buildFormField(
          label: 'Email',
          hint: 'alexandria.b@example.com',
          icon: Icons.email_outlined,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 20),
        // ─── Số điện thoại ───────────────────────────────────────────────
        _buildFormField(
          label: 'Số điện thoại',
          hint: '0987 654 321',
          icon: Icons.phone_outlined,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: Validators.validatePhone,
        ),
        const SizedBox(height: 20),
        // ─── Mật khẩu + strength indicator ──────────────────────────────
        _buildPasswordField(),
        const SizedBox(height: 20),
        // ─── Xác nhận mật khẩu ──────────────────────────────────────────
        _buildFormField(
          label: 'Xác nhận mật khẩu',
          hint: '••••••••',
          icon: Icons.lock_reset_outlined,
          controller: _confirmPasswordController,
          isPassword: true,
          obscureText: _obscureConfirmPassword,
          onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          validator: (val) => Validators.validateConfirmPassword(val, _passwordController.text),
        ),
      ],
    );
  }

  // ─── TextFormField chuẩn ─────────────────────────────────────────────────
  Widget _buildFormField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
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
        const SizedBox(height: 8),
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
            obscureText: isPassword ? obscureText : false,
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
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: onToggleVisibility,
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
                borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 1.5),
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

  // ─── Mật khẩu với Password Strength Indicator ────────────────────────────
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mật khẩu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
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
              setState(() {
                _passwordStrength = Validators.passwordStrength(val);
              });
            },
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFE07A5F), size: 22),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 1.5),
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
        // Password Strength Bar
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildPasswordStrengthBar(),
        ],
      ],
    );
  }

  // ─── Thanh đánh giá độ mạnh mật khẩu ────────────────────────────────────
  Widget _buildPasswordStrengthBar() {
    final labels = ['Yếu', 'Trung bình', 'Mạnh'];
    final colors = [Colors.red.shade400, Colors.orange.shade400, Colors.green.shade500];
    final filledSegments = _passwordStrength + 1; // 1, 2, hoặc 3 đoạn

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 5,
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                decoration: BoxDecoration(
                  color: i < filledSegments
                      ? colors[_passwordStrength]
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                'Độ mạnh: ${labels[_passwordStrength]}',
                key: ValueKey(_passwordStrength),
                style: TextStyle(
                  fontSize: 12,
                  color: colors[_passwordStrength],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            if (_passwordStrength < 2)
              Text(
                _passwordStrength == 0
                    ? 'Thêm chữ hoa & số để mạnh hơn'
                    : 'Thêm ký tự đặc biệt để mạnh hơn',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
          ],
        ),
      ],
    );
  }

  // ─── Checkbox Điều khoản ─────────────────────────────────────────────────
  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (val) => setState(() => _agreeToTerms = val!),
            activeColor: const Color(0xFFE07A5F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text.rich(
            TextSpan(
              text: 'Tôi đồng ý với ',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              children: [
                TextSpan(
                  text: 'Điều khoản dịch vụ',
                  style: TextStyle(
                    color: Color(0xFFE07A5F),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: ' và '),
                TextSpan(
                  text: 'Chính sách bảo mật',
                  style: TextStyle(
                    color: Color(0xFFE07A5F),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Nút Đăng ký ─────────────────────────────────────────────────────────
  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: (_agreeToTerms && !_isLoading) ? _handleRegister : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41),
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade500,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            )
          : const Text(
              'Đăng ký tài khoản',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
    );
  }

  // ─── Xử lý đăng ký ───────────────────────────────────────────────────────
  void _handleRegister() async {
    // Chạy validation toàn form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng kiểm tra lại thông tin đã nhập'),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng đồng ý với Điều khoản dịch vụ'),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      final authResponse = await _apiService.register(email, password);
      final user = authResponse.user;

      if (user != null) {
        // Tạo profile trong table profiles
        await _apiService.createProfile(
          id: user.id,
          email: email,
          fullName: name,
          phone: phone,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đăng ký tài khoản thành công! 🎉'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/choose-role', (route) => false);
      } else {
        throw Exception('Không nhận được thông tin User');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng ký thất bại: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ─── Link đăng nhập ──────────────────────────────────────────────────────
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã có tài khoản? ',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Đăng nhập ngay',
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