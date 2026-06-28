import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

const _uuid = Uuid();

class Accounts extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
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
  TextColumn get name => text()();
  TextColumn get category => text().withDefault(const Constant(''))(); // 'Mattina'|'Pomeriggio'|'Sera'
  IntColumn get sortOrder => integer().named('sort_order').withDefault(const Constant(0))();
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
  BoolColumn get isDailyAutoIncrement =>
      boolean().named('daily_auto_increment').withDefault(const Constant(false))();
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
  BoolColumn get inOriginalLanguage =>
      boolean().named('in_original_language').withDefault(const Constant(false))();
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
  BoolColumn get inOriginalLanguage =>
      boolean().named('in_original_language').withDefault(const Constant(false))();
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
  TextColumn get title => text()();
  TextColumn get platform => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('playing'))(); // playing | completed | want_to_play
  TextColumn get objectives => text().withDefault(const Constant('[]'))(); // JSON [{desc, done}]
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
    tables: [Accounts, TransactionEntries, Goals, TodoLists, TodoItems, NoteFolders, Notes, Habits, HabitLogs, CalendarEvents, NoteGoals, Trackers, Movies, TvSeries, Games, SyncQueueEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 13;

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
            await m.addColumn(accounts, accounts.updatedAt);
            await m.addColumn(accounts, accounts.deletedAt);
            await m.addColumn(transactionEntries, transactionEntries.updatedAt);
            await m.addColumn(transactionEntries, transactionEntries.deletedAt);
            await m.addColumn(goals, goals.updatedAt);
            await m.addColumn(goals, goals.deletedAt);
            await m.addColumn(todoLists, todoLists.updatedAt);
            await m.addColumn(todoLists, todoLists.deletedAt);
            await m.addColumn(todoItems, todoItems.updatedAt);
            await m.addColumn(todoItems, todoItems.deletedAt);
            await m.addColumn(habits, habits.updatedAt);
            await m.addColumn(habits, habits.deletedAt);
            await m.addColumn(habitLogs, habitLogs.updatedAt);
            await m.addColumn(habitLogs, habitLogs.deletedAt);
            await m.addColumn(calendarEvents, calendarEvents.updatedAt);
            await m.addColumn(calendarEvents, calendarEvents.deletedAt);
            await m.addColumn(noteFolders, noteFolders.updatedAt);
            await m.addColumn(noteFolders, noteFolders.deletedAt);
            await m.addColumn(notes, notes.deletedAt);
            await m.addColumn(noteGoals, noteGoals.deletedAt);
            await m.addColumn(trackers, trackers.deletedAt);
            await m.addColumn(movies, movies.updatedAt);
            await m.addColumn(movies, movies.deletedAt);
            await m.addColumn(tvSeries, tvSeries.updatedAt);
            await m.addColumn(tvSeries, tvSeries.deletedAt);
            await m.addColumn(games, games.updatedAt);
            await m.addColumn(games, games.deletedAt);
          }
          if (from < 13) {
            await m.createTable(syncQueueEntries);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'productivity_db');
  }

  Future<void> _queueSyncChange(
    String entityType,
    String entityId,
    String operation,
  ) async {
    await (delete(syncQueueEntries)
          ..where((q) =>
              q.entityType.equals(entityType) & q.entityId.equals(entityId)))
        .go();
    await into(syncQueueEntries).insert(
      SyncQueueEntriesCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        operation: operation,
      ),
    );
  }

  Future<Account?> getAccountByIdIncludingDeleted(String id) =>
      (select(accounts)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<TransactionEntry?> getTransactionByIdIncludingDeleted(String id) =>
      (select(transactionEntries)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

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
            ..where((l) =>
                l.habitId.equals(habitId) & l.date.equals(date)))
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

  // --- Accounts ---

  Stream<List<Account>> watchAccounts() =>
      (select(accounts)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Future<void> upsertAccount(AccountsCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final normalized = entry.copyWith(id: Value(id));
    await into(accounts).insertOnConflictUpdate(normalized);
    await _queueSyncChange('accounts', id, 'upsert');
  }

  Future<void> deleteAccountWithTransactions(String accountId) async {
    await transaction(() async {
      final now = DateTime.now();
      final txIds = await (select(transactionEntries)
            ..where((t) =>
                t.accountId.equals(accountId) & t.deletedAt.isNull()))
          .map((t) => t.id)
          .get();
      await (update(transactionEntries)
            ..where((t) =>
                t.accountId.equals(accountId) & t.deletedAt.isNull()))
          .write(
        TransactionEntriesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await (update(accounts)
            ..where((t) => t.id.equals(accountId) & t.deletedAt.isNull()))
          .write(
        AccountsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
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
    final normalized = entry.copyWith(id: Value(id));
    await into(transactionEntries).insert(normalized);
    await _queueSyncChange('transaction_entries', id, 'upsert');
  }

  Future<void> deleteTransactionById(String id) async {
    final now = DateTime.now();
    await (update(transactionEntries)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .write(
      TransactionEntriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
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
    final normalized = entry.copyWith(id: Value(id));
    await into(goals).insert(normalized);
    await _queueSyncChange('goals', id, 'upsert');
  }

  Future<void> updateGoal(GoalsCompanion entry) async {
    await (update(goals)..where((g) => g.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('goals', entry.id.value, 'upsert');
  }

  Future<void> deleteGoalById(String id) async {
    final now = DateTime.now();
    await (update(goals)..where((g) => g.id.equals(id) & g.deletedAt.isNull()))
        .write(
      GoalsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
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
    final normalized = entry.copyWith(id: Value(id));
    await into(todoLists).insert(normalized);
    await _queueSyncChange('todo_lists', id, 'upsert');
  }

  Future<void> deleteTodoListWithItems(String listId) async {
    await transaction(() async {
      final now = DateTime.now();
      final itemIds = await (select(todoItems)
            ..where((t) => t.listId.equals(listId) & t.deletedAt.isNull()))
          .map((t) => t.id)
          .get();
      await (update(todoItems)
            ..where((t) => t.listId.equals(listId) & t.deletedAt.isNull()))
          .write(
        TodoItemsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await (update(todoLists)
            ..where((t) => t.id.equals(listId) & t.deletedAt.isNull()))
          .write(
        TodoListsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
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
    final normalized = entry.copyWith(id: Value(id));
    await into(todoItems).insert(normalized);
    await _queueSyncChange('todo_items', id, 'upsert');
  }

  Future<void> updateTodoItem(TodoItemsCompanion entry) async {
    await (update(todoItems)..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
    await _queueSyncChange('todo_items', entry.id.value, 'upsert');
  }

  Future<void> deleteTodoItemById(String id) async {
    final now = DateTime.now();
    await (update(todoItems)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .write(
      TodoItemsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
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
    final normalized = entry.copyWith(id: Value(id));
    await into(noteFolders).insert(normalized);
    await _queueSyncChange('note_folders', id, 'upsert');
  }

  Future<void> deleteNoteFolderById(String folderId) async {
    await transaction(() async {
      final now = DateTime.now();
      final noteIds = await (select(notes)
            ..where((n) =>
                n.folderId.equals(folderId) & n.deletedAt.isNull()))
          .map((n) => n.id)
          .get();
      await (update(notes)..where((n) => n.folderId.equals(folderId)))
          .write(NotesCompanion(
        folderId: const Value(null),
        updatedAt: Value(now),
      ));
      await (update(noteFolders)
            ..where((f) => f.id.equals(folderId) & f.deletedAt.isNull()))
          .write(
        NoteFoldersCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
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
    final normalized = entry.copyWith(id: Value(id));
    await into(notes).insert(normalized);
    await _queueSyncChange('notes', id, 'upsert');
  }

  Future<void> updateNote(NotesCompanion entry) async {
    await (update(notes)..where((n) => n.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('notes', entry.id.value, 'upsert');
  }

  Future<void> deleteNoteById(String id) async {
    final now = DateTime.now();
    await (update(notes)..where((n) => n.id.equals(id) & n.deletedAt.isNull()))
        .write(
      NotesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await _queueSyncChange('notes', id, 'delete');
  }

  // --- Habits ---

  Stream<List<Habit>> watchHabits() =>
      (select(habits)..orderBy([
        (h) => OrderingTerm.asc(h.deletedAt),
        (h) => OrderingTerm.asc(h.category),
        (h) => OrderingTerm.asc(h.sortOrder),
        (h) => OrderingTerm.asc(h.createdAt),
      ])..where((h) => h.deletedAt.isNull())).watch();

  Future<void> insertHabit(HabitsCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final normalized = entry.copyWith(id: Value(id));
    await into(habits).insert(normalized);
    await _queueSyncChange('habits', id, 'upsert');
  }

  Future<void> updateHabit(HabitsCompanion entry) async {
    await (update(habits)..where((h) => h.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('habits', entry.id.value, 'upsert');
  }

  Future<void> deleteHabitById(String id) async {
    await transaction(() async {
      final now = DateTime.now();
      final logs = await (select(habitLogs)
            ..where((l) => l.habitId.equals(id) & l.deletedAt.isNull()))
          .get();
      await (update(habitLogs)
            ..where((l) => l.habitId.equals(id) & l.deletedAt.isNull()))
          .write(HabitLogsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
      await (update(habits)
            ..where((h) => h.id.equals(id) & h.deletedAt.isNull()))
          .write(HabitsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
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
      (select(habitLogs)
            ..where((l) =>
                l.date.isBiggerOrEqualValue(from) &
                l.date.isSmallerOrEqualValue(to) &
                l.deletedAt.isNull()))
          .watch();

  Future<void> setHabitLog(HabitLogsCompanion entry) async {
    await into(habitLogs).insertOnConflictUpdate(entry);
    await _queueSyncChange(
      'habit_logs',
      '${entry.habitId.value}|${entry.date.value.toIso8601String()}',
      'upsert',
    );
  }

  Future<void> clearHabitLog(String habitId, DateTime date) async {
    final now = DateTime.now();
    await (update(habitLogs)
          ..where((l) =>
              l.habitId.equals(habitId) &
              l.date.equals(date) &
              l.deletedAt.isNull()))
        .write(
      HabitLogsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await _queueSyncChange(
      'habit_logs',
      '$habitId|${date.toIso8601String()}',
      'delete',
    );
  }

  Future<List<HabitLog>> getRecentHabitLogs(DateTime from) =>
      (select(habitLogs)
            ..where((l) =>
                l.date.isBiggerOrEqualValue(from) & l.deletedAt.isNull())
            ..orderBy([(l) => OrderingTerm.desc(l.date)]))
          .get();

  // --- Trackers ---

  Stream<List<Tracker>> watchTrackers() =>
      (select(trackers)..orderBy([
        (t) => OrderingTerm.asc(t.deletedAt),
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.createdAt),
      ])..where((t) => t.deletedAt.isNull())).watch();

  Future<void> insertTracker(TrackersCompanion entry) async {
    final id = entry.id.present ? entry.id.value : _uuid.v4();
    final normalized = entry.copyWith(id: Value(id));
    await into(trackers).insert(normalized);
    await _queueSyncChange('trackers', id, 'upsert');
  }

  Future<void> updateTracker(TrackersCompanion entry) async {
    await (update(trackers)..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
    await _queueSyncChange('trackers', entry.id.value, 'upsert');
  }

  Future<void> deleteTrackerById(String id) async {
    final now = DateTime.now();
    await (update(trackers)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .write(
      TrackersCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
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
    final normalized = entry.copyWith(id: Value(id));
    await into(noteGoals).insert(normalized);
    await _queueSyncChange('note_goals', id, 'upsert');
  }

  Future<void> updateNoteGoal(NoteGoalsCompanion entry) async {
    await (update(noteGoals)..where((g) => g.id.equals(entry.id.value)))
        .write(entry);
    await _queueSyncChange('note_goals', entry.id.value, 'upsert');
  }

  Future<void> deleteNoteGoalById(String id) async {
    final now = DateTime.now();
    await (update(noteGoals)
          ..where((g) => g.id.equals(id) & g.deletedAt.isNull()))
        .write(
      NoteGoalsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
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
    final normalized = entry.copyWith(id: Value(id));
    await into(movies).insert(normalized);
    await _queueSyncChange('movies', id, 'upsert');
  }

  Future<void> updateMovie(MoviesCompanion entry) async {
    await (update(movies)..where((m) => m.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('movies', entry.id.value, 'upsert');
  }

  Future<void> deleteMovieById(String id) async {
    final now = DateTime.now();
    await (update(movies)..where((m) => m.id.equals(id) & m.deletedAt.isNull()))
        .write(
      MoviesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
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
    final normalized = entry.copyWith(id: Value(id));
    await into(tvSeries).insert(normalized);
    await _queueSyncChange('tv_series', id, 'upsert');
  }

  Future<void> updateTvSeries(TvSeriesCompanion entry) async {
    await (update(tvSeries)..where((s) => s.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('tv_series', entry.id.value, 'upsert');
  }

  Future<void> deleteTvSeriesById(String id) async {
    final now = DateTime.now();
    await (update(tvSeries)
          ..where((s) => s.id.equals(id) & s.deletedAt.isNull()))
        .write(
      TvSeriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
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
    final normalized = entry.copyWith(id: Value(id));
    await into(games).insert(normalized);
    await _queueSyncChange('games', id, 'upsert');
  }

  Future<void> updateGame(GamesCompanion entry) async {
    await (update(games)..where((g) => g.id.equals(entry.id.value))).write(entry);
    await _queueSyncChange('games', entry.id.value, 'upsert');
  }

  Future<void> deleteGameById(String id) async {
    final now = DateTime.now();
    await (update(games)..where((g) => g.id.equals(id) & g.deletedAt.isNull()))
        .write(
      GamesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
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
    final normalized = entry.copyWith(id: Value(id));
    await into(calendarEvents).insert(normalized);
    await _queueSyncChange('calendar_events', id, 'upsert');
  }

  Future<void> updateCalendarEvent(CalendarEventsCompanion entry) async {
    await (update(calendarEvents)..where((e) => e.id.equals(entry.id.value)))
        .write(entry);
    await _queueSyncChange('calendar_events', entry.id.value, 'upsert');
  }

  Future<void> deleteCalendarEventById(String id) async {
    final now = DateTime.now();
    await (update(calendarEvents)
          ..where((e) => e.id.equals(id) & e.deletedAt.isNull()))
        .write(
      CalendarEventsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await _queueSyncChange('calendar_events', id, 'delete');
  }

  Stream<List<SyncQueueEntry>> watchPendingSyncQueue() =>
      (select(syncQueueEntries)
            ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
          .watch();

  Future<List<SyncQueueEntry>> getPendingSyncQueue() =>
      (select(syncQueueEntries)
            ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
          .get();

  Future<void> markSyncEntryFailed(
    String id,
    String errorMessage,
  ) =>
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
