import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';

class EducationServices {
  static Future<dynamic> getEducationByUserToken() async {
    final response = await ApiService().get(
      dotenv.env['API_URL']! + "educations/user",
      token: await SecureStorageService().getRefreshToken(),
    );

    // The response is already a Map<String, dynamic>, no need to decode it
    return response;
  }

  static Future<dynamic> createEducation(dynamic education) async {
    final response = await ApiService().post(
      dotenv.env['API_URL']! + "educations",
      education,
    );
  }

  static Future<dynamic> updateEducation(
    String educationId,
    dynamic education,
  ) async {
    final response = await ApiService().patch(
      dotenv.env['API_URL']! + "educations/${educationId}",
      education,
      token: await SecureStorageService().getRefreshToken(),
    );
    print(response);
    return response;
  }

  static Future<dynamic> deleteEducation(String educationId) async {
    final response = await ApiService().delete(
      dotenv.env['API_URL']! + "educations/${educationId}",
      {},
      token: await SecureStorageService().getRefreshToken(),
    );
    return response;
  }
}
