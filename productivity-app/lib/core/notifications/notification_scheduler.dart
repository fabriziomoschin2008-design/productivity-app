import '../../data/local/database.dart';
import 'notification_ids.dart';
import 'notification_service.dart';

class NotificationScheduler {
  NotificationScheduler._();
  static final instance = NotificationScheduler._();

  final _svc = NotificationService.instance;

  // Track scheduled goal and event IDs to cancel precisely on re-schedule.
  final _goalIds = <int>{};
  final _eventIds = <int>{};

  // Prevent showing "scaduto" repeatedly within the same session.
  final _shownExpiredGoals = <String>{};

  // --- Public API ---

  Future<void> scheduleHabitReminder(List<Habit> habits) async {
    await _svc.cancel(kHabitReminderId);
    if (habits.isEmpty) return;
    final count = habits.length;
    await _svc.scheduleAt(
      id: kHabitReminderId,
      title: 'Abitudini di oggi',
      body: count == 1
          ? 'Hai 1 abitudine da registrare. Apri Cubby per completarla.'
          : 'Hai $count abitudini da registrare. Apri Cubby per completarle.',
      scheduledDate: _nextDailyAt(20, 0),
    );
  }

  Future<void> scheduleGoalDeadlines(List<Goal> goals) async {
    for (final id in _goalIds) {
      await _svc.cancel(id);
    }
    _goalIds.clear();

    final now = DateTime.now();
    for (final goal in goals) {
      if (goal.isCompleted || goal.deadline == null) continue;
      final dl = goal.deadline!;

      // 3-day warning at 09:00
      final warn3 = DateTime(dl.year, dl.month, dl.day - 3, 9, 0);
      if (warn3.isAfter(now)) {
        final id = goalDeadline3dId(goal.id);
        await _svc.scheduleAt(
          id: id,
          title: 'Scadenza obiettivo',
          body: "'${goal.name}' scade tra 3 giorni.",
          scheduledDate: warn3,
        );
        _goalIds.add(id);
      }

      // 1-day warning at 09:00
      final warn1 = DateTime(dl.year, dl.month, dl.day - 1, 9, 0);
      if (warn1.isAfter(now)) {
        final id = goalDeadline1dId(goal.id);
        await _svc.scheduleAt(
          id: id,
          title: 'Scadenza obiettivo',
          body: "'${goal.name}' scade domani.",
          scheduledDate: warn1,
        );
        _goalIds.add(id);
      }

      // Show once per session if expired in the last 7 days
      final expired = dl.isBefore(now) && now.difference(dl).inDays <= 7;
      if (expired && !_shownExpiredGoals.contains(goal.id)) {
        _shownExpiredGoals.add(goal.id);
        await _svc.show(
          id: goalDeadline3dId(goal.id),
          title: 'Obiettivo scaduto',
          body: "'${goal.name}' è scaduto.",
        );
      }
    }
  }

  Future<void> showGoalCompleted(Goal goal) async {
    await _svc.show(
      id: goalCompletedId(goal.id),
      title: 'Obiettivo raggiunto!',
      body: "Hai completato '${goal.name}'. Ottimo lavoro!",
    );
  }

  Future<void> scheduleCalendarEvents(List<CalendarEvent> events) async {
    for (final id in _eventIds) {
      await _svc.cancel(id);
    }
    _eventIds.clear();

    final now = DateTime.now();
    final cutoff = now.add(const Duration(days: 7));

    for (final ev in events) {
      if (ev.allDay) continue;
      final reminderTime = ev.startDate.subtract(const Duration(minutes: 30));
      if (reminderTime.isBefore(now) || ev.startDate.isAfter(cutoff)) continue;

      final id = calendarEventId(ev.id);
      await _svc.scheduleAt(
        id: id,
        title: ev.title,
        body: 'Inizia tra 30 minuti.',
        scheduledDate: reminderTime,
      );
      _eventIds.add(id);
    }
  }

  Future<void> scheduleTodoMorningReminder(List<TodoItem> items) async {
    await _svc.cancel(kTodoMorningId);
    final now = DateTime.now();
    final endOfTomorrow =
        DateTime(now.year, now.month, now.day + 1, 23, 59, 59);
    final pending = items
        .where(
          (t) =>
              !t.isDone &&
              t.dueDate != null &&
              !t.dueDate!.isAfter(endOfTomorrow),
        )
        .length;
    if (pending == 0) return;
    await _svc.scheduleAt(
      id: kTodoMorningId,
      title: 'Task di oggi',
      body: pending == 1
          ? 'Hai 1 task in scadenza entro domani.'
          : 'Hai $pending task in scadenza entro domani.',
      scheduledDate: _nextDailyAt(8, 0),
    );
  }

  // --- Helpers ---

  DateTime _nextDailyAt(int hour, int minute) {
    final now = DateTime.now();
    var t = DateTime(now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now)) t = t.add(const Duration(days: 1));
    return t;
  }
}
