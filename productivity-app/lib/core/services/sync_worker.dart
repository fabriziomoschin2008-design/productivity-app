import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local/database.dart';
import 'logger_service.dart';
import 'sync_repository.dart';

class SyncWorker {
  final AppDatabase _db;
  final SyncRepository _repo;
  final SupabaseClient _client;

  StreamSubscription<List<SyncQueueEntry>>? _sub;
  bool _isSyncing = false;

  SyncWorker(this._db, this._repo, this._client);

  void start() {
    _sub ??= _repo.watchPending().listen((entries) {
      if (entries.isNotEmpty) {
        unawaited(syncPending());
      }
    });
    unawaited(syncPending());
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final entries = await _repo.getPending();
      for (final entry in entries) {
        try {
          await _syncEntry(entry);
          await _repo.markCompleted(entry.id);
        } catch (e) {
          AppLogger.instance.warning(
            'Sync fallito per ${entry.entityType}/${entry.entityId}: $e',
          );
          await _repo.markFailed(entry.id, entry.retryCount, e.toString());
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncEntry(SyncQueueEntry entry) async {
    final payload = await _payloadFor(entry);
    if (payload == null) return;

    switch (entry.entityType) {
      case 'habit_logs':
        await _client.from('habit_logs').upsert(
              payload,
              onConflict: 'habit_id,date',
            );
        return;
      case 'tv_series':
        await _client.from('tv_series').upsert(payload, onConflict: 'id');
        return;
      default:
        await _client.from(entry.entityType).upsert(payload, onConflict: 'id');
    }
  }

  Future<Map<String, dynamic>?> _payloadFor(SyncQueueEntry entry) async {
    switch (entry.entityType) {
      case 'accounts':
        final row = await _db.getAccountByIdIncludingDeleted(entry.entityId);
        return row == null ? null : _accountToMap(row);
      case 'transaction_entries':
        final row =
            await _db.getTransactionByIdIncludingDeleted(entry.entityId);
        return row == null ? null : _transactionToMap(row);
      case 'goals':
        final row = await _db.getGoalByIdIncludingDeleted(entry.entityId);
        return row == null ? null : _goalToMap(row);
      case 'todo_lists':
        final row = await _db.getTodoListByIdIncludingDeleted(entry.entityId);
        return row == null ? null : _todoListToMap(row);
      case 'todo_items':
        final row = await _db.getTodoItemByIdIncludingDeleted(entry.entityId);
        return row == null ? null : _todoItemToMap(row);
      case 'note_folders':
        final row =
            await _db.getNoteFolderByIdIncludingDeleted(entry.entityId);
        return row == null ? null : _noteFolderToMap(row);
      case 'notes':
        final row = await _db.getNoteByIdIncludingDeleted(entry.entityId);
        return row == null ? null : _noteToMap(row);
      case 'habits':
        final row = await _db.getHabitByIdIncludingDeleted(entry.entityId);
        return row == null ? null : _habitToMap(row);
      case 'habit_logs':
        final parts = entry.entityId.split('|');
        if (parts.length != 2) return null;
        final row = await _db.getHabitLogIncludingDeleted(
          parts[0],
          DateTime.parse(parts[1]),
        );
        return row == null ? null : _habitLogToMap(row);
      case 'calendar_events':
        final row =
            await _db.getCalendarEventByIdIncludingDeleted(entry.entityId);
        return row == null ? null : _calendarEventToMap(row);
      case 'note_goals':
        final row = await _db.getNoteGoalByIdIncludingDeleted(entry.entityId);
        return row == null ? null : _noteGoalToMap(row);
      case 'trackers':
        final row = await _db.getTrackerByIdIncludingDeleted(entry.entityId);
        return row == null ? null : _trackerToMap(row);
      case 'movies':
        final row = await _db.getMovieByIdIncludingDeleted(entry.entityId);
        return row == null ? null : _movieToMap(row);
      case 'tv_series':
        final row = await _db.getTvSeriesByIdIncludingDeleted(entry.entityId);
        return row == null ? null : _tvSeriesToMap(row);
      case 'games':
        final row = await _db.getGameByIdIncludingDeleted(entry.entityId);
        return row == null ? null : _gameToMap(row);
      default:
        return null;
    }
  }

  Map<String, dynamic> _accountToMap(Account row) => {
        'id': row.id,
        'name': row.name,
        'color_value': row.colorValue,
        'opening_balance': row.openingBalance,
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _transactionToMap(TransactionEntry row) => {
        'id': row.id,
        'account_id': row.accountId,
        'amount': row.amount,
        'type': row.type,
        'category': row.category,
        'date': _ts(row.date),
        'note': row.note,
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _goalToMap(Goal row) => {
        'id': row.id,
        'name': row.name,
        'target_amount': row.targetAmount,
        'current_amount': row.currentAmount,
        'deadline': _ts(row.deadline),
        'note': row.note,
        'is_completed': row.isCompleted,
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _todoListToMap(TodoList row) => {
        'id': row.id,
        'name': row.name,
        'color_value': row.colorValue,
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _todoItemToMap(TodoItem row) => {
        'id': row.id,
        'list_id': row.listId,
        'title': row.title,
        'note': row.note,
        'is_done': row.isDone,
        'priority': row.priority,
        'due_date': _ts(row.dueDate),
        'has_due_time': row.hasDueTime,
        'completed_at': _ts(row.completedAt),
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _noteFolderToMap(NoteFolder row) => {
        'id': row.id,
        'name': row.name,
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _noteToMap(Note row) => {
        'id': row.id,
        'title': row.title,
        'content': row.content,
        'folder_id': row.folderId,
        'is_pinned': row.isPinned,
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _habitToMap(Habit row) => {
        'id': row.id,
        'name': row.name,
        'category': row.category,
        'sort_order': row.sortOrder,
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _habitLogToMap(HabitLog row) => {
        'habit_id': row.habitId,
        'date': _ts(row.date),
        'status': row.status,
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _calendarEventToMap(CalendarEvent row) => {
        'id': row.id,
        'title': row.title,
        'note': row.note,
        'start_date': _ts(row.startDate),
        'end_date': _ts(row.endDate),
        'all_day': row.allDay,
        'color_value': row.colorValue,
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _noteGoalToMap(NoteGoal row) => {
        'id': row.id,
        'title': row.title,
        'description': row.description,
        'deadline': _ts(row.deadline),
        'content': row.content,
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _trackerToMap(Tracker row) => {
        'id': row.id,
        'name': row.name,
        'current_value': row.currentValue,
        'target_value': row.targetValue,
        'step': row.step,
        'unit': row.unit,
        'completed_cycles': row.completedCycles,
        'color_value': row.colorValue,
        'sort_order': row.sortOrder,
        'daily_auto_increment': row.isDailyAutoIncrement,
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _movieToMap(Movy row) => {
        'id': row.id,
        'tmdb_id': row.tmdbId,
        'title': row.title,
        'overview': row.overview,
        'poster_path': row.posterPath,
        'release_date': row.releaseDate,
        'runtime': row.runtime,
        'vote_average': row.voteAverage,
        'genre_names': row.genreNames,
        'status': row.status,
        'user_rating': row.userRating,
        'in_original_language': row.inOriginalLanguage,
        'added_at': _ts(row.addedAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _tvSeriesToMap(TvSery row) => {
        'id': row.id,
        'tmdb_id': row.tmdbId,
        'title': row.title,
        'overview': row.overview,
        'poster_path': row.posterPath,
        'first_air_date': row.firstAirDate,
        'total_seasons': row.totalSeasons,
        'vote_average': row.voteAverage,
        'genre_names': row.genreNames,
        'status': row.status,
        'user_rating': row.userRating,
        'watched_seasons': row.watchedSeasons,
        'in_original_language': row.inOriginalLanguage,
        'added_at': _ts(row.addedAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _gameToMap(Game row) => {
        'id': row.id,
        'title': row.title,
        'platform': row.platform,
        'status': row.status,
        'objectives': row.objectives,
        'user_rating': row.userRating,
        'added_at': _ts(row.addedAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  String? _ts(DateTime? value) => value?.toIso8601String();
}
