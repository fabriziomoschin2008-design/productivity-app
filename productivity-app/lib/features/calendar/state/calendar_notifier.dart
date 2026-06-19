import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/error_handler.dart';
import '../../../data/local/database.dart';
import 'calendar_state.dart';

const _uuid = Uuid();

class CalendarNotifier extends StateNotifier<CalendarState> {
  final AppDatabase _db;
  StreamSubscription? _habitsSub;
  StreamSubscription? _logsSub;
  StreamSubscription? _eventsSub;

  CalendarNotifier(this._db) : super(CalendarState.initial()) {
    _habitsSub = _db.watchHabits().listen((habits) {
      state = state.copyWith(habits: habits);
    });
    _subscribeToLogs();
    _eventsSub = _db.watchCalendarEvents().listen((events) {
      state = state.copyWith(events: events);
    });
  }

  void _subscribeToLogs() {
    _logsSub?.cancel();
    final month = state.focusedMonth;
    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    _logsSub = _db.watchHabitLogsForRange(from, to).listen((logs) {
      state = state.copyWith(habitLogs: logs);
    });
  }

  void selectDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final newMonth = DateTime(date.year, date.month);
    final monthChanged = newMonth != state.focusedMonth;
    state = state.copyWith(selectedDate: day, focusedMonth: newMonth);
    if (monthChanged) _subscribeToLogs();
  }

  void navigateMonth(int delta) {
    final current = state.focusedMonth;
    final newMonth = DateTime(current.year, current.month + delta);
    state = state.copyWith(focusedMonth: newMonth);
    _subscribeToLogs();
  }

  void setHabitView(HabitView view) => state = state.copyWith(habitView: view);

  void setTab(CalendarTab tab) => state = state.copyWith(activeTab: tab);

  // Cycles: '' → 'done' → 'skip' → 'na' → ''
  Future<void> logHabit(String habitId, DateTime date) async {
    try {
      final day = DateTime(date.year, date.month, date.day);
      final current = state.statusForHabit(habitId, day);
      final next = switch (current) {
        '' => 'done',
        'done' => 'skip',
        'skip' => 'na',
        _ => '',
      };
      if (next.isEmpty) {
        await _db.clearHabitLog(habitId, day);
      } else {
        await _db.setHabitLog(HabitLogsCompanion(
          habitId: Value(habitId),
          date: Value(day),
          status: Value(next),
        ));
      }
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> setHabitStatus(
      String habitId, DateTime date, String status) async {
    try {
      final day = DateTime(date.year, date.month, date.day);
      if (status.isEmpty) {
        await _db.clearHabitLog(habitId, day);
      } else {
        await _db.setHabitLog(HabitLogsCompanion(
          habitId: Value(habitId),
          date: Value(day),
          status: Value(status),
        ));
      }
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> createHabit(String name, String category) async {
    try {
      await _db.insertHabit(HabitsCompanion(
        id: Value(_uuid.v4()),
        name: Value(name),
        category: Value(category),
      ));
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _db.deleteHabitById(id);
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> createEvent({
    required String title,
    String? note,
    required DateTime startDate,
    DateTime? endDate,
    bool allDay = true,
    int colorValue = 0xFF6C63FF,
  }) async {
    try {
      await _db.insertCalendarEvent(CalendarEventsCompanion(
        id: Value(_uuid.v4()),
        title: Value(title),
        note: Value(note),
        startDate: Value(startDate),
        endDate: Value(endDate),
        allDay: Value(allDay),
        colorValue: Value(colorValue),
      ));
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _db.deleteCalendarEventById(id);
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  @override
  void dispose() {
    _habitsSub?.cancel();
    _logsSub?.cancel();
    _eventsSub?.cancel();
    super.dispose();
  }
}
