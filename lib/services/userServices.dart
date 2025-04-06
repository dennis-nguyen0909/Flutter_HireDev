import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';

class UserServices {
  static Future<dynamic> updateUser(
    Map<String, dynamic> data, {
    required BuildContext context,
  }) async {
    print('data $data');
    final response = await ApiService().patch(
      dotenv.get('API_URL') + 'users',
      data,
      token: await SecureStorageService().getRefreshToken(),
    );
    print('response1111 $response');
    if (response['statusCode'] == 200 && response['data'] != null) {
      final userId = response['data']['_id'];
      if (userId != null) {
        print("d9a4 voi $userId");
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.fetchUserDetails(userId);
      }
    }
    return response;
  }

  static Future<dynamic> changePassword(Map<String, dynamic> data) async {
    final response = await ApiService().post(
      dotenv.get('API_URL') + 'users/reset-password',
      data,
      token: await SecureStorageService().getRefreshToken(),
    );
    return response;
  }
}
