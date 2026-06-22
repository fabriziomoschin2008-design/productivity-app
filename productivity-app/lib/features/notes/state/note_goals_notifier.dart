import 'dart:async';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/error_handler.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/local/database.dart';
import 'note_goals_state.dart';

const _uuid = Uuid();

class NoteGoalsNotifier extends StateNotifier<NoteGoalsState> {
  final AppDatabase _db;
  StreamSubscription<List<NoteGoal>>? _goalsSub;

  NoteGoalsNotifier(this._db) : super(const NoteGoalsState()) {
    _goalsSub = _db.watchNoteGoals().listen((goals) {
      state = state.copyWith(goals: goals);
    });
  }

  @override
  void dispose() {
    _goalsSub?.cancel();
    super.dispose();
  }

  void selectGoal(String? id) => state = state.copyWith(selectedGoalId: id);

  Future<void> createGoal() async {
    try {
      final id = _uuid.v4();
      await _db.insertNoteGoal(NoteGoalsCompanion(id: Value(id)));
      state = state.copyWith(selectedGoalId: id);
      AppLogger.instance.info('Obiettivo creato: $id');
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> updateGoal({
    required String id,
    required String title,
    required String? description,
    required DateTime? deadline,
    required String content,
  }) async {
    try {
      await _db.updateNoteGoal(NoteGoalsCompanion(
        id: Value(id),
        title: Value(title),
        description: Value(description),
        deadline: Value(deadline),
        content: Value(content),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (e, s) {
      AppErrorHandler.handle(e, s, showUi: false);
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      if (state.selectedGoalId == id) {
        state = state.copyWith(selectedGoalId: null);
      }
      final appData = Platform.environment['LOCALAPPDATA'] ?? '';
      final attachDir =
          Directory('$appData\\ProductivityApp\\attachments\\$id');
      if (attachDir.existsSync()) attachDir.deleteSync(recursive: true);
      await _db.deleteNoteGoalById(id);
      AppLogger.instance.info('Obiettivo eliminato: $id');
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }
}
