import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';

class PrizeServices {
  static Future<dynamic> getPrizeByUserToken({
    int current = 1,
    int pageSize = 10,
    String? userId,
  }) async {
    final response = await ApiService().get(
      dotenv.env['API_URL']! +
          "prizes?current=$current&pageSize=$pageSize&query[user_id]=$userId",
      token: await SecureStorageService().getRefreshToken(),
    );

    return response;
  }

  static Future<dynamic> createPrize(dynamic prize) async {
    final response = await ApiService().post(
      dotenv.env['API_URL']! + "prizes",
      prize,
      token: await SecureStorageService().getRefreshToken(),
    );
    print(response);
    return response;
  }

  static Future<dynamic> updatePrize(String prizeId, dynamic prize) async {
    final response = await ApiService().patch(
      dotenv.env['API_URL']! + "prizes/${prizeId}",
      prize,
      token: await SecureStorageService().getRefreshToken(),
    );
    print(response);
    return response;
  }

  static Future<dynamic> deletePrize(String prizeId) async {
    final response = await ApiService().delete(
      dotenv.env['API_URL']! + "prizes/${prizeId}",
      {},
      token: await SecureStorageService().getRefreshToken(),
    );
    return response;
  }
}
