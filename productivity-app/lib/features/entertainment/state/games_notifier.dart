import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/error_handler.dart';
import '../../../data/local/database.dart';
import 'games_state.dart';

class GamesNotifier extends StateNotifier<GamesState> {
  final AppDatabase _db;
  StreamSubscription<List<Game>>? _sub;

  GamesNotifier(this._db) : super(const GamesState()) {
    _sub = _db.watchGames().listen((list) {
      state = state.copyWith(games: list);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void setFilter(String f) => state = state.copyWith(filter: f);
  void setSearch(String q) => state = state.copyWith(search: q);

  Future<void> addGame(
    String title, {
    String? platform,
    List<GameObjective> objectives = const [],
    String? status,
  }) async {
    try {
      final hasPending = objectives.any((o) => !o.done);
      final computedStatus = status ?? (hasPending ? 'playing' : 'completed');
      await _db.insertGame(GamesCompanion(
        title: Value(title),
        platform: Value(platform),
        status: Value(computedStatus),
        objectives: Value(encodeObjectives(objectives)),
      ));
      AppLogger.instance.info('Gioco aggiunto: $title');
    } catch (e, st) {
      AppErrorHandler.handle(e, st);
    }
  }

  Future<void> toggleObjective(String gameId, int index) async {
    try {
      final game = state.games.firstWhere((g) => g.id == gameId);
      final objectives = decodeObjectives(game.objectives);
      if (index < 0 || index >= objectives.length) return;

      final updated = List<GameObjective>.from(objectives);
      updated[index] = GameObjective(desc: updated[index].desc, done: !updated[index].done);

      final allDone = updated.isNotEmpty && updated.every((o) => o.done);
      String? autoStatus;
      if (allDone) {
        autoStatus = 'completed';
      } else if (game.status == 'completed') {
        autoStatus = 'playing';
      }

      await _db.updateGame(GamesCompanion(
        id: Value(gameId),
        objectives: Value(encodeObjectives(updated)),
        status: autoStatus != null ? Value(autoStatus) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (e, st) {
      AppErrorHandler.handle(e, st, showUi: false);
    }
  }

  Future<void> updateObjectives(
      String id, List<GameObjective> objectives) async {
    try {
      final game = state.games.firstWhere((g) => g.id == id);
      final allDone =
          objectives.isNotEmpty && objectives.every((o) => o.done);
      String? autoStatus;
      if (allDone) {
        autoStatus = 'completed';
      } else if (game.status == 'completed' &&
          objectives.any((o) => !o.done)) {
        autoStatus = 'playing';
      }
      await _db.updateGame(GamesCompanion(
        id: Value(id),
        objectives: Value(encodeObjectives(objectives)),
        status:
            autoStatus != null ? Value(autoStatus) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (e, st) {
      AppErrorHandler.handle(e, st, showUi: false);
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _db.updateGame(
        GamesCompanion(
          id: Value(id),
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e, st) {
      AppErrorHandler.handle(e, st, showUi: false);
    }
  }

  Future<void> updateRating(String id, int? rating) async {
    try {
      await _db.updateGame(
        GamesCompanion(
          id: Value(id),
          userRating: Value(rating),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e, st) {
      AppErrorHandler.handle(e, st, showUi: false);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _db.deleteGameById(id);
      AppLogger.instance.info('Gioco eliminato: $id');
    } catch (e, st) {
      AppErrorHandler.handle(e, st);
    }
  }
}
