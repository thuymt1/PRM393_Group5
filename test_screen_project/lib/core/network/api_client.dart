import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

/// HTTP client trung tam.
/// Tu dong inject JWT cua Supabase vao moi request gui den Backend.
class ApiClient {
  final String _baseUrl = AppConstants.backendBaseUrl;

  /// Lay JWT tu Supabase Auth session hien tai
  String? get _token => Supabase.instance.client.auth.currentSession?.accessToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    var uri = Uri.parse('$_baseUrl$path');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(Uri.parse('$_baseUrl$path'), headers: _headers);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 401) {
      throw Exception('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.');
    } else if (response.statusCode == 403) {
      throw Exception('Bạn không có quyền thực hiện thao tác này.');
    } else {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(body['error'] ?? body['message'] ?? 'Lỗi server: ${response.statusCode}');
    }
  }
}
