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

  @override
  Set<Column> get primaryKey => {id};
}

class TodoLists extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text()();
  IntColumn get colorValue => integer().named('color_value')();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

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

  @override
  Set<Column> get primaryKey => {id};
}

class HabitLogs extends Table {
  TextColumn get habitId => text().named('habit_id')();
  DateTimeColumn get date => dateTime()(); // mezzanotte del giorno
  TextColumn get status => text()(); // 'done' | 'skip' | 'na'

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

  @override
  Set<Column> get primaryKey => {id};
}

class NoteFolders extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

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

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
    tables: [Accounts, TransactionEntries, Goals, TodoLists, TodoItems, NoteFolders, Notes, Habits, HabitLogs, CalendarEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

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
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'productivity_db');
  }

  // --- Accounts ---

  Stream<List<Account>> watchAccounts() =>
      (select(accounts)..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
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
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<TransactionEntry>> getTransactionsByAccount(String accountId) {
    return (select(transactionEntries)
          ..where((t) => t.accountId.equals(accountId)))
        .get();
  }

  Future<void> insertTransaction(TransactionEntriesCompanion entry) =>
      into(transactionEntries).insert(entry);

  Future<void> deleteTransactionById(String id) =>
      (delete(transactionEntries)..where((t) => t.id.equals(id))).go();

  // --- Goals ---

  Stream<List<Goal>> watchGoals() =>
      (select(goals)..orderBy([(g) => OrderingTerm.asc(g.createdAt)])).watch();

  Future<void> insertGoal(GoalsCompanion entry) => into(goals).insert(entry);

  Future<void> updateGoal(GoalsCompanion entry) =>
      (update(goals)..where((g) => g.id.equals(entry.id.value))).write(entry);

  Future<void> deleteGoalById(String id) =>
      (delete(goals)..where((g) => g.id.equals(id))).go();

  // --- Todo Lists ---

  Stream<List<TodoList>> watchTodoLists() =>
      (select(todoLists)..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
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
      (select(todoItems)..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
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
      (select(noteFolders)..orderBy([(f) => OrderingTerm.asc(f.createdAt)]))
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
      (select(notes)..orderBy([(n) => OrderingTerm.desc(n.updatedAt)])).watch();

  Future<void> insertNote(NotesCompanion entry) =>
      into(notes).insert(entry);

  Future<void> updateNote(NotesCompanion entry) =>
      (update(notes)..where((n) => n.id.equals(entry.id.value))).write(entry);

  Future<void> deleteNoteById(String id) =>
      (delete(notes)..where((n) => n.id.equals(id))).go();

  // --- Habits ---

  Stream<List<Habit>> watchHabits() =>
      (select(habits)..orderBy([
        (h) => OrderingTerm.asc(h.category),
        (h) => OrderingTerm.asc(h.sortOrder),
        (h) => OrderingTerm.asc(h.createdAt),
      ])).watch();

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
                l.date.isSmallerOrEqualValue(to)))
          .watch();

  Future<void> setHabitLog(HabitLogsCompanion entry) =>
      into(habitLogs).insertOnConflictUpdate(entry);

  Future<void> clearHabitLog(String habitId, DateTime date) =>
      (delete(habitLogs)
            ..where((l) =>
                l.habitId.equals(habitId) & l.date.equals(date)))
          .go();

  // --- Calendar Events ---

  Stream<List<CalendarEvent>> watchCalendarEvents() =>
      (select(calendarEvents)
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
