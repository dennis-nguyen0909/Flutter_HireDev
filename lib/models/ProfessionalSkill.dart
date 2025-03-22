class ProfessionalSkill {
  final String title;
  final List<String> items;
  final String id;

  ProfessionalSkill({
    required this.title,
    required this.items,
    required this.id,
  });

  // Phương thức fromJson cho đối tượng ProfessionalSkill
  factory ProfessionalSkill.fromJson(Map<String, dynamic> json) {
    return ProfessionalSkill(
      title: json['title'],
      items: List<String>.from(
        json['items'],
      ), // Chuyển đổi mảng các mục thành List<String>
      id: json['_id'],
    );
  }
}
