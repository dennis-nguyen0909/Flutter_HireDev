class JobResponsibilities {
  final String responsibility;

  JobResponsibilities({required this.responsibility});

  factory JobResponsibilities.fromJson(Map<String, dynamic> json) {
    return JobResponsibilities(responsibility: json['responsibility']);
  }
}
