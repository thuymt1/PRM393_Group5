import 'package:flutter/material.dart';

// Hàm main() - Điểm khởi chạy đầu tiên của ứng dụng Flutter
void main() {
  runApp(const MyApp());
}

// Lớp cấu hình ứng dụng (MaterialApp) bọc quanh màn hình Login
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Test Đăng Nhập',
      debugShowCheckedModeBanner: false, // Ẩn banner chữ DEBUG ở góc màn hình
      theme: ThemeData(
        primaryColor: const Color(0xFF6D4C41), // Màu chủ đạo của hệ thống
        useMaterial3: true, // Kích hoạt giao diện Material 3 mới nhất
      ),
      home: const LoginScreen(), // Đặt LoginScreen làm màn hình mặc định khi khởi động
    );
  }
}

// Màn hình Đăng nhập chính
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Trạng thái dùng để ẩn hoặc hiện mật khẩu (true: ẩn, false: hiện)
  bool _obscureText = true;

  // Bộ điều khiển để lấy dữ liệu từ các ô nhập liệu
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAE7), // Màu nền tổng thể phong cách nhẹ nhàng
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Làm trong suốt thanh AppBar
        elevation: 0, // Xóa bỏ bóng đổ của thanh AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
          onPressed: () => Navigator.pop(context), // Quay lại màn hình trước đó
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeader(), // Hiển thị dòng chữ chào mừng
            const SizedBox(height: 48),
            _buildLoginForm(), // Hiển thị form nhập tài khoản & mật khẩu
            const SizedBox(height: 16),
            _buildForgotPassword(), // Hiển thị nút quên mật khẩu
            const SizedBox(height: 40),
            _buildLoginButton(), // Nút bấm thực hiện đăng nhập
            const SizedBox(height: 32),
            _buildSocialLogin(), // Khu vực đăng nhập bằng mạng xã hội
            const SizedBox(height: 40),
            _buildSignUpLink(), // Liên kết dẫn đến màn hình đăng ký
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Khối giao diện tiêu đề (Header)
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
            fontFamily: 'BeVietnamPro', // Cần cấu hình font này trong pubspec.yaml nếu muốn hiển thị chuẩn
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

  // Khối form nhập liệu chứa các TextField
  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildTextField(
          label: 'Email',
          hint: 'alexandria.b@example.com',
          icon: Icons.email_outlined,
          controller: _emailController,
        ),
        const SizedBox(height: 24),
        _buildTextField(
          label: 'Mật khẩu',
          hint: '••••••••',
          icon: Icons.lock_outline,
          isPassword: true,
          controller: _passwordController,
        ),
      ],
    );
  }

  // Hàm tùy biến dùng chung để tạo ra các ô nhập liệu (TextField) đẹp mắt
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
            obscureText: isPassword ? _obscureText : false, // Ẩn văn bản nếu là mật khẩu
            style: const TextStyle(fontSize: 15),
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
                onPressed: () => setState(() => _obscureText = !_obscureText), // Đảo ngược trạng thái ẩn/hiện
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none, // Ẩn viền mặc định đi để dùng viền của Container
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  // Thành phần text link "Quên mật khẩu?"
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Xử lý sự kiện quên mật khẩu tại đây
        },
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

  // Nút bấm thực hiện hành động Đăng nhập
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        // Thực hiện kết nối API hoặc kiểm tra tài khoản mật khẩu tại đây
        print("Email nhập vào: ${_emailController.text}");
        print("Mật khẩu nhập vào: ${_passwordController.text}");
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41),
        minimumSize: const Size(double.infinity, 56), // Chiều rộng tối đa, chiều cao là 56
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
      ),
      child: const Text(
        'Đăng nhập',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // Khối đăng nhập bằng các tài khoản Mạng xã hội thứ ba
  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()), // Đường vạch kẻ bên trái
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Hoặc đăng nhập với',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ),
            const Expanded(child: Divider()), // Đường vạch kẻ bên phải
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon('https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg'),
            const SizedBox(width: 24),
            _socialIcon('https://upload.wikimedia.org/wikipedia/commons/0/05/Facebook_Logo_%282019%29.png'),
          ],
        ),
      ],
    );
  }

  // Hàm hỗ trợ vẽ ô tròn chứa icon của mạng xã hội
  Widget _socialIcon(String url) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Image.network(url, width: 24, height: 24), // Tải ảnh trực tiếp từ đường dẫn internet
    );
  }

  // Thành phần text điều hướng sang trang Đăng ký (Sign Up)
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
            // Chuyển hướng người dùng qua trang Đăng ký tại đây
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