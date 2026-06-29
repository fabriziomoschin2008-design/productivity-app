import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/layout/adaptive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/local/database.dart';
import '../providers/todo_providers.dart';
import 'add_task_dialog.dart';

class TodoTasksPanel extends ConsumerWidget {
  const TodoTasksPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todoProvider);
    final items = state.visibleItems;

    return Column(
      children: [
        _Header(
          title: state.selectedViewTitle,
          titleColor: state.selectedViewColor,
          showCompleted: state.showCompleted,
          onToggleCompleted: () =>
              ref.read(todoProvider.notifier).toggleShowCompleted(),
          onAddTask: () => showDialog(
            context: context,
            builder: (_) => AddTaskDialog(
              defaultListId: state.defaultListIdForNewTask,
              lists: state.lists,
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: items.isEmpty
              ? const _EmptyTasks()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const Divider(indent: 60, endIndent: 20),
                  itemBuilder: (_, i) => _TaskTile(
                    task: items[i],
                    onToggle: () =>
                        ref.read(todoProvider.notifier).toggleTask(items[i]),
                    onDelete: () =>
                        ref.read(todoProvider.notifier).deleteTask(items[i].id),
                  ),
                ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final bool showCompleted;
  final VoidCallback onToggleCompleted;
  final VoidCallback onAddTask;

  const _Header({
    required this.title,
    required this.titleColor,
    required this.showCompleted,
    required this.onToggleCompleted,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final compact = AdaptiveLayout.isPhone(context);
    final titleWidget = Text(
      title,
      style: AppTextStyles.headingCard.copyWith(
        fontSize: 20,
        color: titleColor ?? AppColors.textPrimary,
      ),
    );

    final toggleButton = TextButton.icon(
      onPressed: onToggleCompleted,
      icon: Icon(
        showCompleted
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        size: 15,
      ),
      label: Text(
        showCompleted ? 'Nascondi' : 'Completati',
        style: const TextStyle(fontSize: 12),
      ),
      style: TextButton.styleFrom(
        foregroundColor: showCompleted
            ? AppColors.accent
            : AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    final addButton = ElevatedButton.icon(
      onPressed: onAddTask,
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Attività'),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 20, 16, 16),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleWidget,
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [toggleButton, addButton],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: titleWidget),
                toggleButton,
                const SizedBox(width: 8),
                addButton,
              ],
            ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TodoItem task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.isDone;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(top: 2),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? AppColors.income : Colors.transparent,
                border: Border.all(
                  color: isDone ? AppColors.income : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 11, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTextStyles.bodyRegular.copyWith(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone
                        ? AppColors.textDisabled
                        : AppColors.textPrimary,
                  ),
                ),
                if (task.note != null && task.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.note!,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (task.dueDate != null || task.priority > 0) ...[
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (task.priority > 0)
                        _PriorityDot(priority: task.priority),
                      if (task.dueDate != null)
                        _DueDateBadge(
                          dueDate: task.dueDate!,
                          hasDueTime: task.hasDueTime,
                          isDone: isDone,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 16),
            color: AppColors.textDisabled,
            tooltip: 'Elimina',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final int priority;
  const _PriorityDot({required this.priority});

  static const _colors = {
    1: Color(0xFF27AE60),
    2: AppColors.accent,
    3: AppColors.expense,
  };
  static const _labels = {1: 'Bassa', 2: 'Media', 3: 'Alta'};

  @override
  Widget build(BuildContext context) {
    final color = _colors[priority] ?? AppColors.textDisabled;
    final label = _labels[priority] ?? '';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.label.copyWith(color: color)),
      ],
    );
  }
}

class _DueDateBadge extends StatelessWidget {
  final DateTime dueDate;
  final bool hasDueTime;
  final bool isDone;

  const _DueDateBadge({
    required this.dueDate,
    required this.hasDueTime,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    Color color;
    String label;

    final timeStr = hasDueTime ? ' · ${formatTime(dueDate)}' : '';

    if (isDone) {
      color = AppColors.textDisabled;
      label = '${formatDateShort(dueDate)}$timeStr';
    } else if (hasDueTime ? dueDate.isBefore(now) : dueDay.isBefore(today)) {
      color = AppColors.expense;
      label = 'Scaduto · ${formatDateShort(dueDate)}$timeStr';
    } else if (dueDay == today) {
      color = AppColors.accent;
      label = hasDueTime ? 'Oggi$timeStr' : 'Oggi';
    } else {
      color = AppColors.textSecondary;
      label = '${formatDateShort(dueDate)}$timeStr';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_outlined, size: 11, color: color),
        const SizedBox(width: 3),
        Text(label, style: AppTextStyles.label.copyWith(color: color)),
      ],
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 40,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 14),
          Text(
            'Nessuna attività',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Usa "Attività" per aggiungerne una',
            style: AppTextStyles.label,
          ),
        ],
      ),
    );
  }
}
