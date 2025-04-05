import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';

class CertificateServices {
  static Future<Map<String, dynamic>> getCertificatesByUserToken({
    int current = 1,
    int pageSize = 10,
    String? userId,
  }) async {
    try {
      final token = await SecureStorageService().getRefreshToken();
      final response = await ApiService().get(
        '${dotenv.env['API_URL']}certificates?current=$current&pageSize=$pageSize${userId != null ? '&user_id=$userId' : ''}',
        token: token,
      );
      return response;
    } catch (e) {
      print('Error getting certificates: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createCertificate(
    Map<String, dynamic> certificate,
  ) async {
    try {
      final token = await SecureStorageService().getRefreshToken();
      final response = await ApiService().post(
        '${dotenv.env['API_URL']}certificates',
        certificate,
        token: token,
      );
      return response;
    } catch (e) {
      print('Error creating certificate: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateCertificate(
    String id,
    Map<String, dynamic> certificate,
  ) async {
    try {
      final token = await SecureStorageService().getRefreshToken();
      final response = await ApiService().patch(
        '${dotenv.env['API_URL']}certificates/$id',
        certificate,
        token: token,
      );
      return response;
    } catch (e) {
      print('Error updating certificate: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteCertificate(String id) async {
    try {
      final token = await SecureStorageService().getRefreshToken();
      final response = await ApiService().delete(
        '${dotenv.env['API_URL']}certificates/$id',
        {},
        token: token,
      );
      return response;
    } catch (e) {
      print('Error deleting certificate: $e');
      rethrow;
    }
  }
}
