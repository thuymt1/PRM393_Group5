import 'url_helper_stub.dart'
    if (dart.library.html) 'url_helper_web.dart'
    if (dart.library.io) 'url_helper_mobile.dart';

class UrlHelper {
  /// Xoá toàn bộ query parameters trên thanh địa chỉ trình duyệt (Web) mà không làm reload trang.
  static void clearQueryParameters() {
    clearUrlParams();
  }
}
