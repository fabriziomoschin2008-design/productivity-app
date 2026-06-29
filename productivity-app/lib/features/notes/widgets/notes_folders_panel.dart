import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/layout/adaptive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../providers/notes_providers.dart';
import 'add_folder_dialog.dart';

class NotesFoldersPanel extends ConsumerWidget {
  const NotesFoldersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);
    final goalState = ref.watch(noteGoalsProvider);

    return SizedBox(
      width: AdaptiveLayout.sidePanelWidth(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
            child: Row(
              children: [
                Text('Note', style: AppTextStyles.headingCard),
                const Spacer(),
                IconButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const AddFolderDialog(),
                  ),
                  icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                  tooltip: 'Nuova cartella',
                  color: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                _SmartViewTile(
                  label: 'Tutte le note',
                  icon: Icons.notes_outlined,
                  count: state.allNotesCount,
                  selected:
                      state.selectedFolderId == null &&
                      goalState.selectedGoalId == null,
                  onTap: () {
                    ref.read(notesProvider.notifier).selectFolder(null);
                    ref.read(notesProvider.notifier).selectNote(null);
                    ref.read(noteGoalsProvider.notifier).selectGoal(null);
                  },
                ),
                if (state.folders.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: Text('CARTELLE', style: AppTextStyles.label),
                  ),
                  for (final folder in state.folders)
                    _FolderTile(
                      name: folder.name,
                      count: state.countForFolder(folder.id),
                      selected:
                          state.selectedFolderId == folder.id &&
                          goalState.selectedGoalId == null,
                      onTap: () {
                        ref
                            .read(notesProvider.notifier)
                            .selectFolder(folder.id);
                        ref.read(noteGoalsProvider.notifier).selectGoal(null);
                      },
                      onDelete: () =>
                          _confirmDelete(context, ref, folder.id, folder.name),
                    ),
                ],
                // ── Obiettivi ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
                  child: Row(
                    children: [
                      Text('OBIETTIVI', style: AppTextStyles.label),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          ref.read(noteGoalsProvider.notifier).createGoal();
                          ref.read(notesProvider.notifier).selectNote(null);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (goalState.goals.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Text(
                      'Nessun obiettivo',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ),
                for (final goal in goalState.goals)
                  _GoalTile(
                    goal: goal,
                    selected: goalState.selectedGoalId == goal.id,
                    onTap: () {
                      ref.read(noteGoalsProvider.notifier).selectGoal(goal.id);
                      ref.read(notesProvider.notifier).selectNote(null);
                    },
                    onDelete: () =>
                        _confirmDeleteGoal(context, ref, goal.id, goal.title),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        title: const Text('Elimina cartella'),
        content: Text(
          'Elimina "$name"? Le note al suo interno verranno spostate in "Tutte le note".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(notesProvider.notifier).deleteFolder(id);
  }

  Future<void> _confirmDeleteGoal(
    BuildContext context,
    WidgetRef ref,
    String id,
    String title,
  ) async {
    final displayTitle = title.isEmpty ? 'Senza titolo' : title;
    final ok = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        title: const Text('Elimina obiettivo'),
        content: Text(
          'Elimina "$displayTitle"? Questa azione è irreversibile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(noteGoalsProvider.notifier).deleteGoal(id);
  }
}

// ---------------------------------------------------------------------------

class _SmartViewTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _SmartViewTile({
    required this.label,
    required this.icon,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (count > 0)
              Text(
                '$count',
                style: AppTextStyles.label.copyWith(
                  color: selected ? AppColors.primary : AppColors.textDisabled,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  final String name;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FolderTile({
    required this.name,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.only(left: 12, right: 4, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.folder_outlined,
              size: 16,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count > 0)
              Text(
                '$count',
                style: AppTextStyles.label.copyWith(
                  color: selected ? AppColors.primary : AppColors.textDisabled,
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Elimina cartella'),
                ),
              ],
              icon: const Icon(Icons.more_horiz, size: 14),
              iconColor: AppColors.textDisabled,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final NoteGoal goal;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _GoalTile({
    required this.goal,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final dl = goal.deadline;
    final isOverdue = dl != null && dl.isBefore(DateTime.now());

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.only(left: 12, right: 4, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.flag_outlined,
              size: 16,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title.isEmpty ? 'Senza titolo' : goal.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: goal.title.isEmpty
                          ? AppColors.textDisabled
                          : (selected
                                ? AppColors.primary
                                : AppColors.textPrimary),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (dl != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _fmtDate(dl),
                      style: AppTextStyles.label.copyWith(
                        color: isOverdue
                            ? AppColors.expense
                            : AppColors.textDisabled,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Elimina obiettivo'),
                ),
              ],
              icon: const Icon(Icons.more_horiz, size: 14),
              iconColor: AppColors.textDisabled,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
