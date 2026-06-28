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

@DriftDatabase(
    tables: [Accounts, TransactionEntries, Goals, TodoLists, TodoItems, NoteFolders, Notes, Habits, HabitLogs, CalendarEvents, NoteGoals, Trackers, Movies, TvSeries, Games])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 12;

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
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'productivity_db');
  }

  // --- Accounts ---

  Stream<List<Account>> watchAccounts() =>
      (select(accounts)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Future<void> upsertAccount(AccountsCompanion entry) =>
      into(accounts).insertOnConflictUpdate(entry);

  Future<void> deleteAccountWithTransactions(String accountId) async {
    await transaction(() async {
      await (delete(transactionEntries)
            ..where((t) => t.accountId.equals(accountId)))
          .go();
      await (delete(accounts)..where((t) => t.id.equals(accountId))).go();
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

  Future<void> insertTransaction(TransactionEntriesCompanion entry) =>
      into(transactionEntries).insert(entry);

  Future<void> deleteTransactionById(String id) =>
      (delete(transactionEntries)..where((t) => t.id.equals(id))).go();

  // --- Goals ---

  Stream<List<Goal>> watchGoals() =>
      (select(goals)
            ..where((g) => g.deletedAt.isNull())
            ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
          .watch();

  Future<void> insertGoal(GoalsCompanion entry) => into(goals).insert(entry);

  Future<void> updateGoal(GoalsCompanion entry) =>
      (update(goals)..where((g) => g.id.equals(entry.id.value))).write(entry);

  Future<void> deleteGoalById(String id) =>
      (delete(goals)..where((g) => g.id.equals(id))).go();

  // --- Todo Lists ---

  Stream<List<TodoList>> watchTodoLists() =>
      (select(todoLists)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Future<void> insertTodoList(TodoListsCompanion entry) =>
      into(todoLists).insert(entry);

  Future<void> deleteTodoListWithItems(String listId) async {
    await transaction(() async {
      await (delete(todoItems)..where((t) => t.listId.equals(listId))).go();
      await (delete(todoLists)..where((t) => t.id.equals(listId))).go();
    });
  }

  // --- Todo Items ---

  Stream<List<TodoItem>> watchTodoItems() =>
      (select(todoItems)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Future<void> insertTodoItem(TodoItemsCompanion entry) =>
      into(todoItems).insert(entry);

  Future<void> updateTodoItem(TodoItemsCompanion entry) =>
      (update(todoItems)..where((t) => t.id.equals(entry.id.value)))
          .write(entry);

  Future<void> deleteTodoItemById(String id) =>
      (delete(todoItems)..where((t) => t.id.equals(id))).go();

  // --- Note Folders ---

  Stream<List<NoteFolder>> watchNoteFolders() =>
      (select(noteFolders)
            ..where((f) => f.deletedAt.isNull())
            ..orderBy([(f) => OrderingTerm.asc(f.createdAt)]))
          .watch();

  Future<void> insertNoteFolder(NoteFoldersCompanion entry) =>
      into(noteFolders).insert(entry);

  Future<void> deleteNoteFolderById(String folderId) async {
    await transaction(() async {
      await (update(notes)..where((n) => n.folderId.equals(folderId)))
          .write(const NotesCompanion(folderId: Value(null)));
      await (delete(noteFolders)..where((f) => f.id.equals(folderId))).go();
    });
  }

  // --- Notes ---

  Stream<List<Note>> watchNotes() =>
      (select(notes)
            ..where((n) => n.deletedAt.isNull())
            ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)]))
          .watch();

  Future<void> insertNote(NotesCompanion entry) =>
      into(notes).insert(entry);

  Future<void> updateNote(NotesCompanion entry) =>
      (update(notes)..where((n) => n.id.equals(entry.id.value))).write(entry);

  Future<void> deleteNoteById(String id) =>
      (delete(notes)..where((n) => n.id.equals(id))).go();

  // --- Habits ---

  Stream<List<Habit>> watchHabits() =>
      (select(habits)..orderBy([
        (h) => OrderingTerm.asc(h.deletedAt),
        (h) => OrderingTerm.asc(h.category),
        (h) => OrderingTerm.asc(h.sortOrder),
        (h) => OrderingTerm.asc(h.createdAt),
      ])..where((h) => h.deletedAt.isNull())).watch();

  Future<void> insertHabit(HabitsCompanion entry) =>
      into(habits).insert(entry);

  Future<void> updateHabit(HabitsCompanion entry) =>
      (update(habits)..where((h) => h.id.equals(entry.id.value))).write(entry);

  Future<void> deleteHabitById(String id) async {
    await transaction(() async {
      await (delete(habitLogs)..where((l) => l.habitId.equals(id))).go();
      await (delete(habits)..where((h) => h.id.equals(id))).go();
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

  Future<void> setHabitLog(HabitLogsCompanion entry) =>
      into(habitLogs).insertOnConflictUpdate(entry);

  Future<void> clearHabitLog(String habitId, DateTime date) =>
      (delete(habitLogs)
            ..where((l) =>
                l.habitId.equals(habitId) & l.date.equals(date)))
          .go();

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

  Future<void> insertTracker(TrackersCompanion entry) =>
      into(trackers).insert(entry);

  Future<void> updateTracker(TrackersCompanion entry) =>
      (update(trackers)..where((t) => t.id.equals(entry.id.value)))
          .write(entry);

  Future<void> deleteTrackerById(String id) =>
      (delete(trackers)..where((t) => t.id.equals(id))).go();

  // --- Note Goals ---

  Stream<List<NoteGoal>> watchNoteGoals() =>
      (select(noteGoals)
            ..where((g) => g.deletedAt.isNull())
            ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
          .watch();

  Future<void> insertNoteGoal(NoteGoalsCompanion entry) =>
      into(noteGoals).insert(entry);

  Future<void> updateNoteGoal(NoteGoalsCompanion entry) =>
      (update(noteGoals)..where((g) => g.id.equals(entry.id.value)))
          .write(entry);

  Future<void> deleteNoteGoalById(String id) =>
      (delete(noteGoals)..where((g) => g.id.equals(id))).go();

  // --- Movies ---

  Stream<List<Movy>> watchMovies() =>
      (select(movies)
            ..where((m) => m.deletedAt.isNull())
            ..orderBy([(m) => OrderingTerm.desc(m.addedAt)]))
          .watch();

  Future<void> insertMovie(MoviesCompanion entry) => into(movies).insert(entry);

  Future<void> updateMovie(MoviesCompanion entry) =>
      (update(movies)..where((m) => m.id.equals(entry.id.value))).write(entry);

  Future<void> deleteMovieById(String id) =>
      (delete(movies)..where((m) => m.id.equals(id))).go();

  // --- TV Series ---

  Stream<List<TvSery>> watchTvSeries() =>
      (select(tvSeries)
            ..where((s) => s.deletedAt.isNull())
            ..orderBy([(s) => OrderingTerm.desc(s.addedAt)]))
          .watch();

  Future<void> insertTvSeries(TvSeriesCompanion entry) =>
      into(tvSeries).insert(entry);

  Future<void> updateTvSeries(TvSeriesCompanion entry) =>
      (update(tvSeries)..where((s) => s.id.equals(entry.id.value))).write(entry);

  Future<void> deleteTvSeriesById(String id) =>
      (delete(tvSeries)..where((s) => s.id.equals(id))).go();

  // --- Games ---

  Stream<List<Game>> watchGames() =>
      (select(games)
            ..where((g) => g.deletedAt.isNull())
            ..orderBy([(g) => OrderingTerm.desc(g.addedAt)]))
          .watch();

  Future<void> insertGame(GamesCompanion entry) => into(games).insert(entry);

  Future<void> updateGame(GamesCompanion entry) =>
      (update(games)..where((g) => g.id.equals(entry.id.value))).write(entry);

  Future<void> deleteGameById(String id) =>
      (delete(games)..where((g) => g.id.equals(id))).go();

  // --- Calendar Events ---

  Stream<List<CalendarEvent>> watchCalendarEvents() =>
      (select(calendarEvents)
            ..where((e) => e.deletedAt.isNull())
            ..orderBy([(e) => OrderingTerm.asc(e.startDate)]))
          .watch();

  Future<void> insertCalendarEvent(CalendarEventsCompanion entry) =>
      into(calendarEvents).insert(entry);

  Future<void> updateCalendarEvent(CalendarEventsCompanion entry) =>
      (update(calendarEvents)..where((e) => e.id.equals(entry.id.value)))
          .write(entry);

  Future<void> deleteCalendarEventById(String id) =>
      (delete(calendarEvents)..where((e) => e.id.equals(id))).go();
}
