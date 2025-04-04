import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/models/CityModel.dart';
import 'package:hiredev/models/DistrictModel.dart';
import 'package:hiredev/models/WardModel.dart';
import 'package:hiredev/services/apiServices.dart';

class LocationServices {
  static Future<List<CityModel>> getCities() async {
    final response = await ApiService().get(
      dotenv.get('API_URL') + 'cities?depth=1',
    );

    print("response: $response");

    if (response['statusCode'] == 200) {
      final List<dynamic> data = response['data'];
      return data.map((json) => CityModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cities');
    }
  }

  static Future<List<DistrictModel>> getDistricts(String cityId) async {
    try {
      final response = await ApiService().get(
        dotenv.get('API_URL') + 'cities/$cityId/districts',
      );

      if (response['statusCode'] == 200) {
        // Safely navigate through the response structure
        if (response['data'] != null) {
          // Check different possible response structures
          List<dynamic> districts = [];

          if (response['data'] is List) {
            // If data is directly a list
            districts = response['data'];
          } else if (response['data'] is Map) {
            // If data is a map, try to find districts inside
            if (response['data']['districts'] != null &&
                response['data']['districts'] is List) {
              districts = response['data']['districts'];
            } else if (response['data']['items'] != null &&
                response['data']['items'] is List) {
              districts = response['data']['items'];
            }
          }

          print("districts111: $districts");
          return districts.map((json) => DistrictModel.fromJson(json)).toList();
        } else {
          print("No data in response");
          return [];
        }
      } else {
        throw Exception('Failed to load districts: ${response['message']}');
      }
    } catch (e) {
      print('Error in getDistricts: $e');
      return [];
    }
  }

  static Future<List<WardModel>> getWards(String districtId) async {
    try {
      final response = await ApiService().get(
        dotenv.get('API_URL') + 'districts/$districtId/wards',
      );

      print("responseWards: ${response}");
      if (response['statusCode'] == 200) {
        // Check if the expected path exists
        if (response['data'] != null &&
            response['data'] != null &&
            response['data']['wards'] != null &&
            response['data']['wards'] is List) {
          final List<dynamic> wards = response['data']['wards'];
          return wards.map((json) => WardModel.fromJson(json)).toList();
        } else {
          print("Invalid wards data structure: ${response['data']}");
          return [];
        }
      } else {
        throw Exception('Failed to load wards: ${response['message']}');
      }
    } catch (e) {
      print('Error in getWards: $e');
      return [];
    }
  }
}
