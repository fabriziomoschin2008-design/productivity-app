import 'package:flutter/material.dart';
import '../../../data/local/database.dart';

const kTodayViewId = '__today__';

class _Sentinel {
  const _Sentinel();
}

class TodoState {
  final List<TodoList> lists;
  final List<TodoItem> allItems;
  final String? selectedViewId; // null=Tutte, kTodayViewId=Oggi, uuid=lista
  final bool showCompleted;

  const TodoState({
    this.lists = const [],
    this.allItems = const [],
    this.selectedViewId,
    this.showCompleted = false,
  });

  // --- Vista corrente ---

  List<TodoItem> get visibleItems {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<TodoItem> filtered;

    if (selectedViewId == kTodayViewId) {
      filtered = allItems.where((t) {
        if (t.isDone && !showCompleted) return false;
        final due = t.dueDate;
        if (due == null) return false;
        return !DateTime(due.year, due.month, due.day).isAfter(today);
      }).toList();
    } else if (selectedViewId == null) {
      filtered = showCompleted
          ? List.from(allItems)
          : allItems.where((t) => !t.isDone).toList();
    } else {
      filtered = allItems.where((t) {
        if (t.listId != selectedViewId) return false;
        return showCompleted || !t.isDone;
      }).toList();
    }

    filtered.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      final aDate = a.dueDate ?? DateTime(9999);
      final bDate = b.dueDate ?? DateTime(9999);
      if (aDate != bDate) return aDate.compareTo(bDate);
      if (a.priority != b.priority) return b.priority.compareTo(a.priority);
      return a.createdAt.compareTo(b.createdAt);
    });

    return filtered;
  }

  // --- Conteggi ---

  int get allIncompleteCount => allItems.where((t) => !t.isDone).length;

  int get todayCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return allItems.where((t) {
      if (t.isDone) return false;
      final due = t.dueDate;
      if (due == null) return false;
      return !DateTime(due.year, due.month, due.day).isAfter(today);
    }).length;
  }

  int countForList(String listId) =>
      allItems.where((t) => t.listId == listId && !t.isDone).length;

  // --- Metadati vista ---

  String get selectedViewTitle {
    if (selectedViewId == null) return 'Tutte le attività';
    if (selectedViewId == kTodayViewId) return 'Oggi';
    return lists.where((l) => l.id == selectedViewId).firstOrNull?.name ?? '';
  }

  Color? get selectedViewColor {
    if (selectedViewId == null || selectedViewId == kTodayViewId) return null;
    final list = lists.where((l) => l.id == selectedViewId).firstOrNull;
    return list != null ? Color(list.colorValue) : null;
  }

  String? get defaultListIdForNewTask {
    if (selectedViewId == null || selectedViewId == kTodayViewId) return null;
    return selectedViewId;
  }

  TodoState copyWith({
    List<TodoList>? lists,
    List<TodoItem>? allItems,
    Object? selectedViewId = const _Sentinel(),
    bool? showCompleted,
  }) {
    return TodoState(
      lists: lists ?? this.lists,
      allItems: allItems ?? this.allItems,
      selectedViewId: selectedViewId is _Sentinel
          ? this.selectedViewId
          : selectedViewId as String?,
      showCompleted: showCompleted ?? this.showCompleted,
    );
  }
}
