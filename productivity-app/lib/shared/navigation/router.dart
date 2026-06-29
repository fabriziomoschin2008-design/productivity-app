import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/layout/adaptive_layout.dart';
import '../../core/debug/debug_panel.dart';
import '../../core/debug/debug_provider.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/finance/screens/finance_screen.dart';
import '../../features/notes/screens/notes_screen.dart';
import '../../features/todo/screens/todo_screen.dart';
import '../../features/entertainment/screens/entertainment_screen.dart';
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
        GoRoute(path: '/notes', builder: (ctx, state) => const NotesScreen()),
        GoRoute(
          path: '/calendar',
          builder: (ctx, state) => const CalendarScreen(),
        ),
        GoRoute(path: '/todo', builder: (ctx, state) => const TodoScreen()),
        GoRoute(
          path: '/tracker',
          builder: (ctx, state) => const TrackerScreen(),
        ),
        GoRoute(
          path: '/entertainment',
          builder: (ctx, state) => const EntertainmentScreen(),
        ),
      ],
    ),
  ],
);

class _AppShell extends ConsumerWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debugMode = ref.watch(debugModeProvider);
    final location = GoRouterState.of(context).uri.path;
    final compact = AdaptiveLayout.isCompact(context);

    return Scaffold(
      bottomNavigationBar: compact ? MobileBottomNav(location: location) : null,
      body: Stack(
        children: [
          if (compact)
            SafeArea(bottom: false, child: child)
          else
            Row(
              children: [
                const NavSidebar(),
                Expanded(child: child),
              ],
            ),
          if (compact) const MobileAuthButton(),
          if (debugMode) const DebugPanel(),
        ],
      ),
    );
  }
}
