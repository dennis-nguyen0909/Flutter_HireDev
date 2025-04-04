class ProjectModel {
  final String? id;
  final String? name;
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? role;
  final List<String>? technologies;
  final String? projectUrl;
  final String? userId;

  ProjectModel({
    this.id,
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.role,
    this.technologies,
    this.projectUrl,
    this.userId,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      role: json['role'],
      technologies:
          json['technologies'] != null
              ? List<String>.from(json['technologies'])
              : null,
      projectUrl: json['projectUrl'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'role': role,
      'technologies': technologies,
      'projectUrl': projectUrl,
      'userId': userId,
    };
  }
}
