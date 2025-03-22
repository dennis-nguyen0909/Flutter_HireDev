class Ward {
  final String id;
  final String name;
  final int code;
  final String codename;
  final String divisionType;
  final String shortCodename;

  Ward({
    required this.id,
    required this.name,
    required this.code,
    required this.codename,
    required this.divisionType,
    required this.shortCodename,
  });

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      id: json['_id'],
      name: json['name'],
      code: json['code'],
      codename: json['codename'],
      divisionType: json['division_type'],
      shortCodename: json['short_codename'],
    );
  }
}
