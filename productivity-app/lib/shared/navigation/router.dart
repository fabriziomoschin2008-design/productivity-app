import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/finance/screens/finance_screen.dart';
import '../../features/todo/screens/todo_screen.dart';
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
          builder: (ctx, state) => const _PlaceholderScreen(title: 'Note'),
        ),
        GoRoute(
          path: '/calendar',
          builder: (ctx, state) => const _PlaceholderScreen(title: 'Calendario'),
        ),
        GoRoute(
          path: '/todo',
          builder: (ctx, state) => const TodoScreen(),
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
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title — in arrivo',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey,
            ),
      ),
    );
  }
}
