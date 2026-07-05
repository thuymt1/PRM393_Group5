import 'dart:html' as html;

void clearUrlParams() {
  try {
    final href = html.window.location.href;
    final uri = Uri.parse(href);
    
    // Kiểm tra xem có query params hoặc fragment chứa mã xác thực không
    bool hasQuery = uri.queryParameters.isNotEmpty;
    bool hasTokenFragment = uri.fragment.contains('access_token') || uri.fragment.contains('type=recovery');

    if (hasQuery || hasTokenFragment) {
      // Thay thế bằng đường dẫn sạch (loại bỏ các thông số nhảy trang)
      final newUri = uri.replace(
        queryParameters: {}, 
        // Nếu dùng hash routing và fragment đang giữ token, reset nó về trang mặc định (VD: /login)
        fragment: hasTokenFragment ? '/login' : uri.fragment
      );
      
      html.window.history.replaceState({}, '', newUri.toString());
    }
  } catch (_) {}
}
