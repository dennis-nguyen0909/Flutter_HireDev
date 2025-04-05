import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';

class ExperienceServices {
  static Future<dynamic> getExperienceByUserToken(
    String userId,
    int current,
    int pageSize,
  ) async {
    final response = await ApiService().get(
      dotenv.env['API_URL']! + "work-experiences/user",
      token: await SecureStorageService().getRefreshToken(),
    );

    // The response is already a Map<String, dynamic>, no need to decode it
    return response;
  }

  static Future<dynamic> createExperience(dynamic experience) async {
    final response = await ApiService().post(
      dotenv.env['API_URL']! + "work-experiences",
      experience,
      token: await SecureStorageService().getRefreshToken(),
    );
    print(response);
    return response;
  }

  static Future<dynamic> updateExperience(
    String experienceId,
    dynamic experience,
  ) async {
    final response = await ApiService().patch(
      dotenv.env['API_URL']! + "work-experiences/${experienceId}",
      experience,
      token: await SecureStorageService().getRefreshToken(),
    );
    print(response);
    return response;
  }

  static Future<dynamic> deleteExperience(String experienceId) async {
    final response = await ApiService().delete(
      dotenv.env['API_URL']! + "work-experiences",
      {
        "ids": [experienceId],
      },
      token: await SecureStorageService().getRefreshToken(),
    );
    print(response);
    return response;
  }
}
