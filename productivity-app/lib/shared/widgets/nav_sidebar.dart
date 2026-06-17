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
      width: 68,
      color: AppColors.navBackground,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _Logo(),
          const SizedBox(height: 32),
          _NavItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Finanze',
            path: '/finance',
            active: location.startsWith('/finance'),
          ),
          _NavItem(
            icon: Icons.sticky_note_2_outlined,
            label: 'Note',
            path: '/notes',
            active: location.startsWith('/notes'),
          ),
          _NavItem(
            icon: Icons.calendar_month_outlined,
            label: 'Calendario',
            path: '/calendar',
            active: location.startsWith('/calendar'),
          ),
          _NavItem(
            icon: Icons.check_box_outlined,
            label: 'To-do',
            path: '/todo',
            active: location.startsWith('/todo'),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 20),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 68,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: active
                ? const Border(
                    left: BorderSide(color: AppColors.navAccentLine, width: 3))
                : const Border(
                    left: BorderSide(color: Colors.transparent, width: 3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: active
                    ? AppColors.navItemSelected
                    : AppColors.navItem,
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
    );
  }
}
