import 'package:flutter/material.dart';
import '../../../core/layout/adaptive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/todo_lists_panel.dart';
import '../widgets/todo_tasks_panel.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (AdaptiveLayout.isCompact(context)) {
      return const ColoredBox(
        color: AppColors.background,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Liste'),
                  Tab(text: 'Attività'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [TodoListsPanel(), TodoTasksPanel()],
                ),
              ),
            ],
          ),
        ),
      );
    }

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
