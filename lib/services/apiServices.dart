import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseBody;

  ApiException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() {
    return message; // Trả về chỉ message
  }
}

class ApiService {
  // Singleton pattern để tạo ra một instance duy nhất của ApiService
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  Future<dynamic> get(String url, {String? token}) async {
    final uri = Uri.parse(url);
    final headers = <String, String>{}; // Khởi tạo headers trống

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(
        uri,
        headers: headers, // Sử dụng headers đã được tạo
      );

      return json.decode(response.body);
    } catch (e) {
      throw ApiException('Lỗi khi gọi API: $e');
    }
  }

  Future<dynamic> post(
    String url,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    final uri = Uri.parse(url);
    final headers = <String, String>{};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    headers['Content-Type'] = 'application/json';

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(data),
      );

      return json.decode(response.body);
    } catch (e) {
      // Xử lý lỗi từ http hoặc lỗi JSON
      print("Lỗi: $e");
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> put(
    String url,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    final uri = Uri.parse(url);
    final headers = <String, String>{};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    headers['Content-Type'] = 'application/json';

    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(data),
      );

      return json.decode(response.body);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> delete(
    String url,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    final uri = Uri.parse(url);
    final headers = <String, String>{};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    headers['Content-Type'] = 'application/json';

    try {
      final response = await http.delete(
        uri,
        headers: headers,
        body: json.encode(data),
      );
      return json.decode(response.body);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> patch(
    String url,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    final uri = Uri.parse(url);
    final headers = <String, String>{};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    headers['Content-Type'] = 'application/json';

    try {
      final response = await http.patch(
        uri,
        headers: headers,
        body: json.encode(data),
      );
      return json.decode(response.body);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
