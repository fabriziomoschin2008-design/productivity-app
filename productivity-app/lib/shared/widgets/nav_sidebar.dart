import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/debug/debug_provider.dart';
import '../../core/services/error_handler.dart';
import '../../core/services/sync_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth_dialog.dart';

class AppNavDestination {
  final IconData icon;
  final String label;
  final String mobileLabel;
  final String path;

  const AppNavDestination({
    required this.icon,
    required this.label,
    required this.mobileLabel,
    required this.path,
  });
}

const appNavDestinations = <AppNavDestination>[
  AppNavDestination(
    icon: Icons.account_balance_wallet_rounded,
    label: 'Finanze',
    mobileLabel: 'Conti',
    path: '/finance',
  ),
  AppNavDestination(
    icon: Icons.sticky_note_2_rounded,
    label: 'Note',
    mobileLabel: 'Note',
    path: '/notes',
  ),
  AppNavDestination(
    icon: Icons.calendar_month_rounded,
    label: 'Calendario',
    mobileLabel: 'Agenda',
    path: '/calendar',
  ),
  AppNavDestination(
    icon: Icons.check_circle_rounded,
    label: 'To-do',
    mobileLabel: 'To-do',
    path: '/todo',
  ),
  AppNavDestination(
    icon: Icons.track_changes_rounded,
    label: 'Tracker',
    mobileLabel: 'Track',
    path: '/tracker',
  ),
  AppNavDestination(
    icon: Icons.movie_rounded,
    label: 'Media',
    mobileLabel: 'Media',
    path: '/entertainment',
  ),
];

Future<void> handleAuthTap(BuildContext context, User? user) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final syncWorker = container.read(syncWorkerProvider);
  if (user == null) {
    await showDialog<bool>(
      context: context,
      builder: (_) => const AuthDialog(),
    );
    return;
  }

  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Disconnetti'),
      content: Text('Vuoi uscire da ${user.email ?? 'questo account'}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Esci'),
        ),
      ],
    ),
  );
  if (confirm != true || !context.mounted) return;
  try {
    final userId = user.id;
    await Supabase.instance.client.auth.signOut();
    await syncWorker.clearLocalSyncedData(userId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disconnessione effettuata'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (e, s) {
    AppErrorHandler.handle(e, s);
  }
}

class NavSidebar extends ConsumerWidget {
  const NavSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final authUser = ref.watch(authUserProvider).valueOrNull;

    return Container(
      width: 84,
      decoration: const BoxDecoration(
        color: AppColors.navBackground,
        boxShadow: [
          BoxShadow(
            color: Color(0x142D2A26),
            blurRadius: 20,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 18),
          const _CubbyLogo(),
          const SizedBox(height: 28),
          for (final destination in appNavDestinations)
            _NavItem(
              icon: destination.icon,
              label: destination.label,
              path: destination.path,
              active: location.startsWith(destination.path),
            ),
          const Spacer(),
          _AuthNavItem(user: authUser),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AuthNavItem extends StatelessWidget {
  final User? user;

  const _AuthNavItem({required this.user});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = user != null;
    final label = isLoggedIn ? 'Cloud' : 'Accedi';
    final icon = isLoggedIn ? Icons.cloud_done_rounded : Icons.login_rounded;

    return Tooltip(
      message: isLoggedIn
          ? (user!.email ?? 'Sessione attiva')
          : 'Accedi per attivare il sync',
      preferBelow: false,
      child: GestureDetector(
        onTap: () => handleAuthTap(context, user),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isLoggedIn
                  ? AppColors.income.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isLoggedIn ? AppColors.income : AppColors.navItem,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppTextStyles.navLabel.copyWith(
                    color: isLoggedIn ? AppColors.income : AppColors.navItem,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MobileAuthButton extends ConsumerWidget {
  const MobileAuthButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider).valueOrNull;
    final isLoggedIn = user != null;
    final syncWorker = ref.read(syncWorkerProvider);
    final compact = MediaQuery.sizeOf(context).width < 600;
    final bottomInset = compact ? 74.0 : 82.0;

    return SafeArea(
      minimum: EdgeInsets.only(right: 12, bottom: bottomInset),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isLoggedIn) ...[
              FloatingActionButton.extended(
                heroTag: 'mobile_sync_button',
                onPressed: () async {
                  await syncWorker.refreshNow(fullResync: true);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Refresh cloud completato'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.sync_rounded, size: 18),
                label: const Text('Sync'),
                extendedPadding: const EdgeInsets.symmetric(horizontal: 14),
                extendedIconLabelSpacing: 8,
              ),
              const SizedBox(height: 10),
            ],
            FloatingActionButton.extended(
              heroTag: 'mobile_auth_button',
              onPressed: () => handleAuthTap(context, user),
              backgroundColor: isLoggedIn
                  ? AppColors.income
                  : AppColors.primary,
              foregroundColor: Colors.white,
              icon: Icon(
                isLoggedIn ? Icons.cloud_done_rounded : Icons.login_rounded,
                size: 18,
              ),
              label: Text(isLoggedIn ? 'Cloud' : 'Accedi'),
              extendedPadding: const EdgeInsets.symmetric(horizontal: 14),
              extendedIconLabelSpacing: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class MobileBottomNav extends StatelessWidget {
  final String location;

  const MobileBottomNav({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final currentIndex = appNavDestinations.indexWhere(
      (destination) => location.startsWith(destination.path),
    );
    final compact = MediaQuery.sizeOf(context).width < 600;
    return NavigationBar(
      selectedIndex: currentIndex < 0 ? 0 : currentIndex,
      onDestinationSelected: (index) =>
          context.go(appNavDestinations[index].path),
      height: compact ? 66 : 70,
      labelBehavior: compact
          ? NavigationDestinationLabelBehavior.onlyShowSelected
          : NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        for (final destination in appNavDestinations)
          NavigationDestination(
            icon: Icon(destination.icon),
            label: compact ? destination.mobileLabel : destination.label,
          ),
      ],
    );
  }
}

class _CubbyLogo extends ConsumerWidget {
  const _CubbyLogo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onDoubleTap: () {}, // intercetta doppio tap per non triggerare triple
      onLongPress: () {
        final notifier = ref.read(debugModeProvider.notifier);
        notifier.state = !notifier.state;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              notifier.state ? 'Debug mode attivo' : 'Debug mode disattivo',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      preferBelow: false,
      child: GestureDetector(
        onTap: () => context.go(path),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    icon,
                    key: ValueKey(active),
                    size: 22,
                    color: active
                        ? AppColors.navItemSelected
                        : AppColors.navItem,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppTextStyles.navLabel.copyWith(
                    color: active
                        ? AppColors.navItemSelected
                        : AppColors.navItem,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
