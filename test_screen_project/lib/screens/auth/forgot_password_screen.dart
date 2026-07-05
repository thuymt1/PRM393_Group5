import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';

/// Màn hình Quên Mật Khẩu – gửi link qua email để đặt lại mật khẩu
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _apiService.sendPasswordResetOtp(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final msg = e.message.toLowerCase();
      
      // Với lý do bảo mật, nếu email không tồn tại hoặc lỗi tương tự ta vẫn báo thành công
      if (msg.contains('rate limit') || msg.contains('too many') || msg.contains('seconds')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bạn đã gửi quá nhiều yêu cầu. Vui lòng chờ vài phút rồi thử lại.'),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        setState(() => _emailSent = true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lỗi kết nối mạng. Vui lòng kiểm tra internet.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
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
        child: _emailSent ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  // ─── Giao diện nhập email gửi link ──────────────────────────────────────────
  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildHeader(),
          const SizedBox(height: 48),
          _buildEmailField(),
          const SizedBox(height: 12),
          _buildHelpText(),
          const SizedBox(height: 40),
          _buildSubmitButton(),
          const SizedBox(height: 24),
          _buildBackToLoginLink(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE07A5F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.lock_reset_rounded, size: 40, color: Color(0xFFE07A5F)),
        ),
        const SizedBox(height: 24),
        const Text(
          'Quên mật khẩu?',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontFamily: 'BeVietnamPro',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Nhập email đăng ký của bạn – chúng tôi sẽ gửi link đặt lại mật khẩu về email đó.',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email đăng ký',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6D4C41), fontSize: 14),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'example@email.com',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFE07A5F), size: 22),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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

  Widget _buildHelpText() {
    return Row(
      children: [
        Icon(Icons.info_outline, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Link đặt lại mật khẩu sẽ hết hạn trong 10 phút.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSendResetLink,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D4C41),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: const Color(0xFF6D4C41).withOpacity(0.3),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Gửi link đặt lại',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
    );
  }

  Widget _buildBackToLoginLink() {
    return Center(
      child: TextButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 14, color: Color(0xFFE07A5F)),
        label: const Text(
          'Quay lại đăng nhập',
          style: TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  // ─── Giao diện thông báo thành công ─────────────────────────────────────────
  Widget _buildSuccessView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFE07A5F).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_rounded, size: 80, color: Color(0xFFE07A5F)),
        ),
        const SizedBox(height: 32),
        const Text(
          'Đã gửi email thành công',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41),
            fontFamily: 'BeVietnamPro',
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            text: 'Chúng tôi đã gửi đường dẫn đặt lại mật khẩu đến email ',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.6),
            children: [
              TextSpan(
                text: _emailController.text.trim(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
              ),
              const TextSpan(text: '. Vui lòng kiểm tra hộp thư của bạn (kèm thư mục spam).'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
              _emailController.clear();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF6D4C41),
            side: const BorderSide(color: Color(0xFF6D4C41)),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Dùng email khác', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6D4C41),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Quay lại đăng nhập', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
