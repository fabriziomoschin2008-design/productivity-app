import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../state/finance_notifier.dart';
import '../state/finance_state.dart';
import '../state/goals_notifier.dart';
import '../state/goals_state.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final financeProvider =
    StateNotifierProvider<FinanceNotifier, FinanceState>((ref) {
  final db = ref.watch(databaseProvider);
  return FinanceNotifier(db);
});

final goalsProvider =
    StateNotifierProvider<GoalsNotifier, GoalsState>((ref) {
  final db = ref.watch(databaseProvider);
  return GoalsNotifier(db);
});
