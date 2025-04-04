import 'package:hiredev/models/DistrictModel.dart';

class CityModel {
  final String id;
  final String name;
  final int code;
  final String divisionType;
  final String codename;
  final int phoneCode;
  final List<DistrictModel> districts;

  CityModel({
    required this.id,
    required this.name,
    required this.code,
    required this.divisionType,
    required this.codename,
    required this.phoneCode,
    required this.districts,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['_id'],
      name: json['name'],
      code: json['code'],
      divisionType: json['division_type'],
      codename: json['codename'],
      phoneCode: json['phone_code'],
      districts:
          (json['districts'] as List)
              .map((district) => DistrictModel.fromJson(district))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'code': code,
      'division_type': divisionType,
      'codename': codename,
      'phone_code': phoneCode,
      'districts': districts.map((district) => district.toJson()).toList(),
    };
  }
}
