import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/data/local/database.dart';
import 'package:productivity_app/features/calendar/state/calendar_state.dart';

void main() {
  test('eventsForDate includes events spanning multiple days', () {
    final now = DateTime(2026, 6, 29, 12);
    final event = CalendarEvent(
      id: 'event-1',
      title: 'Viaggio',
      startDate: DateTime(2026, 6, 28, 9),
      endDate: DateTime(2026, 6, 30, 18),
      allDay: true,
      colorValue: 0xFFFFFFFF,
      createdAt: now,
      updatedAt: now,
    );

    final state = CalendarState(
      habits: const [],
      habitLogs: const [],
      events: [event],
      selectedDate: DateTime(2026, 6, 29),
      focusedMonth: DateTime(2026, 6),
      habitView: HabitView.daily,
      activeTab: CalendarTab.events,
    );

    expect(state.eventsForDate(DateTime(2026, 6, 28)), [event]);
    expect(state.eventsForDate(DateTime(2026, 6, 29)), [event]);
    expect(state.eventsForDate(DateTime(2026, 6, 30)), [event]);
    expect(state.eventsForDate(DateTime(2026, 7, 1)), isEmpty);
  });
}
