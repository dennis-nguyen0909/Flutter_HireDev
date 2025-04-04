import 'package:hiredev/models/WardModel.dart';

class DistrictModel {
  final String id;
  final String name;
  final int code;
  final String codename;
  final List<WardModel>? wards;
  DistrictModel({
    required this.id,
    required this.name,
    required this.code,
    required this.codename,
    this.wards,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['_id'],
      name: json['name'],
      code: json['code'],
      codename: json['codename'],
      wards:
          json['wards'] != null
              ? (json['wards'] as List)
                  .map((ward) => WardModel.fromJson(ward))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'code': code,
      'codename': codename,
      'wards': wards?.map((ward) => ward.toJson()).toList(),
    };
  }
}
