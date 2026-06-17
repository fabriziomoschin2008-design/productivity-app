import 'package:intl/intl.dart';

final _formatter = NumberFormat.currency(
  locale: 'it_IT',
  symbol: '€',
  decimalDigits: 2,
);

String formatCurrency(double amount) => _formatter.format(amount);

String formatAmount(double amount, {bool signed = false}) {
  final abs = _formatter.format(amount.abs());
  if (!signed) return abs;
  return amount >= 0 ? '+$abs' : '-$abs';
}
