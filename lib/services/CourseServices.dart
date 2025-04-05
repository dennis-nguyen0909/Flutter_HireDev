import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';

class CourseServices {
  static Future<dynamic> getCourseByUserToken(
    String userId,
    int current,
    int pageSize,
  ) async {
    final response = await ApiService().get(
      dotenv.env['API_URL']! +
          "courses?current=$current&pageSize=$pageSize&query[user_id]=${userId}",
      token: await SecureStorageService().getRefreshToken(),
    );
    print("getCourseByUserToken: $response");

    // The response is already a Map<String, dynamic>, no need to decode it
    return response;
  }

  static Future<dynamic> createCourse(dynamic course) async {
    final response = await ApiService().post(
      dotenv.env['API_URL']! + "courses",
      course,
      token: await SecureStorageService().getRefreshToken(),
    );
    print(response);
    return response;
  }

  static Future<dynamic> updateCourse(String courseId, dynamic course) async {
    final response = await ApiService().patch(
      dotenv.env['API_URL']! + "courses/${courseId}",
      course,
      token: await SecureStorageService().getRefreshToken(),
    );
    print(response);
    return response;
  }

  static Future<dynamic> deleteCourse(String courseId) async {
    final response = await ApiService().delete(
      dotenv.env['API_URL']! + "courses/${courseId}",
      {},
      token: await SecureStorageService().getRefreshToken(),
    );
    return response;
  }
}
