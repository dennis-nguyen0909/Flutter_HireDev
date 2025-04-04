class CourseModel {
  final String? id;
  final String? name;
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? organization;
  final String? certificateUrl;
  final String? userId;

  CourseModel({
    this.id,
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.organization,
    this.certificateUrl,
    this.userId,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      organization: json['organization'],
      certificateUrl: json['certificateUrl'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'organization': organization,
      'certificateUrl': certificateUrl,
      'userId': userId,
    };
  }
}
