class TypeMoney {
  final String id;
  final String name;
  final String code;
  final String symbol;
  final String key;
  final String userId;

  TypeMoney({
    required this.id,
    required this.name,
    required this.code,
    required this.symbol,
    required this.key,
    required this.userId,
  });

  factory TypeMoney.fromJson(Map<String, dynamic> json) {
    return TypeMoney(
      id: json['_id'],
      name: json['name'],
      code: json['code'],
      symbol: json['symbol'],
      key: json['key'],
      userId: json['user_id'],
    );
  }
}
