/// Tập trung toàn bộ logic validation cho các trường nhập liệu trong ứng dụng
class Validators {
  Validators._(); // Ngăn khởi tạo instance - chỉ dùng static methods

  // ─── EMAIL ────────────────────────────────────────────────────────────────

  /// Kiểm tra định dạng email hợp lệ
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email không được để trống';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không đúng định dạng (vd: example@email.com)';
    }
    return null;
  }

  // ─── PASSWORD ─────────────────────────────────────────────────────────────

  /// Kiểm tra mật khẩu: tối thiểu 6 ký tự
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  /// Kiểm tra mật khẩu nâng cao: tối thiểu 6 ký tự, có chữ hoa & số
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 chữ hoa';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 chữ số';
    }
    return null;
  }

  /// Kiểm tra xác nhận mật khẩu khớp
  static String? validateConfirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != original) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  // ─── PHONE ────────────────────────────────────────────────────────────────

  /// Kiểm tra số điện thoại Việt Nam (10 chữ số, bắt đầu bằng 0)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    // Loại bỏ khoảng trắng và dấu gạch
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Số điện thoại không hợp lệ (10 chữ số, bắt đầu bằng 0)';
    }
    return null;
  }

  // ─── NAME ─────────────────────────────────────────────────────────────────

  /// Kiểm tra họ tên: không rỗng, tối thiểu 2 ký tự, không chứa số/ký tự đặc biệt
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Họ và tên không được để trống';
    }
    if (value.trim().length < 2) {
      return 'Họ và tên phải có ít nhất 2 ký tự';
    }
    // Cho phép chữ cái có dấu (Unicode) và khoảng trắng
    final nameRegex = RegExp(r"^[\p{L}\s]+$", unicode: true);
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Họ và tên không được chứa số hoặc ký tự đặc biệt';
    }
    return null;
  }

  // ─── PASSWORD STRENGTH ────────────────────────────────────────────────────

  /// Đánh giá độ mạnh của mật khẩu: 0=Yếu, 1=Trung bình, 2=Mạnh
  static int passwordStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    if (score <= 1) return 0; // Yếu
    if (score == 2 || score == 3) return 1; // Trung bình
    return 2; // Mạnh
  }
}
