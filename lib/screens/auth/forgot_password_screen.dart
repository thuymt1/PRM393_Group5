import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _api = ApiService();
  bool _loading = false;
  bool _sentView = false;
  bool _otpStep = false;
  bool _passwordStep = false;

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _api.sendPasswordResetOtp(_email.text.trim());
      if (!mounted) return;
      setState(() {
        _sentView = true;
        _loading = false;
      });
      _notice('Mã OTP đã được gửi. Hãy kiểm tra email của bạn.');
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _notice('Không thể gửi mã: $e', error: true);
      }
    }
  }

  Future<void> _reset() async {
    if (_password.text.length < 6 || _password.text != _confirm.text) {
      _notice('Mật khẩu mới phải từ 6 ký tự và trùng nhau', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.updatePassword(_password.text);
      await _api.signOut();
      if (!mounted) return;
      _notice('Đổi mật khẩu thành công!');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _notice('Không thể đổi mật khẩu. Vui lòng thử lại.', error: true);
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (!RegExp(r'^\d{6}$').hasMatch(_otp.text.trim())) {
      _notice('Vui lòng nhập đủ mã OTP 6 số', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.verifyPasswordResetOtp(_email.text.trim(), _otp.text.trim());
      if (!mounted) return;
      setState(() {
        _loading = false;
        _passwordStep = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        _notice('Mã OTP sai hoặc đã hết hạn', error: true);
      }
    }
  }

  void _notice(String text, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: error ? Colors.red.shade600 : Colors.green.shade700,
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
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
      padding: const EdgeInsets.all(24),
      child: _passwordStep
          ? _passwordView()
          : (_otpStep
                ? _otpView()
                : (_sentView ? _sentViewWidget() : _emailView())),
    ),
  );

  Widget _emailView() => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        const Icon(Icons.lock_reset, size: 60, color: Color(0xFFE07A5F)),
        const SizedBox(height: 20),
        const Text(
          'Quên mật khẩu?',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Nhập email đăng ký để nhận mã OTP đặt lại mật khẩu.'),
        const SizedBox(height: 30),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
          decoration: const InputDecoration(
            labelText: 'Email đăng ký',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Mã đặt lại mật khẩu sẽ hết hạn trong 60 giây',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        _button('Gửi mã', _send),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('< Quay lại đăng nhập'),
        ),
      ],
    ),
  );

  Widget _sentViewWidget() => Column(
    children: [
      const SizedBox(height: 40),
      const Icon(
        Icons.mark_email_read_rounded,
        size: 80,
        color: Color(0xFFE07A5F),
      ),
      const SizedBox(height: 28),
      const Text(
        'Đã gửi email thành công',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6D4C41),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Chúng tôi đã gửi mã đặt lại mật khẩu đến email ${_email.text.trim()}. Vui lòng kiểm tra hộp thư của bạn (kèm thư mục thư rác).',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 40),
      _button('Nhập mã OTP', () => setState(() => _otpStep = true)),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: () => setState(() {
          _sentView = false;
          _email.clear();
        }),
        child: const Text('Dùng email khác'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Quay lại đăng nhập'),
      ),
    ],
  );

  Widget _otpView() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 30),
      const Icon(
        Icons.mark_email_read_outlined,
        size: 60,
        color: Color(0xFFE07A5F),
      ),
      const SizedBox(height: 20),
      const Text(
        'Đặt lại mật khẩu',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6D4C41),
        ),
      ),
      const SizedBox(height: 12),
      Text('Mã OTP đã gửi tới ${_email.text.trim()}.'),
      const SizedBox(height: 24),
      TextField(
        controller: _otp,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: const InputDecoration(
          labelText: 'Mã OTP 6 số',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 24),
      _button('Xác nhận mã', _verifyOtp),
    ],
  );

  Widget _passwordView() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 30),
      const Icon(Icons.password_rounded, size: 60, color: Color(0xFFE07A5F)),
      const SizedBox(height: 20),
      const Text(
        'Tạo mật khẩu mới',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6D4C41),
        ),
      ),
      const SizedBox(height: 12),
      const Text('Mã xác nhận chính xác. Hãy nhập mật khẩu mới của bạn.'),
      const SizedBox(height: 24),
      TextField(
        controller: _password,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Mật khẩu mới',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _confirm,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Nhập lại mật khẩu mới',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 24),
      _button('Đổi mật khẩu', _reset),
    ],
  );

  Widget _button(String text, VoidCallback action) => ElevatedButton(
    onPressed: _loading ? null : action,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6D4C41),
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 56),
    ),
    child: _loading
        ? const CircularProgressIndicator(color: Colors.white)
        : Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}
