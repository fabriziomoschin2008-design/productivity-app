import 'package:intl/intl.dart';

final _short = DateFormat('d MMM', 'it_IT');
final _medium = DateFormat('d MMM yyyy', 'it_IT');
final _monthYear = DateFormat('MMM yyyy', 'it_IT');
final _monthShort = DateFormat('MMM', 'it_IT');

String formatDateShort(DateTime date) => _short.format(date);
String formatDateMedium(DateTime date) => _medium.format(date);
String formatMonthYear(DateTime date) => _monthYear.format(date);
String formatMonthShort(DateTime date) => _monthShort.format(date);
