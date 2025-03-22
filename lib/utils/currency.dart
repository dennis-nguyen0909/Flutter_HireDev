import 'package:intl/intl.dart';

class Currency {
  static String formatCurrencyWithSymbol(int amount, String symbol) {
    return NumberFormat.currency(
      locale: 'vi-VN',
      symbol: symbol,
    ).format(amount);
  }
}
