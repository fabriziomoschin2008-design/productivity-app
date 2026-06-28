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
  StreamSubscription<AuthState>? _authSub;
  Timer? _pollTimer;
  bool _isSyncing = false;

  SyncWorker(this._db, this._repo, this._client);

  void start() {
    _sub ??= _repo.watchPending().listen((entries) {
      if (entries.isNotEmpty) {
        unawaited(syncPending());
      }
    });
    _authSub ??= _client.auth.onAuthStateChange.listen((_) {
      unawaited(syncPending());
    });
    _pollTimer ??= Timer.periodic(const Duration(seconds: 45), (_) {
      unawaited(syncPending());
    });
    unawaited(syncPending());
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    await _authSub?.cancel();
    _authSub = null;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;
    final session = _client.auth.currentSession;
    if (session == null) {
      AppLogger.instance.info(
        'Sync sospeso: nessuna sessione autenticata Supabase disponibile',
      );
      return;
    }
    _isSyncing = true;
    try {
      await _db.assignUserIdToUnownedRows(session.user.id);
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
      await _pullRemoteChanges(session.user.id);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pullRemoteChanges(String userId) async {
    try {
      final accountsRows = await _fetchRows('accounts', userId);
      final transactionRows = await _fetchRows('transaction_entries', userId);
      final goalsRows = await _fetchRows('goals', userId);
      final todoListRows = await _fetchRows('todo_lists', userId);
      final todoItemRows = await _fetchRows('todo_items', userId);
      final noteFolderRows = await _fetchRows('note_folders', userId);
      final noteRows = await _fetchRows('notes', userId);
      final habitRows = await _fetchRows('habits', userId);
      final habitLogRows = await _fetchRows('habit_logs', userId);
      final calendarEventRows = await _fetchRows('calendar_events', userId);
      final noteGoalRows = await _fetchRows('note_goals', userId);
      final trackerRows = await _fetchRows('trackers', userId);
      final movieRows = await _fetchRows('movies', userId);
      final tvSeriesRows = await _fetchRows('tv_series', userId);
      final gameRows = await _fetchRows('games', userId);

      await _db.applyRemoteSnapshot(
        accountsRows: accountsRows.map(_accountFromMap).toList(),
        transactionRows: transactionRows.map(_transactionFromMap).toList(),
        goalsRows: goalsRows.map(_goalFromMap).toList(),
        todoListRows: todoListRows.map(_todoListFromMap).toList(),
        todoItemRows: todoItemRows.map(_todoItemFromMap).toList(),
        noteFolderRows: noteFolderRows.map(_noteFolderFromMap).toList(),
        noteRows: noteRows.map(_noteFromMap).toList(),
        habitRows: habitRows.map(_habitFromMap).toList(),
        habitLogRows: habitLogRows.map(_habitLogFromMap).toList(),
        calendarEventRows:
            calendarEventRows.map(_calendarEventFromMap).toList(),
        noteGoalRows: noteGoalRows.map(_noteGoalFromMap).toList(),
        trackerRows: trackerRows.map(_trackerFromMap).toList(),
        movieRows: movieRows.map(_movieFromMap).toList(),
        tvSeriesRows: tvSeriesRows.map(_tvSeriesFromMap).toList(),
        gameRows: gameRows.map(_gameFromMap).toList(),
      );
    } catch (e) {
      AppLogger.instance.warning('Pull sync fallito: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRows(
    String table,
    String userId,
  ) async {
    final response =
        await _client.from(table).select().eq('user_id', userId).order(
              'updated_at',
              ascending: true,
            );
    return List<Map<String, dynamic>>.from(response);
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
        'user_id': row.userId ?? _client.auth.currentUser?.id,
        'name': row.name,
        'color_value': row.colorValue,
        'opening_balance': row.openingBalance,
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _transactionToMap(TransactionEntry row) => {
        'id': row.id,
        'user_id': row.userId ?? _client.auth.currentUser?.id,
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
        'user_id': row.userId ?? _client.auth.currentUser?.id,
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
        'user_id': row.userId ?? _client.auth.currentUser?.id,
        'name': row.name,
        'color_value': row.colorValue,
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _todoItemToMap(TodoItem row) => {
        'id': row.id,
        'user_id': row.userId ?? _client.auth.currentUser?.id,
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
        'user_id': row.userId ?? _client.auth.currentUser?.id,
        'name': row.name,
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _noteToMap(Note row) => {
        'id': row.id,
        'user_id': row.userId ?? _client.auth.currentUser?.id,
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
        'user_id': row.userId ?? _client.auth.currentUser?.id,
        'name': row.name,
        'category': row.category,
        'sort_order': row.sortOrder,
        'created_at': _ts(row.createdAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _habitLogToMap(HabitLog row) => {
        'habit_id': row.habitId,
        'user_id': row.userId ?? _client.auth.currentUser?.id,
        'date': _ts(row.date),
        'status': row.status,
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Map<String, dynamic> _calendarEventToMap(CalendarEvent row) => {
        'id': row.id,
        'user_id': row.userId ?? _client.auth.currentUser?.id,
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
        'user_id': row.userId ?? _client.auth.currentUser?.id,
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
        'user_id': row.userId ?? _client.auth.currentUser?.id,
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
        'user_id': row.userId ?? _client.auth.currentUser?.id,
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
        'user_id': row.userId ?? _client.auth.currentUser?.id,
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
        'user_id': row.userId ?? _client.auth.currentUser?.id,
        'title': row.title,
        'platform': row.platform,
        'status': row.status,
        'objectives': row.objectives,
        'user_rating': row.userRating,
        'added_at': _ts(row.addedAt),
        'updated_at': _ts(row.updatedAt),
        'deleted_at': _ts(row.deletedAt),
      };

  Account _accountFromMap(Map<String, dynamic> row) => Account(
        id: _string(row['id']),
        userId: _nullableString(row['user_id']),
        name: _string(row['name']),
        colorValue: _int(row['color_value']),
        openingBalance: _double(row['opening_balance']),
        createdAt: _date(row['created_at']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  TransactionEntry _transactionFromMap(Map<String, dynamic> row) =>
      TransactionEntry(
        id: _string(row['id']),
        userId: _nullableString(row['user_id']),
        accountId: _string(row['account_id']),
        amount: _double(row['amount']),
        type: _string(row['type']),
        category: _string(row['category']),
        date: _date(row['date']),
        note: _nullableString(row['note']),
        createdAt: _date(row['created_at']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  Goal _goalFromMap(Map<String, dynamic> row) => Goal(
        id: _string(row['id']),
        userId: _nullableString(row['user_id']),
        name: _string(row['name']),
        targetAmount: _double(row['target_amount']),
        currentAmount: _double(row['current_amount']),
        deadline: _nullableDate(row['deadline']),
        note: _nullableString(row['note']),
        isCompleted: _bool(row['is_completed']),
        createdAt: _date(row['created_at']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  TodoList _todoListFromMap(Map<String, dynamic> row) => TodoList(
        id: _string(row['id']),
        userId: _nullableString(row['user_id']),
        name: _string(row['name']),
        colorValue: _int(row['color_value']),
        createdAt: _date(row['created_at']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  TodoItem _todoItemFromMap(Map<String, dynamic> row) => TodoItem(
        id: _string(row['id']),
        userId: _nullableString(row['user_id']),
        listId: _nullableString(row['list_id']),
        title: _string(row['title']),
        note: _nullableString(row['note']),
        isDone: _bool(row['is_done']),
        priority: _int(row['priority']),
        dueDate: _nullableDate(row['due_date']),
        hasDueTime: _bool(row['has_due_time']),
        completedAt: _nullableDate(row['completed_at']),
        createdAt: _date(row['created_at']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  NoteFolder _noteFolderFromMap(Map<String, dynamic> row) => NoteFolder(
        id: _string(row['id']),
        userId: _nullableString(row['user_id']),
        name: _string(row['name']),
        createdAt: _date(row['created_at']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  Note _noteFromMap(Map<String, dynamic> row) => Note(
        id: _string(row['id']),
        userId: _nullableString(row['user_id']),
        title: _string(row['title']),
        content: _string(row['content']),
        folderId: _nullableString(row['folder_id']),
        isPinned: _bool(row['is_pinned']),
        createdAt: _date(row['created_at']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  Habit _habitFromMap(Map<String, dynamic> row) => Habit(
        id: _string(row['id']),
        userId: _nullableString(row['user_id']),
        name: _string(row['name']),
        category: _string(row['category']),
        sortOrder: _int(row['sort_order']),
        createdAt: _date(row['created_at']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  HabitLog _habitLogFromMap(Map<String, dynamic> row) => HabitLog(
        habitId: _string(row['habit_id']),
        userId: _nullableString(row['user_id']),
        date: _date(row['date']),
        status: _string(row['status']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  CalendarEvent _calendarEventFromMap(Map<String, dynamic> row) =>
      CalendarEvent(
        id: _string(row['id']),
        userId: _nullableString(row['user_id']),
        title: _string(row['title']),
        note: _nullableString(row['note']),
        startDate: _date(row['start_date']),
        endDate: _nullableDate(row['end_date']),
        allDay: _bool(row['all_day']),
        colorValue: _int(row['color_value']),
        createdAt: _date(row['created_at']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  NoteGoal _noteGoalFromMap(Map<String, dynamic> row) => NoteGoal(
        id: _string(row['id']),
        userId: _nullableString(row['user_id']),
        title: _string(row['title']),
        description: _nullableString(row['description']),
        deadline: _nullableDate(row['deadline']),
        content: _string(row['content']),
        createdAt: _date(row['created_at']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  Tracker _trackerFromMap(Map<String, dynamic> row) => Tracker(
        id: _string(row['id']),
        userId: _nullableString(row['user_id']),
        name: _string(row['name']),
        currentValue: _double(row['current_value']),
        targetValue: _double(row['target_value']),
        step: _double(row['step']),
        unit: _nullableString(row['unit']),
        completedCycles: _int(row['completed_cycles']),
        colorValue: _int(row['color_value']),
        sortOrder: _int(row['sort_order']),
        isDailyAutoIncrement: _bool(row['daily_auto_increment']),
        createdAt: _date(row['created_at']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  Movy _movieFromMap(Map<String, dynamic> row) => Movy(
        id: _string(row['id']),
        userId: _nullableString(row['user_id']),
        tmdbId: _nullableInt(row['tmdb_id']),
        title: _string(row['title']),
        overview: _nullableString(row['overview']),
        posterPath: _nullableString(row['poster_path']),
        releaseDate: _nullableString(row['release_date']),
        runtime: _nullableInt(row['runtime']),
        voteAverage: _nullableDouble(row['vote_average']),
        genreNames: _nullableString(row['genre_names']),
        status: _string(row['status']),
        userRating: _nullableInt(row['user_rating']),
        inOriginalLanguage: _bool(row['in_original_language']),
        addedAt: _date(row['added_at']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  TvSery _tvSeriesFromMap(Map<String, dynamic> row) => TvSery(
        id: _string(row['id']),
        userId: _nullableString(row['user_id']),
        tmdbId: _nullableInt(row['tmdb_id']),
        title: _string(row['title']),
        overview: _nullableString(row['overview']),
        posterPath: _nullableString(row['poster_path']),
        firstAirDate: _nullableString(row['first_air_date']),
        totalSeasons: _nullableInt(row['total_seasons']),
        voteAverage: _nullableDouble(row['vote_average']),
        genreNames: _nullableString(row['genre_names']),
        status: _string(row['status']),
        userRating: _nullableInt(row['user_rating']),
        watchedSeasons: _string(row['watched_seasons']),
        inOriginalLanguage: _bool(row['in_original_language']),
        addedAt: _date(row['added_at']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  Game _gameFromMap(Map<String, dynamic> row) => Game(
        id: _string(row['id']),
        userId: _nullableString(row['user_id']),
        title: _string(row['title']),
        platform: _nullableString(row['platform']),
        status: _string(row['status']),
        objectives: _string(row['objectives']),
        userRating: _nullableInt(row['user_rating']),
        addedAt: _date(row['added_at']),
        updatedAt: _date(row['updated_at']),
        deletedAt: _nullableDate(row['deleted_at']),
      );

  String? _ts(DateTime? value) => value?.toIso8601String();

  String _string(dynamic value) => value as String;
  String? _nullableString(dynamic value) => value as String?;
  int _int(dynamic value) => (value as num).toInt();
  int? _nullableInt(dynamic value) => value == null ? null : (value as num).toInt();
  double _double(dynamic value) => (value as num).toDouble();
  double? _nullableDouble(dynamic value) =>
      value == null ? null : (value as num).toDouble();
  bool _bool(dynamic value) => value as bool;
  DateTime _date(dynamic value) => DateTime.parse(value as String).toLocal();
  DateTime? _nullableDate(dynamic value) =>
      value == null ? null : DateTime.parse(value as String).toLocal();
}
