import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/finance/screens/finance_screen.dart';
import '../../features/notes/screens/notes_screen.dart';
import '../../features/todo/screens/todo_screen.dart';
import '../../features/tracker/screens/tracker_screen.dart';
import '../widgets/nav_sidebar.dart';

final appRouter = GoRouter(
  initialLocation: '/finance',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/finance',
          builder: (ctx, state) => const FinanceScreen(),
        ),
        GoRoute(
          path: '/notes',
          builder: (ctx, state) => const NotesScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (ctx, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/todo',
          builder: (ctx, state) => const TodoScreen(),
        ),
        GoRoute(
          path: '/tracker',
          builder: (ctx, state) => const TrackerScreen(),
        ),
      ],
    ),
  ],
);

class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const NavSidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
