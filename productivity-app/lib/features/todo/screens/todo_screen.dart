import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/todo_lists_panel.dart';
import '../widgets/todo_tasks_panel.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: const Row(
        children: [
          TodoListsPanel(),
          VerticalDivider(width: 1),
          Expanded(child: TodoTasksPanel()),
        ],
      ),
    );
  }
}
