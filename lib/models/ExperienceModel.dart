class ExperienceModel {
  final String? id;
  final String? companyName;
  final String? position;
  final String? description;
  final String? startDate;
  final String? endDate;
  final bool? isCurrent;
  final String? location;
  final List<String>? responsibilities;
  final String? userId;

  ExperienceModel({
    this.id,
    this.companyName,
    this.position,
    this.description,
    this.startDate,
    this.endDate,
    this.isCurrent,
    this.location,
    this.responsibilities,
    this.userId,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['_id'],
      companyName: json['companyName'],
      position: json['position'],
      description: json['description'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      isCurrent: json['isCurrent'],
      location: json['location'],
      responsibilities:
          json['responsibilities'] != null
              ? List<String>.from(json['responsibilities'])
              : null,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'position': position,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'isCurrent': isCurrent,
      'location': location,
      'responsibilities': responsibilities,
      'userId': userId,
    };
  }
}
