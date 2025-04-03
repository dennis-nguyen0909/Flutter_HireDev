import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Import http_parser

class FileService {
  static Future<String?> uploadFilePdf(String filePath) async {
    SecureStorageService secureStorageService = SecureStorageService();
    try {
      final url = Uri.parse(dotenv.get('API_URL') + 'media/upload-pdf');
      final token = await secureStorageService.getRefreshToken();
      final request = http.MultipartRequest('POST', url);

      // Add authorization header
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Get file information
      final file = File(filePath);
      final fileName = file.path.split('/').last;

      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // Field name for the file upload
          filePath,
          filename: fileName,
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return response.body;
      } else {
        return null; // Or handle the error appropriately
      }
    } catch (e) {
      print('Error during file upload: $e');
      return null;
    }
  }

  static Future<dynamic> updateCvOfUser(
    String cvLink,
    dynamic bytes,
    String cvName,
    String publicId,
    String userId,
  ) async {
    final response = await ApiService().post(
      dotenv.get('API_URL') + 'cvs',
      {
        'user_id': userId,
        'cv_link': cvLink,
        'cv_name': cvName,
        'public_id': publicId,
        'bytes': bytes,
      },
      token: await SecureStorageService().getRefreshToken(),
    );
    // The error occurs because response is already a Map, not a String
    // So we don't need to decode it
    return response;
  }

  static Future<dynamic> deleteCvOfUser(List<String> cvIds) async {
    final response = await ApiService().delete(
      dotenv.get('API_URL') + 'cvs',
      {
        'ids': cvIds,
      }, // This already sends the correct format: {"ids":["67ee12ec3b3d2799774b3f29"]}
      token: await SecureStorageService().getRefreshToken(),
    );
    return response;
  }
}
