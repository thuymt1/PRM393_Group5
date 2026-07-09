class ErrorHandler {
  static String getMessage(dynamic error) {
    if (error == null) return 'Đã xảy ra lỗi không xác định.';
    
    final errorString = error.toString();
    
    // Supabase Auth Exceptions
    if (errorString.contains('AuthException')) {
      if (errorString.contains('Invalid login credentials')) {
        return 'Email hoặc mật khẩu không chính xác.';
      } else if (errorString.contains('User already registered')) {
        return 'Email này đã được đăng ký.';
      } else if (errorString.contains('Password should be at least')) {
        return 'Mật khẩu quá yếu (phải chứa ít nhất 6 ký tự).';
      } else if (errorString.contains('Email link is invalid or has expired')) {
        return 'Link xác nhận không hợp lệ hoặc đã hết hạn.';
      }
      return 'Lỗi xác thực. Vui lòng thử lại.';
    }

    // Backend Exceptions
    if (errorString.contains('Exception:')) {
      // Extract the message part after "Exception: "
      final message = errorString.replaceFirst('Exception:', '').trim();
      
      // Known Backend messages
      if (message.contains('Phiên đăng nhập hết hạn')) {
        return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
      } else if (message.contains('Bạn không có quyền')) {
        return 'Bạn không có quyền thực hiện thao tác này.';
      } else if (message.contains('Connection refused') || message.contains('Failed host lookup')) {
        return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.';
      }
      
      // If it's a raw backend message or something else, return it directly if it's safe
      if (message.isNotEmpty) {
        // To prevent showing JSON strings or weird chars, we can filter it
        if (message.startsWith('{') || message.contains('[')) {
          return 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.';
        }
        return message;
      }
    }
    
    // Generic fallback
    if (errorString.contains('SocketException')) {
      return 'Lỗi mạng. Vui lòng kiểm tra kết nối internet.';
    }

    return 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.';
  }
}
