import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/notifications/notification_scheduler.dart';
import '../../../core/services/error_handler.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/local/database.dart';
import 'todo_state.dart';

class TodoNotifier extends StateNotifier<TodoState> {
  final AppDatabase _db;
  StreamSubscription<List<TodoList>>? _listsSub;
  StreamSubscription<List<TodoItem>>? _itemsSub;

  TodoNotifier(this._db) : super(const TodoState()) {
    _listsSub = _db.watchTodoLists().listen((lists) {
      state = state.copyWith(lists: lists);
    });
    _itemsSub = _db.watchTodoItems().listen((items) {
      state = state.copyWith(allItems: items);
      NotificationScheduler.instance.scheduleTodoMorningReminder(items);
    });
  }

  void selectView(String? viewId) {
    state = state.copyWith(selectedViewId: viewId);
  }

  void toggleShowCompleted() {
    state = state.copyWith(showCompleted: !state.showCompleted);
  }

  Future<void> addList({
    required String name,
    required int colorValue,
  }) async {
    try {
      AppLogger.instance.info('Lista todo aggiunta: $name');
      await _db.insertTodoList(TodoListsCompanion.insert(
        name: name,
        colorValue: colorValue,
      ));
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> deleteList(String listId) async {
    try {
      AppLogger.instance.info('Lista todo eliminata: id=$listId');
      if (state.selectedViewId == listId) {
        state = state.copyWith(selectedViewId: null);
      }
      await _db.deleteTodoListWithItems(listId);
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> addTask({
    required String title,
    String? listId,
    String? note,
    int priority = 0,
    DateTime? dueDate,
    bool hasDueTime = false,
  }) async {
    try {
      AppLogger.instance.info('Task aggiunto: "$title"');
      await _db.insertTodoItem(TodoItemsCompanion.insert(
        title: title,
        listId: Value(listId),
        note: Value(note),
        priority: Value(priority),
        dueDate: Value(dueDate),
        hasDueTime: Value(hasDueTime),
      ));
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> toggleTask(TodoItem item) async {
    try {
      final done = !item.isDone;
      AppLogger.instance
          .info('Task ${done ? 'completato' : 'riaperto'}: "${item.title}"');
      await _db.updateTodoItem(TodoItemsCompanion(
        id: Value(item.id),
        isDone: Value(done),
        completedAt: Value(done ? DateTime.now() : null),
      ));
    } catch (e, s) {
      AppErrorHandler.handle(e, s, showUi: false);
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      AppLogger.instance.info('Task eliminato: id=$id');
      await _db.deleteTodoItemById(id);
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  @override
  void dispose() {
    _listsSub?.cancel();
    _itemsSub?.cancel();
    super.dispose();
  }
}
