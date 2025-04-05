import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';

class SkillServices {
  static Future<dynamic> getSkillByUserToken() async {
    final response = await ApiService().get(
      dotenv.env['API_URL']! + "skills/user",
      token: await SecureStorageService().getRefreshToken(),
    );

    return response;
  }

  static Future<dynamic> createSkill(dynamic skill) async {
    final response = await ApiService().post(
      dotenv.env['API_URL']! + "skills",
      skill,
      token: await SecureStorageService().getRefreshToken(),
    );
    print(response);
    return response;
  }

  static Future<dynamic> updateSkill(String skillId, dynamic skill) async {
    final response = await ApiService().patch(
      dotenv.env['API_URL']! + "skills/${skillId}",
      skill,
      token: await SecureStorageService().getRefreshToken(),
    );
    print(response);
    return response;
  }

  static Future<dynamic> deleteSkill(String skillId) async {
    final response = await ApiService().delete(
      dotenv.env['API_URL']! + "skills",
      {
        "ids": [skillId],
      },
      token: await SecureStorageService().getRefreshToken(),
    );
    return response;
  }
}
