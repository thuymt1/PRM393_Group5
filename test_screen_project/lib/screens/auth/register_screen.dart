import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Trạng thái điều khiển việc ẩn/hiện văn bản cho ô nhập mật khẩu
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Trạng thái kiểm tra xem người dùng đã đồng ý với điều khoản dịch vụ chưa
  bool _agreeToTerms = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  // Các bộ điều khiển dữ liệu nhập vào cho từng TextField cụ thể
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Màu nền nhẹ nhàng đồng bộ từ design system
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Làm trong suốt thanh công cụ phía trên
        elevation: 0, // Loại bỏ bóng đổ phía dưới thanh ứng dụng
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
          onPressed: () => Navigator.pop(context), // Quay trở lại màn hình trước đó khi bấm
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildHeader(), // Hiển thị khối chữ giới thiệu và tiêu đề
            const SizedBox(height: 32),
            _buildRegisterForm(), // Hiển thị danh sách các ô nhập thông tin tài khoản
            const SizedBox(height: 16),
            _buildTermsCheckbox(), // Hiển thị khu vực chọn đồng ý điều khoản bảo mật
            const SizedBox(height: 32),
            _buildRegisterButton(), // Nút bấm thực hiện tiến trình đăng ký
            const SizedBox(height: 32),
            _buildLoginLink(), // Đường dẫn quay lại màn hình đăng nhập nếu đã có tài khoản
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị tiêu đề chính của màn hình đăng ký
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
            fontFamily: 'BeVietnamPro', // Cần cấu hình font tương ứng trong pubspec.yaml để hiển thị chuẩn
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

  // Gom nhóm tập hợp toàn bộ các ô nhập thông tin đăng ký thành viên
  Widget _buildRegisterForm() {
    return Column(
      children: [
        _buildTextField(
          label: 'Họ và tên',
          hint: 'Nguyễn Văn A',
          icon: Icons.person_outline,
          controller: _nameController,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Email',
          hint: 'alexandria.b@example.com',
          icon: Icons.email_outlined,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress, // Tối ưu bàn phím cho định dạng email
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Số điện thoại',
          hint: '0987 654 321',
          icon: Icons.phone_outlined,
          controller: _phoneController,
          keyboardType: TextInputType.phone, // Tối ưu bàn phím hiển thị các phím số cuộc gọi
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Mật khẩu',
          hint: '••••••••',
          icon: Icons.lock_outline,
          isPassword: true,
          obscureText: _obscurePassword,
          onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword), // Đảo trạng thái ẩn/hiện
          controller: _passwordController,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Xác nhận mật khẩu',
          hint: '••••••••',
          icon: Icons.lock_reset_outlined,
          isPassword: true,
          obscureText: _obscureConfirmPassword,
          onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword), // Đảo trạng thái ẩn/hiện
          controller: _confirmPasswordController,
        ),
      ],
    );
  }

  // Hàm thiết kế dùng chung cấu trúc cho ô nhập dữ liệu TextField dạng bo góc tròn có đổ bóng nhẹ
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
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
          child: TextField(
            controller: controller,
            obscureText: isPassword ? obscureText : false, // Kiểm tra ẩn text đối với các trường mật khẩu
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFFE07A5F), size: 22), // Biểu tượng đầu ô nhập liệu
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: onToggleVisibility, // Kích hoạt hàm ẩn hiện khi click vào mắt biểu tượng
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none, // Ẩn đường viền thô mặc định của TextField
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  // Thanh xác nhận tích chọn đồng ý tuân thủ quy chế và chính sách bảo mật thông tin ứng dụng
  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (val) => setState(() => _agreeToTerms = val!), // Lưu trạng thái thay đổi tick chọn
            activeColor: const Color(0xFFE07A5F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Bo góc nhẹ cho ô checkbox
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
                    decoration: TextDecoration.underline, // Gạch chân đường link
                  ),
                ),
                TextSpan(text: ' và '),
                TextSpan(
                  text: 'Chính sách bảo mật',
                  style: TextStyle(
                    color: Color(0xFFE07A5F),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline, // Gạch chân đường link
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget hiển thị nút Đăng ký tài khoản (Tự động kích hoạt khi trạng thái _agreeToTerms bằng true)
  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: (_agreeToTerms && !_isLoading) ? _handleRegister : null, // Gán giá trị null để vô hiệu hóa nút bấm tạm thời khi chưa tích chọn điều khoản
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41),
        disabledBackgroundColor: Colors.grey.shade300, // Màu nền nút khi nút bị tắt kích hoạt
        disabledForegroundColor: Colors.grey.shade500, // Màu chữ hiển thị khi nút bị tắt kích hoạt
        minimumSize: const Size(double.infinity, 56), // Độ dài full hàng ngang, chiều cao ô nút 56
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
              'Đăng ký tài khoản',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
    );
  }

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ tất cả thông tin')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu phải từ 6 ký tự trở lên')),
      );
      return;
    }

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
          const SnackBar(content: Text('Đăng ký tài khoản thành công!')),
        );
        Navigator.pushNamed(context, '/choose-role');
      } else {
        throw Exception('Không nhận được thông tin User');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Dòng dẫn liên kết giúp người dùng quay ngược lại giao diện Đăng nhập hệ thống
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã có tài khoản? ',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context), // Gọi pop để quay lại màn hình Login trước đó
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