import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/finance/providers/finance_providers.dart';
import '../state/todo_notifier.dart';
import '../state/todo_state.dart';

final todoProvider =
    StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  final db = ref.watch(databaseProvider);
  return TodoNotifier(db);
});
