class LocationModel {
  String id;
  String name;
  int code;
  String divisionType;
  String codename;
  int phoneCode;
  List<dynamic> districts;

  LocationModel({
    required this.id,
    required this.name,
    required this.code,
    required this.divisionType,
    required this.codename,
    required this.phoneCode,
    required this.districts,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['_id'],
      name: json['name'],
      code: json['code'],
      divisionType: json['division_type'],
      codename: json['codename'],
      phoneCode: json['phone_code'],
      districts: json['districts'],
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
      'districts': districts,
    };
  }
}
