import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../providers/todo_providers.dart';
import '../state/todo_state.dart';
import 'add_list_dialog.dart';

class TodoListsPanel extends ConsumerWidget {
  const TodoListsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todoProvider);

    return Container(
      width: 272,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Smart views
          _SmartViewTile(
            icon: Icons.inbox_outlined,
            label: 'Tutte',
            count: state.allIncompleteCount,
            selected: state.selectedViewId == null,
            onTap: () => ref.read(todoProvider.notifier).selectView(null),
          ),
          _SmartViewTile(
            icon: Icons.today_outlined,
            label: 'Oggi',
            count: state.todayCount,
            selected: state.selectedViewId == kTodayViewId,
            onTap: () =>
                ref.read(todoProvider.notifier).selectView(kTodayViewId),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 4),
          _ListsHeader(
            onAdd: () => showDialog(
              context: context,
              builder: (_) => const AddListDialog(),
            ),
          ),
          Expanded(
            child: state.lists.isEmpty
                ? _EmptyLists()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: state.lists.length,
                    itemBuilder: (_, i) {
                      final list = state.lists[i];
                      return _ListTile(
                        list: list,
                        count: state.countForList(list.id),
                        selected: state.selectedViewId == list.id,
                        onTap: () => ref
                            .read(todoProvider.notifier)
                            .selectView(list.id),
                        onDelete: () =>
                            _confirmDelete(context, ref, list),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, TodoList list) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina lista'),
        content: Text(
            'Eliminare "${list.name}" e tutte le sue attività?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(todoProvider.notifier).deleteList(list.id);
            },
            child: Text('Elimina',
                style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }
}

class _SmartViewTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _SmartViewTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: selected
                    ? AppColors.accent
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(icon,
                  size: 17,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyRegular.copyWith(
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              if (count > 0)
                Text(
                  '$count',
                  style: AppTextStyles.label.copyWith(
                    color: selected
                        ? AppColors.accent
                        : AppColors.textDisabled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListsHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _ListsHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 6),
      child: Row(
        children: [
          Text('LISTE', style: AppTextStyles.headingSection),
          const Spacer(),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            color: AppColors.primary,
            tooltip: 'Nuova lista',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final TodoList list;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ListTile({
    required this.list,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(list.colorValue);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: selected ? AppColors.accent : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  list.name,
                  style: AppTextStyles.bodyRegular.copyWith(
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count > 0)
                Text(
                  '$count',
                  style: AppTextStyles.label.copyWith(
                    color: selected
                        ? AppColors.accent
                        : AppColors.textDisabled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'delete', child: Text('Elimina')),
                ],
                icon: const Icon(Icons.more_vert,
                    size: 16, color: AppColors.textDisabled),
                padding: EdgeInsets.zero,
                splashRadius: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyLists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.playlist_add,
                size: 32, color: AppColors.textDisabled),
            const SizedBox(height: 10),
            Text('Nessuna lista', style: AppTextStyles.bodySmall),
            const SizedBox(height: 4),
            Text('Usa + per aggiungerne una',
                style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}
