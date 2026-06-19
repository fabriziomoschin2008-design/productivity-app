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

@DriftDatabase(tables: [Accounts, TransactionEntries, Goals, TodoLists, TodoItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

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
}
