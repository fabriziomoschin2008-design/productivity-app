import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/notifications/notification_scheduler.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/local/database.dart';
import 'goals_state.dart';

class GoalsNotifier extends StateNotifier<GoalsState> {
  final AppDatabase _db;
  StreamSubscription<List<Goal>>? _sub;

  GoalsNotifier(this._db) : super(const GoalsState()) {
    _sub = _db.watchGoals().listen((list) {
      state = state.copyWith(goals: list);
      NotificationScheduler.instance.scheduleGoalDeadlines(list);
    });
  }

  Future<void> addGoal({
    required String name,
    required double targetAmount,
    double currentAmount = 0,
    DateTime? deadline,
    String? note,
  }) async {
    AppLogger.instance.info('Obiettivo aggiunto: $name (target: €$targetAmount)');
    await _db.insertGoal(GoalsCompanion.insert(
      name: name,
      targetAmount: targetAmount,
      currentAmount: Value(currentAmount),
      deadline: Value(deadline),
      note: Value(note),
    ));
  }

  Future<void> updateProgress(String id, double newAmount) async {
    AppLogger.instance.info('Obiettivo aggiornato: id=$id → €$newAmount');
    final goal = state.goals.where((g) => g.id == id).firstOrNull;
    final justCompleted =
        goal != null && newAmount >= goal.targetAmount && !goal.isCompleted;
    await _db.updateGoal(GoalsCompanion(
      id: Value(id),
      currentAmount: Value(newAmount),
    ));
    if (justCompleted) {
      NotificationScheduler.instance.showGoalCompleted(goal);
    }
  }

  Future<void> completeGoal(String id) async {
    AppLogger.instance.info('Obiettivo completato: id=$id');
    await _db.updateGoal(GoalsCompanion(
      id: Value(id),
      isCompleted: const Value(true),
    ));
  }

  Future<void> deleteGoal(String id) async {
    AppLogger.instance.info('Obiettivo eliminato: id=$id');
    await _db.deleteGoalById(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
