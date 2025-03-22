class GeneralRequirement {
  final String requirement;

  GeneralRequirement({required this.requirement});

  factory GeneralRequirement.fromJson(Map<String, dynamic> json) {
    return GeneralRequirement(requirement: json['requirement']);
  }
}
