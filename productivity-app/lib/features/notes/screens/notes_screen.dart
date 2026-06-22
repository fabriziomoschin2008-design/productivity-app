import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/notes_providers.dart';
import '../widgets/goal_editor_panel.dart';
import '../widgets/note_editor_panel.dart';
import '../widgets/notes_folders_panel.dart';
import '../widgets/notes_list_panel.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.background,
      child: Row(
        children: [
          NotesFoldersPanel(),
          VerticalDivider(width: 1),
          NotesListPanel(),
          VerticalDivider(width: 1),
          Expanded(child: _ActiveEditorPanel()),
        ],
      ),
    );
  }
}

class _ActiveEditorPanel extends ConsumerWidget {
  const _ActiveEditorPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGoal =
        ref.watch(noteGoalsProvider.select((s) => s.selectedGoal));
    if (selectedGoal != null) {
      return GoalEditorPanel(
          key: ValueKey(selectedGoal.id), goal: selectedGoal);
    }
    return const NoteEditorPanel();
  }
}
