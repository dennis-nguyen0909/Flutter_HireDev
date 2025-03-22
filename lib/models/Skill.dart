class Skill {
  final String id;
  final String name;
  final int v;

  Skill({required this.id, required this.name, required this.v});
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(id: json['_id'], name: json['name'], v: json['__v']);
  }
}
