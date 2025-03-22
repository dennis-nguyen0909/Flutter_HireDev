class Degree {
  final String id;
  final String name;
  final String key;
  final String description;
  final String userId;

  Degree({
    required this.id,
    required this.name,
    required this.key,
    required this.description,
    required this.userId,
  });

  factory Degree.fromJson(Map<String, dynamic> json) {
    return Degree(
      id: json['_id'],
      name: json['name'],
      key: json['key'],
      description: json['description'],
      userId: json['user_id'],
    );
  }
}
