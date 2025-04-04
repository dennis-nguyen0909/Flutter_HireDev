class WardModel {
  final String id;
  final String name;
  final int code;
  final String codename;
  final String divisionType;
  final String shortCodename;

  WardModel({
    required this.id,
    required this.name,
    required this.code,
    required this.codename,
    required this.divisionType,
    required this.shortCodename,
  });

  factory WardModel.fromJson(Map<String, dynamic> json) {
    return WardModel(
      id: json['_id'],
      name: json['name'],
      code: json['code'],
      codename: json['codename'],
      divisionType: json['division_type'],
      shortCodename: json['short_codename'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'code': code,
      'codename': codename,
      'division_type': divisionType,
      'short_codename': shortCodename,
    };
  }
}
