class PrizeModel {
  final String? id;
  final String? name;
  final String? description;
  final String? date;
  final String? organization;
  final String? userId;

  PrizeModel({
    this.id,
    this.name,
    this.description,
    this.date,
    this.organization,
    this.userId,
  });

  factory PrizeModel.fromJson(Map<String, dynamic> json) {
    return PrizeModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      date: json['date'],
      organization: json['organization'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'date': date,
      'organization': organization,
      'userId': userId,
    };
  }
}
