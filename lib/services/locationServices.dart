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
    final response = await ApiService().get(
      dotenv.get('API_URL') + '/cities/$cityId/districts',
    );

    if (response['statusCode'] == 200) {
      final List<dynamic> districts = response['data']['items']['districts'];
      return districts.map((json) => DistrictModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load districts');
    }
  }

  static Future<List<WardModel>> getWards(String districtId) async {
    final response = await ApiService().get(
      dotenv.get('API_URL') + '/districts/$districtId/wards',
    );

    if (response['statusCode'] == 200) {
      final List<dynamic> wards = response['data']['items']['wards'];
      return wards.map((json) => WardModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load wards');
    }
  }
}
