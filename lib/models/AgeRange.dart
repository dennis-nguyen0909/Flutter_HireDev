class AgeRange {
  final int min;
  final int max;

  AgeRange({required this.min, required this.max});

  factory AgeRange.fromJson(Map<String, dynamic> json) {
    return AgeRange(min: json['min'], max: json['max']);
  }
}
