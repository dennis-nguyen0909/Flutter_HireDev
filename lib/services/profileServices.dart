import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';

class ProfileServices {
  static Future<dynamic> getJobAppliedOfCandidate(String userId) async {
    final token = await SecureStorageService().getRefreshToken();
    final response = await ApiService().get(
      dotenv.env['API_URL']! + 'applications/applied/$userId',
      token: token,
    );
    return response;
  }

  static Future<dynamic> getJobSavedOfCandidate(
    String userId,
    int current,
    int pageSize,
  ) async {
    final token = await SecureStorageService().getRefreshToken();
    final response = await ApiService().get(
      dotenv.env['API_URL']! +
          'favorite-jobs?current=$current&pageSize=$pageSize&query[user_id]=$userId',
      token: token,
    );
    return response['data']['meta']['total'];
  }
}
