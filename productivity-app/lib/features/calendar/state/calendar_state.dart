import '../../../data/local/database.dart';

enum HabitView { daily, weekly, monthly }

enum CalendarTab { habits, events }

class CalendarState {
  final List<Habit> habits;
  final List<HabitLog> habitLogs;
  final List<CalendarEvent> events;
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final HabitView habitView;
  final CalendarTab activeTab;

  const CalendarState({
    required this.habits,
    required this.habitLogs,
    required this.events,
    required this.selectedDate,
    required this.focusedMonth,
    required this.habitView,
    required this.activeTab,
  });

  factory CalendarState.initial() {
    final now = DateTime.now();
    return CalendarState(
      habits: const [],
      habitLogs: const [],
      events: const [],
      selectedDate: DateTime(now.year, now.month, now.day),
      focusedMonth: DateTime(now.year, now.month),
      habitView: HabitView.daily,
      activeTab: CalendarTab.habits,
    );
  }

  DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String statusForHabit(String habitId, DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    try {
      return habitLogs
          .firstWhere(
            (l) =>
                l.habitId == habitId &&
                DateTime(l.date.year, l.date.month, l.date.day) == day,
          )
          .status;
    } catch (_) {
      return '';
    }
  }

  double completionRateForDate(DateTime date) {
    if (habits.isEmpty) return 0;
    final naCount =
        habits.where((h) => statusForHabit(h.id, date) == 'na').length;
    final doneCount =
        habits.where((h) => statusForHabit(h.id, date) == 'done').length;
    final denominator = habits.length - naCount;
    if (denominator <= 0) return 0;
    return doneCount / denominator;
  }

  Map<String, List<Habit>> get habitsByCategory {
    final map = <String, List<Habit>>{};
    for (final h in habits) {
      map.putIfAbsent(h.category, () => []).add(h);
    }
    return map;
  }

  List<CalendarEvent> eventsForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return events.where((e) {
      final start = DateTime(e.startDate.year, e.startDate.month, e.startDate.day);
      return start == day;
    }).toList();
  }

  CalendarState copyWith({
    List<Habit>? habits,
    List<HabitLog>? habitLogs,
    List<CalendarEvent>? events,
    DateTime? selectedDate,
    DateTime? focusedMonth,
    HabitView? habitView,
    CalendarTab? activeTab,
  }) {
    return CalendarState(
      habits: habits ?? this.habits,
      habitLogs: habitLogs ?? this.habitLogs,
      events: events ?? this.events,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      habitView: habitView ?? this.habitView,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}
