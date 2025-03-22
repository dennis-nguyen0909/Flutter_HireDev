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

  // Hàm GET chung để gọi API
  Future<dynamic> get(String url) async {
    final uri = Uri.parse(url);

    try {
      final response = await http.get(uri);
      print(response);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Yêu cầu thất bại với mã trạng thái: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      throw ApiException('Lỗi khi gọi API: $e');
    }
  }

  Future<dynamic> post(String url, Map<String, dynamic> data) async {
    final uri = Uri.parse(url);
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      // Nếu phản hồi có mã thành công (200-299), trả về JSON
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        // Kiểm tra xem response body có phải là JSON hợp lệ không
        try {
          final errorResponse = json.decode(response.body);
          throw ApiException(
            errorResponse['message'] ?? 'Đã xảy ra lỗi không xác định',
            statusCode: response.statusCode,
            responseBody: response.body,
          );
        } catch (e) {
          print(e);
          // Nếu body không phải JSON hợp lệ, ném lỗi với thông điệp chung
          throw ApiException(e.toString());
        }
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
