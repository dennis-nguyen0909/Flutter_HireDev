class Benefit {
  final String benefit;

  Benefit({required this.benefit});

  factory Benefit.fromJson(String json) {
    return Benefit(benefit: json);
  }
}
