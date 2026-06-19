import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/calendar_providers.dart';
import '../state/calendar_state.dart';
import '../widgets/events_calendar_view.dart';
import '../widgets/habit_daily_view.dart';
import '../widgets/habit_monthly_view.dart';
import '../widgets/habit_weekly_view.dart';
import '../widgets/habits_side_panel.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: const Row(
        children: [
          HabitsSidePanel(),
          VerticalDivider(width: 1),
          Expanded(child: _CalendarMainArea()),
        ],
      ),
    );
  }
}

class _CalendarMainArea extends ConsumerWidget {
  const _CalendarMainArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);

    return Column(
      children: [
        _TabBar(activeTab: state.activeTab),
        const Divider(height: 1),
        Expanded(
          child: state.activeTab == CalendarTab.habits
              ? _HabitsArea(habitView: state.habitView)
              : const EventsCalendarView(),
        ),
      ],
    );
  }
}

class _TabBar extends ConsumerWidget {
  final CalendarTab activeTab;
  const _TabBar({required this.activeTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _TabButton(
            label: 'Abitudini',
            icon: Icons.repeat,
            active: activeTab == CalendarTab.habits,
            onTap: () => ref
                .read(calendarProvider.notifier)
                .setTab(CalendarTab.habits),
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'Calendario',
            icon: Icons.calendar_month,
            active: activeTab == CalendarTab.events,
            onTap: () => ref
                .read(calendarProvider.notifier)
                .setTab(CalendarTab.events),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: active ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: active ? AppColors.primary : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitsArea extends ConsumerWidget {
  final HabitView habitView;
  const _HabitsArea({required this.habitView});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Sub-toggle: Oggi / Settimana / Mese
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _ViewToggle(
                label: 'Oggi',
                active: habitView == HabitView.daily,
                onTap: () => ref
                    .read(calendarProvider.notifier)
                    .setHabitView(HabitView.daily),
              ),
              const SizedBox(width: 4),
              _ViewToggle(
                label: 'Settimana',
                active: habitView == HabitView.weekly,
                onTap: () => ref
                    .read(calendarProvider.notifier)
                    .setHabitView(HabitView.weekly),
              ),
              const SizedBox(width: 4),
              _ViewToggle(
                label: 'Mese',
                active: habitView == HabitView.monthly,
                onTap: () => ref
                    .read(calendarProvider.notifier)
                    .setHabitView(HabitView.monthly),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        const Expanded(child: _HabitViewContent()),
      ],
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ViewToggle({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: active ? Colors.white : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _HabitViewContent extends ConsumerWidget {
  const _HabitViewContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitView = ref.watch(calendarProvider.select((s) => s.habitView));
    return switch (habitView) {
      HabitView.daily => const HabitDailyView(),
      HabitView.weekly => const HabitWeeklyView(),
      HabitView.monthly => const HabitMonthlyView(),
    };
  }
}
