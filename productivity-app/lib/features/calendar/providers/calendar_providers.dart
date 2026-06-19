import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/finance/providers/finance_providers.dart';
import '../state/calendar_notifier.dart';
import '../state/calendar_state.dart';

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final db = ref.watch(databaseProvider);
  return CalendarNotifier(db);
});
