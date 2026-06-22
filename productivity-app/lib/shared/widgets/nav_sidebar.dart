import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class NavSidebar extends StatelessWidget {
  const NavSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

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
          _NavItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Finanze',
            path: '/finance',
            active: location.startsWith('/finance'),
          ),
          _NavItem(
            icon: Icons.sticky_note_2_rounded,
            label: 'Note',
            path: '/notes',
            active: location.startsWith('/notes'),
          ),
          _NavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Calendario',
            path: '/calendar',
            active: location.startsWith('/calendar'),
          ),
          _NavItem(
            icon: Icons.check_circle_rounded,
            label: 'To-do',
            path: '/todo',
            active: location.startsWith('/todo'),
          ),
          _NavItem(
            icon: Icons.track_changes_rounded,
            label: 'Tracker',
            path: '/tracker',
            active: location.startsWith('/tracker'),
          ),
        ],
      ),
    );
  }
}

class _CubbyLogo extends StatelessWidget {
  const _CubbyLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
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
