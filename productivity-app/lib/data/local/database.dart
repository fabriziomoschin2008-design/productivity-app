import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/logger_service.dart';

part 'database.g.dart';

const _uuid = Uuid();

class Accounts extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get name => text()();
  IntColumn get colorValue => integer().named('color_value')();
  RealColumn get openingBalance =>
      real().named('opening_balance').withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TransactionEntries extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get accountId => text().named('account_id')();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'income' | 'expense'
  TextColumn get category => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Goals extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get name => text()();
  RealColumn get targetAmount => real().named('target_amount')();
  RealColumn get currentAmount =>
      real().named('current_amount').withDefault(const Constant(0.0))();
  DateTimeColumn get deadline => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isCompleted =>
      boolean().named('is_completed').withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TodoLists extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get name => text()();
  IntColumn get colorValue => integer().named('color_value')();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TodoItems extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get listId => text().named('list_id').nullable()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDone =>
      boolean().named('is_done').withDefault(const Constant(false))();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  DateTimeColumn get dueDate => dateTime().named('due_date').nullable()();
  // true = l'utente ha scelto un'ora specifica; false = scade a mezzanotte (23:59:59)
  BoolColumn get hasDueTime =>
      boolean().named('has_due_time').withDefault(const Constant(false))();
  DateTimeColumn get completedAt =>
      dateTime().named('completed_at').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Habits extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get name => text()();
  TextColumn get category =>
      text().withDefault(const Constant(''))(); // 'Mattina'|'Pomeriggio'|'Sera'
  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class HabitLogs extends Table {
  TextColumn get habitId => text().named('habit_id')();
  TextColumn get userId => text().named('user_id').nullable()();
  DateTimeColumn get date => dateTime()(); // mezzanotte del giorno
  TextColumn get status => text()(); // 'done' | 'skip' | 'na'
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {habitId, date};
}

class CalendarEvents extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get startDate => dateTime().named('start_date')();
  DateTimeColumn get endDate => dateTime().named('end_date').nullable()();
  BoolColumn get allDay =>
      boolean().named('all_day').withDefault(const Constant(true))();
  IntColumn get colorValue =>
      integer().named('color_value').withDefault(const Constant(0xFF6C63FF))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class NoteFolders extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Notes extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get folderId => text().named('folder_id').nullable()();
  BoolColumn get isPinned =>
      boolean().named('is_pinned').withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class NoteGoals extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get description => text().nullable()();
  DateTimeColumn get deadline => dateTime().nullable()();
  TextColumn get content => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Trackers extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get name => text()();
  RealColumn get currentValue =>
      real().named('current_value').withDefault(const Constant(0.0))();
  RealColumn get targetValue => real().named('target_value')();
  RealColumn get step => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text().nullable()();
  IntColumn get completedCycles =>
      integer().named('completed_cycles').withDefault(const Constant(0))();
  IntColumn get colorValue =>
      integer().named('color_value').withDefault(const Constant(0xFFFF6B45))();
  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant(0))();
  BoolColumn get isDailyAutoIncrement => boolean()
      .named('daily_auto_increment')
      .withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Movies extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get userId => text().named('user_id').nullable()();
  IntColumn get tmdbId => integer().named('tmdb_id').nullable()();
  TextColumn get title => text()();
  TextColumn get overview => text().nullable()();
  TextColumn get posterPath => text().named('poster_path').nullable()();
  TextColumn get releaseDate => text().named('release_date').nullable()();
  IntColumn get runtime => integer().nullable()();
  RealColumn get voteAverage => real().named('vote_average').nullable()();
  TextColumn get genreNames => text().named('genre_names').nullable()();
  TextColumn get status => text().withDefault(const Constant('watched'))();
  IntColumn get userRating => integer().named('user_rating').nullable()();
  BoolColumn get inOriginalLanguage => boolean()
      .named('in_original_language')
      .withDefault(const Constant(false))();
  DateTimeColumn get addedAt =>
      dateTime().named('added_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TvSeries extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get userId => text().named('user_id').nullable()();
  IntColumn get tmdbId => integer().named('tmdb_id').nullable()();
  TextColumn get title => text()();
  TextColumn get overview => text().nullable()();
  TextColumn get posterPath => text().named('poster_path').nullable()();
  TextColumn get firstAirDate => text().named('first_air_date').nullable()();
  IntColumn get totalSeasons => integer().named('total_seasons').nullable()();
  RealColumn get voteAverage => real().named('vote_average').nullable()();
  TextColumn get genreNames => text().named('genre_names').nullable()();
  TextColumn get status => text().withDefault(const Constant('watching'))();
  IntColumn get userRating => integer().named('user_rating').nullable()();
  // JSON array of ints: [1, 2, 3]
  TextColumn get watchedSeasons =>
      text().named('watched_seasons').withDefault(const Constant('[]'))();
  BoolColumn get inOriginalLanguage => boolean()
      .named('in_original_language')
      .withDefault(const Constant(false))();
  DateTimeColumn get addedAt =>
      dateTime().named('added_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Games extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get title => text()();
  TextColumn get platform => text().nullable()();
  TextColumn get status => text().withDefault(
    const Constant('playing'),
  )(); // playing | completed | want_to_play
  TextColumn get objectives =>
      text().withDefault(const Constant('[]'))(); // JSON [{desc, done}]
  IntColumn get userRating => integer().named('user_rating').nullable()();
  DateTimeColumn get addedAt =>
      dateTime().named('added_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueueEntries extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();
  TextColumn get operation => text()(); // 'upsert' | 'delete'
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get lastAttemptAt =>
      dateTime().named('last_attempt_at').nullable()();
  IntColumn get retryCount =>
      integer().named('retry_count').withDefault(const Constant(0))();
  TextColumn get lastError => text().named('last_error').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Accounts,
    TransactionEntries,
    Goals,
    TodoLists,
    TodoItems,
    NoteFolders,
    Notes,
    Habits,
    HabitLogs,
    CalendarEvents,
    NoteGoals,
    Trackers,
    Movies,
    TvSeries,
    Games,
    SyncQueueEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(goals);
      if (from < 3) {
        await m.createTable(todoLists);
        await m.createTable(todoItems);
      }
      if (from < 4) await m.addColumn(todoItems, todoItems.hasDueTime);
      if (from < 5) {
        await m.createTable(noteFolders);
        await m.createTable(notes);
      }
      if (from < 6) {
        await m.createTable(habits);
        await m.createTable(habitLogs);
        await m.createTable(calendarEvents);
      }
      if (from < 7) await m.createTable(noteGoals);
      if (from < 8) await m.createTable(trackers);
      if (from < 9) {
        await m.addColumn(trackers, trackers.isDailyAutoIncrement);
      }
      if (from < 10) {
        await m.createTable(movies);
        await m.createTable(tvSeries);
      }
      if (from < 11) await m.createTable(games);
      if (from < 12) {
        await customStatement(
          'ALTER TABLE accounts ADD COLUMN updated_at INTEGER',
        );
        await m.addColumn(accounts, accounts.deletedAt);
        await customStatement(
          'UPDATE accounts SET updated_at = created_at WHERE updated_at IS NULL',
        );
        await customStatement(
          'ALTER TABLE transaction_entries ADD COLUMN updated_at INTEGER',
        );
        await m.addColumn(transactionEntries, transactionEntries.deletedAt);
        await customStatement(
          'UPDATE transaction_entries SET updated_at = created_at WHERE updated_at IS NULL',
        );
        await customStatement(
          'ALTER TABLE goals ADD COLUMN updated_at INTEGER',
        );
        await m.addColumn(goals, goals.deletedAt);
        await customStatement(
          'UPDATE goals SET updated_at = created_at WHERE updated_at IS NULL',
        );
        await customStatement(
          'ALTER TABLE todo_lists ADD COLUMN updated_at INTEGER',
        );
        await m.addColumn(todoLists, todoLists.deletedAt);
        await customStatement(
          'UPDATE todo_lists SET updated_at = created_at WHERE updated_at IS NULL',
        );
        await customStatement(
          'ALTER TABLE todo_items ADD COLUMN updated_at INTEGER',
        );
        await m.addColumn(todoItems, todoItems.deletedAt);
        await customStatement(
          'UPDATE todo_items SET updated_at = created_at WHERE updated_at IS NULL',
        );
        await customStatement(
          'ALTER TABLE habits ADD COLUMN updated_at INTEGER',
        );
        await m.addColumn(habits, habits.deletedAt);
        await customStatement(
          'UPDATE habits SET updated_at = created_at WHERE updated_at IS NULL',
        );
        await customStatement(
          'ALTER TABLE habit_logs ADD COLUMN updated_at INTEGER',
        );
        await m.addColumn(habitLogs, habitLogs.deletedAt);
        await customStatement(
          "UPDATE habit_logs SET updated_at = CAST(strftime('%s', 'now') AS INTEGER) WHERE updated_at IS NULL",
        );
        await customStatement(
          'ALTER TABLE calendar_events ADD COLUMN updated_at INTEGER',
        );
        await m.addColumn(calendarEvents, calendarEvents.deletedAt);
        await customStatement(
          'UPDATE calendar_events SET updated_at = created_at WHERE updated_at IS NULL',
        );
        await customStatement(
          'ALTER TABLE note_folders ADD COLUMN updated_at INTEGER',
        );
        await m.addColumn(noteFolders, noteFolders.deletedAt);
        await customStatement(
          'UPDATE note_folders SET updated_at = created_at WHERE updated_at IS NULL',
        );
        await m.addColumn(notes, notes.deletedAt);
        await m.addColumn(noteGoals, noteGoals.deletedAt);
        await m.addColumn(trackers, trackers.deletedAt);
        await customStatement(
          'ALTER TABLE movies ADD COLUMN updated_at INTEGER',
        );
        await m.addColumn(movies, movies.deletedAt);
        await customStatement(
          'UPDATE movies SET updated_at = added_at WHERE updated_at IS NULL',
        );
        await customStatement(
          'ALTER TABLE tv_series ADD COLUMN updated_at INTEGER',
        );
        await m.addColumn(tvSeries, tvSeries.deletedAt);
        await customStatement(
          'UPDATE tv_series SET updated_at = added_at WHERE updated_at IS NULL',
        );
        await customStatement(
          'ALTER TABLE games ADD COLUMN updated_at INTEGER',
        );
        await m.addColumn(games, games.deletedAt);
        await customStatement(
          'UPDATE games SET updated_at = added_at WHERE updated_at IS NULL',
        );
      }
      if (from < 13) {
        await m.createTable(syncQueueEntries);
      }
      if (from < 14) {
        await m.addColumn(accounts, accounts.userId);
        await m.addColumn(transactionEntries, transactionEntries.userId);
        await m.addColumn(goals, goals.userId);
        await m.addColumn(todoLists, todoLists.userId);
        await m.addColumn(todoItems, todoItems.userId);
        await m.addColumn(habits, habits.userId);
        await m.addColumn(habitLogs, habitLogs.userId);
        await m.addColumn(calendarEvents, calendarEvents.userId);
        await m.addColumn(noteFolders, noteFolders.userId);
        await m.addColumn(notes, notes.userId);
        await m.addColumn(noteGoals, noteGoals.userId);
        await m.addColumn(trackers, trackers.userId);
        await m.addColumn(movies, movies.userId);
        await m.addColumn(tvSeries, tvSeries.userId);
        await m.addColumn(games, games.userId);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'productivity_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  Future<void> _removeQueuedSyncChange(
    String entityType,
    String entityId,
  ) async {
    await (delete(syncQueueEntries)..where(
          (q) => q.entityType.equals(entityType) & q.entityId.equals(entityId),
        ))
        .go();
  }

  Future<void> _queueSyncChange(
    String entityType,
    String entityId,
    String operation,
  ) async {
    if (!await _shouldQueueSyncChange(entityType, entityId)) {
      await _removeQueuedSyncChange(entityType, entityId);
      return;
    }

    await _removeQueuedSyncChange(entityType, entityId);
    await into(syncQueueEntries).insert(
      SyncQueueEntriesCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        operation: operation,
      ),
    );
  }

  String? _currentUserId() => Supabase.instance.client.auth.currentUser?.id;

  bool _canMutateOwnedRow(String? rowUserId) {
    if (rowUserId == null) return true;
    return rowUserId == _currentUserId();
  }

  Future<bool> _guardOwnedMutation({
    required String entityType,
    required String entityId,
    required String? rowUserId,
  }) async {
    if (_canMutateOwnedRow(rowUserId)) return true;
    AppLogger.instance.warning(
      'Modifica locale bloccata per $entityType/$entityId: record sincronizzato senza sessione compatibile',
    );
    await _removeQueuedSyncChange(entityType, entityId);
    return false;
  }

  Future<bool> _shouldQueueSyncChange(
    String entityType,
    String entityId,
  ) async {
    final currentUserId = _currentUserId();
    if (currentUserId == null) return false;
    final rowUserId = await _entityUserId(entityType, entityId);
    return rowUserId == currentUserId;
  }

  Future<String?> _entityUserId(String entityType, String entityId) async {
    switch (entityType) {
      case 'accounts':
        return (select(accounts)..where((t) => t.id.equals(entityId)))
            .map((t) => t.userId)
            .getSingleOrNull();
      case 'transaction_entries':
        return (select(transactionEntries)..where((t) => t.id.equals(entityId)))
            .map((t) => t.userId)
            .getSingleOrNull();
      case 'goals':
        return (select(goals)..where((t) => t.id.equals(entityId)))
            .map((t) => t.userId)
            .getSingleOrNull();
      case 'todo_lists':
        return (select(todoLists)..where((t) => t.id.equals(entityId)))
            .map((t) => t.userId)
            .getSingleOrNull();
      case 'todo_items':
        return (select(todoItems)..where((t) => t.id.equals(entityId)))
            .map((t) => t.userId)
            .getSingleOrNull();
      case 'note_folders':
        return (select(noteFolders)..where((t) => t.id.equals(entityId)))
            .map((t) => t.userId)
            .getSingleOrNull();
      case 'notes':
        return (select(notes)..where((t) => t.id.equals(entityId)))
            .map((t) => t.userId)
            .getSingleOrNull();
      case 'habits':
        return (select(habits)..where((t) => t.id.equals(entityId)))
            .map((t) => t.userId)
            .getSingleOrNull();
      case 'habit_logs':
        final parts = entityId.split('|');
        if (parts.length != 2) return null;
        final date = DateTime.tryParse(parts[1]);
        if (date == null) return null;
        return (select(habitLogs)
              ..where((t) => t.habitId.equals(parts[0]) & t.date.equals(date)))
            .map((t) => t.userId)
            .getSingleOrNull();
      case 'calendar_events':
        return (select(calendarEvents)..where((t) => t.id.equals(entityId)))
            .map((t) => t.userId)
            .getSingleOrNull();
      case 'note_goals':
        return (select(noteGoals)..where((t) => t.id.equals(entityId)))
            .map((t) => t.userId)
            .getSingleOrNull();
      case 'trackers':
        return (select(trackers)..where((t) => t.id.equals(entityId)))
            .map((t) => t.userId)
            .getSingleOrNull();
      case 'movies':
        return (select(movies)..where((t) => t.id.equals(entityId)))
            .map((t) => t.userId)
            .getSingleOrNull();
      case 'tv_series':
        return (select(tvSeries)..where((t) => t.id.equals(entityId)))
            .map((t) => t.userId)
            .getSingleOrNull();
      case 'games':
        return (select(games)..where((t) => t.id.equals(entityId)))
            .map((t) => t.userId)
            .getSingleOrNull();
      default:
        return null;
    }
  }

  Future<void> assignUserIdToUnownedRows(String userId) async {
    await transaction(() async {
      final now = DateTime.now();

      final accountIds = await (select(
        accounts,
      )..where((t) => t.userId.isNull())).map((t) => t.id).get();
      if (accountIds.isNotEmpty) {
        await (update(accounts)..where((t) => t.userId.isNull())).write(
          AccountsCompanion(userId: Value(userId), updatedAt: Value(now)),
        );
        for (final id in accountIds) {
          await _queueSyncChange('accounts', id, 'upsert');
        }
      }

      final transactionIds = await (select(
        transactionEntries,
      )..where((t) => t.userId.isNull())).map((t) => t.id).get();
      if (transactionIds.isNotEmpty) {
        await (update(
          transactionEntries,
        )..where((t) => t.userId.isNull())).write(
          TransactionEntriesCompanion(
            userId: Value(userId),
            updatedAt: Value(now),
          ),
        );
        for (final id in transactionIds) {
          await _queueSyncChange('transaction_entries', id, 'upsert');
        }
      }

      final goalIds = await (select(
        goals,
      )..where((t) => t.userId.isNull())).map((t) => t.id).get();
      if (goalIds.isNotEmpty) {
        await (update(goals)..where((t) => t.userId.isNull())).write(
          GoalsCompanion(userId: Value(userId), updatedAt: Value(now)),
        );
        for (final id in goalIds) {
          await _queueSyncChange('goals', id, 'upsert');
        }
      }

      final todoListIds = await (select(
        todoLists,
      )..where((t) => t.userId.isNull())).map((t) => t.id).get();
      if (todoListIds.isNotEmpty) {
        await (update(todoLists)..where((t) => t.userId.isNull())).write(
          TodoListsCompanion(userId: Value(userId), updatedAt: Value(now)),
        );
        for (final id in todoListIds) {
          await _queueSyncChange('todo_lists', id, 'upsert');
        }
      }

      final todoItemIds = await (select(
        todoItems,
      )..where((t) => t.userId.isNull())).map((t) => t.id).get();
      if (todoItemIds.isNotEmpty) {
        await (update(todoItems)..where((t) => t.userId.isNull())).write(
          TodoItemsCompanion(userId: Value(userId), updatedAt: Value(now)),
        );
        for (final id in todoItemIds) {
          await _queueSyncChange('todo_items', id, 'upsert');
        }
      }

      final habitIds = await (select(
        habits,
      )..where((t) => t.userId.isNull())).map((t) => t.id).get();
      if (habitIds.isNotEmpty) {
        await (update(habits)..where((t) => t.userId.isNull())).write(
          HabitsCompanion(userId: Value(userId), updatedAt: Value(now)),
        );
        for (final id in habitIds) {
          await _queueSyncChange('habits', id, 'upsert');
        }
      }

      final habitLogRows = await (select(
        habitLogs,
      )..where((t) => t.userId.isNull())).get();
      if (habitLogRows.isNotEmpty) {
        await (update(habitLogs)..where((t) => t.userId.isNull())).write(
          HabitLogsCompanion(userId: Value(userId), updatedAt: Value(now)),
        );
        for (final row in habitLogRows) {
          await _queueSyncChange(
            'habit_logs',
            '${row.habitId}|${row.date.toIso8601String()}',
            'upsert',
          );
        }
      }

      final calendarEventIds = await (select(
        calendarEvents,
      )..where((t) => t.userId.isNull())).map((t) => t.id).get();
      if (calendarEventIds.isNotEmpty) {
        await (update(calendarEvents)..where((t) => t.userId.isNull())).write(
          CalendarEventsCompanion(userId: Value(userId), updatedAt: Value(now)),
        );
        for (final id in calendarEventIds) {
          await _queueSyncChange('calendar_events', id, 'upsert');
        }
      }

      final noteFolderIds = await (select(
        noteFolders,
      )..where((t) => t.userId.isNull())).map((t) => t.id).get();
      if (noteFolderIds.isNotEmpty) {
        await (update(noteFolders)..where((t) => t.userId.isNull())).write(
          NoteFoldersCompanion(userId: Value(userId), updatedAt: Value(now)),
        );
        for (final id in noteFolderIds) {
          await _queueSyncChange('note_folders', id, 'upsert');
        }
      }

      final noteIds = await (select(
        notes,
      )..where((t) => t.userId.isNull())).map((t) => t.id).get();
      if (noteIds.isNotEmpty) {
        await (update(notes)..where((t) => t.userId.isNull())).write(
          NotesCompanion(userId: Value(userId), updatedAt: Value(now)),
        );
        for (final id in noteIds) {
          await _queueSyncChange('notes', id, 'upsert');
        }
      }

      final noteGoalIds = await (select(
        noteGoals,
      )..where((t) => t.userId.isNull())).map((t) => t.id).get();
      if (noteGoalIds.isNotEmpty) {
        await (update(noteGoals)..where((t) => t.userId.isNull())).write(
          NoteGoalsCompanion(userId: Value(userId), updatedAt: Value(now)),
        );
        for (final id in noteGoalIds) {
          await _queueSyncChange('note_goals', id, 'upsert');
        }
      }

      final trackerIds = await (select(
        trackers,
      )..where((t) => t.userId.isNull())).map((t) => t.id).get();
      if (trackerIds.isNotEmpty) {
        await (update(trackers)..where((t) => t.userId.isNull())).write(
          TrackersCompanion(userId: Value(userId), updatedAt: Value(now)),
        );
        for (final id in trackerIds) {
          await _queueSyncChange('trackers', id, 'upsert');
        }
      }

      final movieIds = await (select(
        movies,
      )..where((t) => t.userId.isNull())).map((t) => t.id).get();
      if (movieIds.isNotEmpty) {
        await (update(movies)..where((t) => t.userId.isNull())).write(
          MoviesCompanion(userId: Value(userId), updatedAt: Value(now)),
        );
        for (final id in movieIds) {
          await _queueSyncChange('movies', id, 'upsert');
        }
      }

      final tvSeriesIds = await (select(
        tvSeries,
      )..where((t) => t.userId.isNull())).map((t) => t.id).get();
      if (tvSeriesIds.isNotEmpty) {
        await (update(tvSeries)..where((t) => t.userId.isNull())).write(
          TvSeriesCompanion(userId: Value(userId), updatedAt: Value(now)),
        );
        for (final id in tvSeriesIds) {
          await _queueSyncChange('tv_series', id, 'upsert');
        }
      }

      final gameIds = await (select(
        games,
      )..where((t) => t.userId.isNull())).map((t) => t.id).get();
      if (gameIds.isNotEmpty) {
        await (update(games)..where((t) => t.userId.isNull())).write(
          GamesCompanion(userId: Value(userId), updatedAt: Value(now)),
        );
        for (final id in gameIds) {
          await _queueSyncChange('games', id, 'upsert');
        }
      }
    });
  }

  Future<Account?> getAccountByIdIncludingDeleted(String id) =>
      (select(accounts)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<TransactionEntry?> getTransactionByIdIncludingDeleted(String id) =>
      (select(
        transactionEntries,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Goal?> getGoalByIdIncludingDeleted(String id) =>
      (select(goals)..where((g) => g.id.equals(id))).getSingleOrNull();

  Future<TodoList?> getTodoListByIdIncludingDeleted(String id) =>
      (select(todoLists)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<TodoItem?> getTodoItemByIdIncludingDeleted(String id) =>
      (select(todoItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<NoteFolder?> getNoteFolderByIdIncludingDeleted(String id) =>
      (select(noteFolders)..where((f) => f.id.equals(id))).getSingleOrNull();

  Future<Note?> getNoteByIdIncludingDeleted(String id) =>
      (select(notes)..where((n) => n.id.equals(id))).getSingleOrNull();

  Future<Habit?> getHabitByIdIncludingDeleted(String id) =>
      (select(habits)..where((h) => h.id.equals(id))).getSingleOrNull();

  Future<HabitLog?> getHabitLogIncludingDeleted(
    String habitId,
    DateTime date,
  ) =>
      (select(habitLogs)
            ..where((l) => l.habitId.equals(habitId) & l.date.equals(date)))
          .getSingleOrNull();

  Future<CalendarEvent?> getCalendarEventByIdIncludingDeleted(String id) =>
      (select(calendarEvents)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<NoteGoal?> getNoteGoalByIdIncludingDeleted(String id) =>
      (select(noteGoals)..where((g) => g.id.equals(id))).getSingleOrNull();

  Future<Tracker?> getTrackerByIdIncludingDeleted(String id) =>
      (select(trackers)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Movy?> getMovieByIdIncludingDeleted(String id) =>
      (select(movies)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<TvSery?> getTvSeriesByIdIncludingDeleted(String id) =>
      (select(tvSeries)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<Game?> getGameByIdIncludingDeleted(String id) =>
      (select(games)..where((g) => g.id.equals(id))).getSingleOrNull();

  Future<void> applyRemoteSnapshot({
    List<Account> accountsRows = const [],
    List<TransactionEntry> transactionRows = const [],
    List<Goal> goalsRows = const [],
    List<TodoList> todoListRows = const [],
    List<TodoItem> todoItemRows = const [],
    List<NoteFolder> noteFolderRows = const [],
    List<Note> noteRows = const [],
    List<Habit> habitRows = const [],
    List<HabitLog> habitLogRows = const [],
    List<CalendarEvent> calendarEventRows = const [],
    List<NoteGoal> noteGoalRows = const [],
    List<Tracker> trackerRows = const [],
    List<Movy> movieRows = const [],
    List<TvSery> tvSeriesRows = const [],
    List<Game> gameRows = const [],
  }) async {
    await transaction(() async {
      await batch((b) {
        if (accountsRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(accounts, accountsRows);
        }
        if (transactionRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(transactionEntries, transactionRows);
        }
        if (goalsRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(goals, goalsRows);
        }
        if (todoListRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(todoLists, todoListRows);
        }
        if (todoItemRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(todoItems, todoItemRows);
        }
        if (noteFolderRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(noteFolders, noteFolderRows);
        }
        if (noteRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(notes, noteRows);
        }
        if (habitRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(habits, habitRows);
        }
        if (habitLogRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(habitLogs, habitLogRows);
        }
        if (calendarEventRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(calendarEvents, calendarEventRows);
        }
        if (noteGoalRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(noteGoals, noteGoalRows);
        }
        if (trackerRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(trackers, trackerRows);
        }
        if (movieRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(movies, movieRows);
        }
        if (tvSeriesRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(tvSeries, tvSeriesRows);
        }
        if (gameRows.isNotEmpty) {
          b.insertAllOnConflictUpdate(games, gameRows);
        }
      });
    });
  }

  // --- Accounts ---

  Stream<List<Account>> watchAccounts() =>
      (select(accounts)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Future<void> upsertAccount(AccountsCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    if (entry.id.present) {
      final existing = await getAccountByIdIncludingDeleted(id);
      if (existing != null &&
          !await _guardOwnedMutation(
            entityType: 'accounts',
            entityId: id,
            rowUserId: existing.userId,
          )) {
        return;
      }
    }
    final now = DateTime.now();
    final normalized = entry.copyWith(
      id: Value(id),
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(accounts).insertOnConflictUpdate(normalized);
    await _queueSyncChange('accounts', id, 'upsert');
  }

  Future<void> deleteAccountWithTransactions(String accountId) async {
    final account = await getAccountByIdIncludingDeleted(accountId);
    if (account == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'accounts',
      entityId: accountId,
      rowUserId: account.userId,
    )) {
      return;
    }
    await transaction(() async {
      final now = DateTime.now();
      final txIds =
          await (select(transactionEntries)..where(
                (t) => t.accountId.equals(accountId) & t.deletedAt.isNull(),
              ))
              .map((t) => t.id)
              .get();
      await (update(
            transactionEntries,
          )..where((t) => t.accountId.equals(accountId) & t.deletedAt.isNull()))
          .write(
            TransactionEntriesCompanion(
              deletedAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      await (update(
        accounts,
      )..where((t) => t.id.equals(accountId) & t.deletedAt.isNull())).write(
        AccountsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      for (final txId in txIds) {
        await _queueSyncChange('transaction_entries', txId, 'delete');
      }
      await _queueSyncChange('accounts', accountId, 'delete');
    });
  }

  // --- Transactions ---

  Stream<List<TransactionEntry>> watchTransactionsByAccount(String accountId) {
    return (select(transactionEntries)
          ..where((t) => t.accountId.equals(accountId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<TransactionEntry>> getTransactionsByAccount(String accountId) {
    return (select(transactionEntries)
          ..where((t) => t.accountId.equals(accountId))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  Future<void> insertTransaction(TransactionEntriesCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final now = DateTime.now();
    final normalized = entry.copyWith(
      id: Value(id),
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(transactionEntries).insert(normalized);
    await _queueSyncChange('transaction_entries', id, 'upsert');
  }

  Future<void> deleteTransactionById(String id) async {
    final existing = await getTransactionByIdIncludingDeleted(id);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'transaction_entries',
      entityId: id,
      rowUserId: existing.userId,
    )) {
      return;
    }
    final now = DateTime.now();
    await (update(
      transactionEntries,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).write(
      TransactionEntriesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    await _queueSyncChange('transaction_entries', id, 'delete');
  }

  // --- Goals ---

  Stream<List<Goal>> watchGoals() =>
      (select(goals)
            ..where((g) => g.deletedAt.isNull())
            ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
          .watch();

  Future<void> insertGoal(GoalsCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final now = DateTime.now();
    final normalized = entry.copyWith(
      id: Value(id),
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(goals).insert(normalized);
    await _queueSyncChange('goals', id, 'upsert');
  }

  Future<void> updateGoal(GoalsCompanion entry) async {
    final existing = await getGoalByIdIncludingDeleted(entry.id.value);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'goals',
      entityId: entry.id.value,
      rowUserId: existing.userId,
    )) {
      return;
    }
    await (update(
      goals,
    )..where((g) => g.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('goals', entry.id.value, 'upsert');
  }

  Future<void> contributeToGoal({
    required String goalId,
    required double amount,
    String? accountId,
    String? note,
  }) async {
    final goal = await getGoalByIdIncludingDeleted(goalId);
    if (goal == null || goal.deletedAt != null) {
      throw StateError('Obiettivo non trovato');
    }
    if (!await _guardOwnedMutation(
      entityType: 'goals',
      entityId: goalId,
      rowUserId: goal.userId,
    )) {
      return;
    }
    if (accountId != null) {
      final account = await getAccountByIdIncludingDeleted(accountId);
      if (account == null || account.deletedAt != null) {
        throw StateError('Conto non trovato');
      }
      if (!await _guardOwnedMutation(
        entityType: 'accounts',
        entityId: accountId,
        rowUserId: account.userId,
      )) {
        return;
      }
    }

    final now = DateTime.now();
    final newTotal = goal.currentAmount + amount;
    final isCompleted = goal.isCompleted || newTotal >= goal.targetAmount;

    await transaction(() async {
      await (update(goals)..where((g) => g.id.equals(goalId))).write(
        GoalsCompanion(
          currentAmount: Value(newTotal),
          isCompleted: Value(isCompleted),
          updatedAt: Value(now),
        ),
      );
      await _queueSyncChange('goals', goalId, 'upsert');

      if (accountId != null) {
        final txId = _uuid.v4();
        await into(transactionEntries).insert(
          TransactionEntriesCompanion.insert(
            id: Value(txId),
            userId: Value(_currentUserId()),
            accountId: accountId,
            amount: amount,
            type: 'expense',
            category: 'Obiettivi',
            date: now,
            note: Value(note),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
        await _queueSyncChange('transaction_entries', txId, 'upsert');
      }
    });
  }

  Future<void> deleteGoalById(String id) async {
    final existing = await getGoalByIdIncludingDeleted(id);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'goals',
      entityId: id,
      rowUserId: existing.userId,
    )) {
      return;
    }
    final now = DateTime.now();
    await (update(goals)..where((g) => g.id.equals(id) & g.deletedAt.isNull()))
        .write(GoalsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    await _queueSyncChange('goals', id, 'delete');
  }

  // --- Todo Lists ---

  Stream<List<TodoList>> watchTodoLists() =>
      (select(todoLists)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Future<void> insertTodoList(TodoListsCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final now = DateTime.now();
    final normalized = entry.copyWith(
      id: Value(id),
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(todoLists).insert(normalized);
    await _queueSyncChange('todo_lists', id, 'upsert');
  }

  Future<void> deleteTodoListWithItems(String listId) async {
    final existing = await getTodoListByIdIncludingDeleted(listId);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'todo_lists',
      entityId: listId,
      rowUserId: existing.userId,
    )) {
      return;
    }
    await transaction(() async {
      final now = DateTime.now();
      final itemIds =
          await (select(todoItems)
                ..where((t) => t.listId.equals(listId) & t.deletedAt.isNull()))
              .map((t) => t.id)
              .get();
      await (update(
        todoItems,
      )..where((t) => t.listId.equals(listId) & t.deletedAt.isNull())).write(
        TodoItemsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      await (update(
        todoLists,
      )..where((t) => t.id.equals(listId) & t.deletedAt.isNull())).write(
        TodoListsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      for (final itemId in itemIds) {
        await _queueSyncChange('todo_items', itemId, 'delete');
      }
      await _queueSyncChange('todo_lists', listId, 'delete');
    });
  }

  // --- Todo Items ---

  Stream<List<TodoItem>> watchTodoItems() =>
      (select(todoItems)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Future<void> insertTodoItem(TodoItemsCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final now = DateTime.now();
    final normalized = entry.copyWith(
      id: Value(id),
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(todoItems).insert(normalized);
    await _queueSyncChange('todo_items', id, 'upsert');
  }

  Future<void> updateTodoItem(TodoItemsCompanion entry) async {
    final existing = await getTodoItemByIdIncludingDeleted(entry.id.value);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'todo_items',
      entityId: entry.id.value,
      rowUserId: existing.userId,
    )) {
      return;
    }
    await (update(
      todoItems,
    )..where((t) => t.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('todo_items', entry.id.value, 'upsert');
  }

  Future<void> deleteTodoItemById(String id) async {
    final existing = await getTodoItemByIdIncludingDeleted(id);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'todo_items',
      entityId: id,
      rowUserId: existing.userId,
    )) {
      return;
    }
    final now = DateTime.now();
    await (update(
      todoItems,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).write(
      TodoItemsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    await _queueSyncChange('todo_items', id, 'delete');
  }

  // --- Note Folders ---

  Stream<List<NoteFolder>> watchNoteFolders() =>
      (select(noteFolders)
            ..where((f) => f.deletedAt.isNull())
            ..orderBy([(f) => OrderingTerm.asc(f.createdAt)]))
          .watch();

  Future<void> insertNoteFolder(NoteFoldersCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final now = DateTime.now();
    final normalized = entry.copyWith(
      id: Value(id),
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(noteFolders).insert(normalized);
    await _queueSyncChange('note_folders', id, 'upsert');
  }

  Future<void> deleteNoteFolderById(String folderId) async {
    final existing = await getNoteFolderByIdIncludingDeleted(folderId);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'note_folders',
      entityId: folderId,
      rowUserId: existing.userId,
    )) {
      return;
    }
    await transaction(() async {
      final now = DateTime.now();
      final noteIds =
          await (select(notes)..where(
                (n) => n.folderId.equals(folderId) & n.deletedAt.isNull(),
              ))
              .map((n) => n.id)
              .get();
      await (update(notes)..where((n) => n.folderId.equals(folderId))).write(
        NotesCompanion(folderId: const Value(null), updatedAt: Value(now)),
      );
      await (update(
        noteFolders,
      )..where((f) => f.id.equals(folderId) & f.deletedAt.isNull())).write(
        NoteFoldersCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      for (final noteId in noteIds) {
        await _queueSyncChange('notes', noteId, 'upsert');
      }
      await _queueSyncChange('note_folders', folderId, 'delete');
    });
  }

  // --- Notes ---

  Stream<List<Note>> watchNotes() =>
      (select(notes)
            ..where((n) => n.deletedAt.isNull())
            ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)]))
          .watch();

  Future<void> insertNote(NotesCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final now = DateTime.now();
    final normalized = entry.copyWith(
      id: Value(id),
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    try {
      await into(notes).insert(normalized);
    } catch (e, s) {
      AppLogger.instance.error(
        'Insert note fallito per $id con folderId=${normalized.folderId.present ? normalized.folderId.value : null}',
        s,
      );
      rethrow;
    }
    await _queueSyncChange('notes', id, 'upsert');
  }

  Future<void> updateNote(NotesCompanion entry) async {
    final existing = await getNoteByIdIncludingDeleted(entry.id.value);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'notes',
      entityId: entry.id.value,
      rowUserId: existing.userId,
    )) {
      return;
    }
    await (update(
      notes,
    )..where((n) => n.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('notes', entry.id.value, 'upsert');
  }

  Future<void> deleteNoteById(String id) async {
    final existing = await getNoteByIdIncludingDeleted(id);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'notes',
      entityId: id,
      rowUserId: existing.userId,
    )) {
      return;
    }
    final now = DateTime.now();
    await (update(notes)..where((n) => n.id.equals(id) & n.deletedAt.isNull()))
        .write(NotesCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    await _queueSyncChange('notes', id, 'delete');
  }

  // --- Habits ---

  Stream<List<Habit>> watchHabits() =>
      (select(habits)
            ..orderBy([
              (h) => OrderingTerm.asc(h.deletedAt),
              (h) => OrderingTerm.asc(h.category),
              (h) => OrderingTerm.asc(h.sortOrder),
              (h) => OrderingTerm.asc(h.createdAt),
            ])
            ..where((h) => h.deletedAt.isNull()))
          .watch();

  Future<void> insertHabit(HabitsCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final now = DateTime.now();
    final normalized = entry.copyWith(
      id: Value(id),
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(habits).insert(normalized);
    await _queueSyncChange('habits', id, 'upsert');
  }

  Future<void> updateHabit(HabitsCompanion entry) async {
    final existing = await getHabitByIdIncludingDeleted(entry.id.value);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'habits',
      entityId: entry.id.value,
      rowUserId: existing.userId,
    )) {
      return;
    }
    await (update(
      habits,
    )..where((h) => h.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('habits', entry.id.value, 'upsert');
  }

  Future<void> deleteHabitById(String id) async {
    final existing = await getHabitByIdIncludingDeleted(id);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'habits',
      entityId: id,
      rowUserId: existing.userId,
    )) {
      return;
    }
    await transaction(() async {
      final now = DateTime.now();
      final logs = await (select(
        habitLogs,
      )..where((l) => l.habitId.equals(id) & l.deletedAt.isNull())).get();
      await (update(
        habitLogs,
      )..where((l) => l.habitId.equals(id) & l.deletedAt.isNull())).write(
        HabitLogsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      await (update(habits)
            ..where((h) => h.id.equals(id) & h.deletedAt.isNull()))
          .write(HabitsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      for (final log in logs) {
        await _queueSyncChange(
          'habit_logs',
          '${log.habitId}|${log.date.toIso8601String()}',
          'delete',
        );
      }
      await _queueSyncChange('habits', id, 'delete');
    });
  }

  // --- HabitLogs ---

  Stream<List<HabitLog>> watchHabitLogsForRange(DateTime from, DateTime to) =>
      (select(habitLogs)..where(
            (l) =>
                l.date.isBiggerOrEqualValue(from) &
                l.date.isSmallerOrEqualValue(to) &
                l.deletedAt.isNull(),
          ))
          .watch();

  Future<void> setHabitLog(HabitLogsCompanion entry) async {
    final existing = await getHabitLogIncludingDeleted(
      entry.habitId.value,
      entry.date.value,
    );
    if (existing != null &&
        !await _guardOwnedMutation(
          entityType: 'habit_logs',
          entityId:
              '${entry.habitId.value}|${entry.date.value.toIso8601String()}',
          rowUserId: existing.userId,
        )) {
      return;
    }
    final now = DateTime.now();
    final normalized = entry.copyWith(
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(habitLogs).insertOnConflictUpdate(normalized);
    await _queueSyncChange(
      'habit_logs',
      '${normalized.habitId.value}|${normalized.date.value.toIso8601String()}',
      'upsert',
    );
  }

  Future<void> clearHabitLog(String habitId, DateTime date) async {
    final existing = await getHabitLogIncludingDeleted(habitId, date);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'habit_logs',
      entityId: '$habitId|${date.toIso8601String()}',
      rowUserId: existing.userId,
    )) {
      return;
    }
    final now = DateTime.now();
    await (update(habitLogs)..where(
          (l) =>
              l.habitId.equals(habitId) &
              l.date.equals(date) &
              l.deletedAt.isNull(),
        ))
        .write(
          HabitLogsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
    await _queueSyncChange(
      'habit_logs',
      '$habitId|${date.toIso8601String()}',
      'delete',
    );
  }

  Future<List<HabitLog>> getRecentHabitLogs(DateTime from) =>
      (select(habitLogs)
            ..where(
              (l) => l.date.isBiggerOrEqualValue(from) & l.deletedAt.isNull(),
            )
            ..orderBy([(l) => OrderingTerm.desc(l.date)]))
          .get();

  // --- Trackers ---

  Stream<List<Tracker>> watchTrackers() =>
      (select(trackers)
            ..orderBy([
              (t) => OrderingTerm.asc(t.deletedAt),
              (t) => OrderingTerm.asc(t.sortOrder),
              (t) => OrderingTerm.asc(t.createdAt),
            ])
            ..where((t) => t.deletedAt.isNull()))
          .watch();

  Future<void> insertTracker(TrackersCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final now = DateTime.now();
    final normalized = entry.copyWith(
      id: Value(id),
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(trackers).insert(normalized);
    await _queueSyncChange('trackers', id, 'upsert');
  }

  Future<void> updateTracker(TrackersCompanion entry) async {
    final existing = await getTrackerByIdIncludingDeleted(entry.id.value);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'trackers',
      entityId: entry.id.value,
      rowUserId: existing.userId,
    )) {
      return;
    }
    await (update(
      trackers,
    )..where((t) => t.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('trackers', entry.id.value, 'upsert');
  }

  Future<void> deleteTrackerById(String id) async {
    final existing = await getTrackerByIdIncludingDeleted(id);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'trackers',
      entityId: id,
      rowUserId: existing.userId,
    )) {
      return;
    }
    final now = DateTime.now();
    await (update(trackers)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .write(TrackersCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    await _queueSyncChange('trackers', id, 'delete');
  }

  // --- Note Goals ---

  Stream<List<NoteGoal>> watchNoteGoals() =>
      (select(noteGoals)
            ..where((g) => g.deletedAt.isNull())
            ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
          .watch();

  Future<void> insertNoteGoal(NoteGoalsCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final now = DateTime.now();
    final normalized = entry.copyWith(
      id: Value(id),
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(noteGoals).insert(normalized);
    await _queueSyncChange('note_goals', id, 'upsert');
  }

  Future<void> updateNoteGoal(NoteGoalsCompanion entry) async {
    final existing = await getNoteGoalByIdIncludingDeleted(entry.id.value);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'note_goals',
      entityId: entry.id.value,
      rowUserId: existing.userId,
    )) {
      return;
    }
    await (update(
      noteGoals,
    )..where((g) => g.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('note_goals', entry.id.value, 'upsert');
  }

  Future<void> deleteNoteGoalById(String id) async {
    final existing = await getNoteGoalByIdIncludingDeleted(id);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'note_goals',
      entityId: id,
      rowUserId: existing.userId,
    )) {
      return;
    }
    final now = DateTime.now();
    await (update(
      noteGoals,
    )..where((g) => g.id.equals(id) & g.deletedAt.isNull())).write(
      NoteGoalsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    await _queueSyncChange('note_goals', id, 'delete');
  }

  // --- Movies ---

  Stream<List<Movy>> watchMovies() =>
      (select(movies)
            ..where((m) => m.deletedAt.isNull())
            ..orderBy([(m) => OrderingTerm.desc(m.addedAt)]))
          .watch();

  Future<void> insertMovie(MoviesCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final now = DateTime.now();
    final normalized = entry.copyWith(
      id: Value(id),
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      addedAt: entry.addedAt.present ? entry.addedAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(movies).insert(normalized);
    await _queueSyncChange('movies', id, 'upsert');
  }

  Future<void> updateMovie(MoviesCompanion entry) async {
    final existing = await getMovieByIdIncludingDeleted(entry.id.value);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'movies',
      entityId: entry.id.value,
      rowUserId: existing.userId,
    )) {
      return;
    }
    await (update(
      movies,
    )..where((m) => m.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('movies', entry.id.value, 'upsert');
  }

  Future<void> deleteMovieById(String id) async {
    final existing = await getMovieByIdIncludingDeleted(id);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'movies',
      entityId: id,
      rowUserId: existing.userId,
    )) {
      return;
    }
    final now = DateTime.now();
    await (update(movies)..where((m) => m.id.equals(id) & m.deletedAt.isNull()))
        .write(MoviesCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    await _queueSyncChange('movies', id, 'delete');
  }

  // --- TV Series ---

  Stream<List<TvSery>> watchTvSeries() =>
      (select(tvSeries)
            ..where((s) => s.deletedAt.isNull())
            ..orderBy([(s) => OrderingTerm.desc(s.addedAt)]))
          .watch();

  Future<void> insertTvSeries(TvSeriesCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final now = DateTime.now();
    final normalized = entry.copyWith(
      id: Value(id),
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      addedAt: entry.addedAt.present ? entry.addedAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(tvSeries).insert(normalized);
    await _queueSyncChange('tv_series', id, 'upsert');
  }

  Future<void> updateTvSeries(TvSeriesCompanion entry) async {
    final existing = await getTvSeriesByIdIncludingDeleted(entry.id.value);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'tv_series',
      entityId: entry.id.value,
      rowUserId: existing.userId,
    )) {
      return;
    }
    await (update(
      tvSeries,
    )..where((s) => s.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('tv_series', entry.id.value, 'upsert');
  }

  Future<void> deleteTvSeriesById(String id) async {
    final existing = await getTvSeriesByIdIncludingDeleted(id);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'tv_series',
      entityId: id,
      rowUserId: existing.userId,
    )) {
      return;
    }
    final now = DateTime.now();
    await (update(tvSeries)
          ..where((s) => s.id.equals(id) & s.deletedAt.isNull()))
        .write(TvSeriesCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    await _queueSyncChange('tv_series', id, 'delete');
  }

  // --- Games ---

  Stream<List<Game>> watchGames() =>
      (select(games)
            ..where((g) => g.deletedAt.isNull())
            ..orderBy([(g) => OrderingTerm.desc(g.addedAt)]))
          .watch();

  Future<void> insertGame(GamesCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final now = DateTime.now();
    final normalized = entry.copyWith(
      id: Value(id),
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      addedAt: entry.addedAt.present ? entry.addedAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(games).insert(normalized);
    await _queueSyncChange('games', id, 'upsert');
  }

  Future<void> updateGame(GamesCompanion entry) async {
    final existing = await getGameByIdIncludingDeleted(entry.id.value);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'games',
      entityId: entry.id.value,
      rowUserId: existing.userId,
    )) {
      return;
    }
    await (update(
      games,
    )..where((g) => g.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('games', entry.id.value, 'upsert');
  }

  Future<void> deleteGameById(String id) async {
    final existing = await getGameByIdIncludingDeleted(id);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'games',
      entityId: id,
      rowUserId: existing.userId,
    )) {
      return;
    }
    final now = DateTime.now();
    await (update(games)..where((g) => g.id.equals(id) & g.deletedAt.isNull()))
        .write(GamesCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    await _queueSyncChange('games', id, 'delete');
  }

  // --- Calendar Events ---

  Stream<List<CalendarEvent>> watchCalendarEvents() =>
      (select(calendarEvents)
            ..where((e) => e.deletedAt.isNull())
            ..orderBy([(e) => OrderingTerm.asc(e.startDate)]))
          .watch();

  Future<void> insertCalendarEvent(CalendarEventsCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final now = DateTime.now();
    final normalized = entry.copyWith(
      id: Value(id),
      userId: entry.userId.present ? entry.userId : Value(_currentUserId()),
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(calendarEvents).insert(normalized);
    await _queueSyncChange('calendar_events', id, 'upsert');
  }

  Future<void> updateCalendarEvent(CalendarEventsCompanion entry) async {
    final existing = await getCalendarEventByIdIncludingDeleted(entry.id.value);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'calendar_events',
      entityId: entry.id.value,
      rowUserId: existing.userId,
    )) {
      return;
    }
    await (update(
      calendarEvents,
    )..where((e) => e.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('calendar_events', entry.id.value, 'upsert');
  }

  Future<void> deleteCalendarEventById(String id) async {
    final existing = await getCalendarEventByIdIncludingDeleted(id);
    if (existing == null) return;
    if (!await _guardOwnedMutation(
      entityType: 'calendar_events',
      entityId: id,
      rowUserId: existing.userId,
    )) {
      return;
    }
    final now = DateTime.now();
    await (update(
      calendarEvents,
    )..where((e) => e.id.equals(id) & e.deletedAt.isNull())).write(
      CalendarEventsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    await _queueSyncChange('calendar_events', id, 'delete');
  }

  Future<void> clearSyncedDataForUser(String userId) async {
    await transaction(() async {
      await (delete(accounts)..where((t) => t.userId.equals(userId))).go();
      await (delete(
        transactionEntries,
      )..where((t) => t.userId.equals(userId))).go();
      await (delete(goals)..where((t) => t.userId.equals(userId))).go();
      await (delete(todoLists)..where((t) => t.userId.equals(userId))).go();
      await (delete(todoItems)..where((t) => t.userId.equals(userId))).go();
      await (delete(noteFolders)..where((t) => t.userId.equals(userId))).go();
      await (delete(notes)..where((t) => t.userId.equals(userId))).go();
      await (delete(habits)..where((t) => t.userId.equals(userId))).go();
      await (delete(habitLogs)..where((t) => t.userId.equals(userId))).go();
      await (delete(
        calendarEvents,
      )..where((t) => t.userId.equals(userId))).go();
      await (delete(noteGoals)..where((t) => t.userId.equals(userId))).go();
      await (delete(trackers)..where((t) => t.userId.equals(userId))).go();
      await (delete(movies)..where((t) => t.userId.equals(userId))).go();
      await (delete(tvSeries)..where((t) => t.userId.equals(userId))).go();
      await (delete(games)..where((t) => t.userId.equals(userId))).go();
      await delete(syncQueueEntries).go();
    });
  }

  Stream<List<SyncQueueEntry>> watchPendingSyncQueue() => (select(
    syncQueueEntries,
  )..orderBy([(q) => OrderingTerm.asc(q.createdAt)])).watch();

  Future<List<SyncQueueEntry>> getPendingSyncQueue() => (select(
    syncQueueEntries,
  )..orderBy([(q) => OrderingTerm.asc(q.createdAt)])).get();

  Future<void> markSyncEntryFailed(String id, String errorMessage) =>
      (update(syncQueueEntries)..where((q) => q.id.equals(id))).write(
        SyncQueueEntriesCompanion(
          lastAttemptAt: Value(DateTime.now()),
          retryCount: const Value.absent(),
          lastError: Value(errorMessage),
        ),
      );

  Future<void> incrementSyncRetry(String id, int currentRetryCount) =>
      (update(syncQueueEntries)..where((q) => q.id.equals(id))).write(
        SyncQueueEntriesCompanion(
          lastAttemptAt: Value(DateTime.now()),
          retryCount: Value(currentRetryCount + 1),
        ),
      );

  Future<void> completeSyncEntry(String id) =>
      (delete(syncQueueEntries)..where((q) => q.id.equals(id))).go();
}
