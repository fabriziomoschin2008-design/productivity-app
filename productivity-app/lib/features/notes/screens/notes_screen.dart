import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/note_editor_panel.dart';
import '../widgets/notes_folders_panel.dart';
import '../widgets/notes_list_panel.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: const Row(
        children: [
          NotesFoldersPanel(),
          VerticalDivider(width: 1),
          NotesListPanel(),
          VerticalDivider(width: 1),
          Expanded(child: NoteEditorPanel()),
        ],
      ),
    );
  }
}
