import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/calendar_providers.dart';
import '../state/calendar_state.dart';

class HabitWeeklyView extends ConsumerWidget {
  const HabitWeeklyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final selected = state.selectedDate;

    // Lunedì della settimana corrente
    final monday = selected.subtract(Duration(days: selected.weekday - 1));
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));

    return Column(
      children: [
        // Navigazione settimana
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => ref
                    .read(calendarProvider.notifier)
                    .selectDate(monday.subtract(const Duration(days: 7))),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: Text(
                  _weekLabel(monday),
                  style: AppTextStyles.headingCard.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => ref
                    .read(calendarProvider.notifier)
                    .selectDate(monday.add(const Duration(days: 7))),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: state.habits.isEmpty
              ? const _EmptyHabitsHint()
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _WeekGrid(state: state, days: days),
                  ),
                ),
        ),
      ],
    );
  }

  String _weekLabel(DateTime monday) {
    const months = [
      'gen', 'feb', 'mar', 'apr', 'mag', 'giu',
      'lug', 'ago', 'set', 'ott', 'nov', 'dic'
    ];
    final sunday = monday.add(const Duration(days: 6));
    if (monday.month == sunday.month) {
      return '${monday.day} – ${sunday.day} ${months[monday.month - 1]} ${monday.year}';
    }
    return '${monday.day} ${months[monday.month - 1]} – ${sunday.day} ${months[sunday.month - 1]} ${monday.year}';
  }
}

class _WeekGrid extends StatelessWidget {
  final CalendarState state;
  final List<DateTime> days;

  const _WeekGrid({required this.state, required this.days});

  static const _nameWidth = 160.0;
  static const _cellWidth = 64.0;
  static const _rowHeight = 44.0;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder(
        horizontalInside: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      children: [
        // Header row
        TableRow(
          decoration: const BoxDecoration(color: AppColors.surfaceElevated),
          children: [
            SizedBox(
              width: _nameWidth,
              height: 36,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(''),
                ),
              ),
            ),
            for (int i = 0; i < 7; i++)
              SizedBox(
                width: _cellWidth,
                height: 36,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekdays[i],
                        style: AppTextStyles.label.copyWith(
                          color: days[i] == todayDay
                              ? AppColors.primary
                              : AppColors.textDisabled,
                          fontWeight: days[i] == todayDay
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        '${days[i].day}',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 11,
                          color: days[i] == todayDay
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        // Habit rows
        for (final habit in state.habits)
          TableRow(
            children: [
              SizedBox(
                width: _nameWidth,
                height: _rowHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      habit.name,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              for (final day in days)
                _WeekCell(
                  habitId: habit.id,
                  date: day,
                  status: state.statusForHabit(habit.id, day),
                ),
            ],
          ),
        // Footer: completion %
        TableRow(
          decoration: const BoxDecoration(color: AppColors.surfaceElevated),
          children: [
            SizedBox(
              width: _nameWidth,
              height: 32,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Completamento',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.textDisabled),
                  ),
                ),
              ),
            ),
            for (final day in days)
              SizedBox(
                width: _cellWidth,
                height: 32,
                child: Center(
                  child: Text(
                    '${(state.completionRateForDate(day) * 100).round()}%',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _WeekCell extends ConsumerWidget {
  final String habitId;
  final DateTime date;
  final String status;

  const _WeekCell({
    required this.habitId,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 64,
      height: 44,
      child: InkWell(
        onTap: () =>
            ref.read(calendarProvider.notifier).logHabit(habitId, date),
        child: Center(child: _StatusIcon(status: status)),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final String status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      'done' => const Icon(Icons.check_circle, size: 20, color: AppColors.income),
      'skip' => const Icon(Icons.remove_circle_outline,
          size: 20, color: AppColors.textDisabled),
      'na' => Text('N/A',
          style: AppTextStyles.label.copyWith(color: AppColors.textDisabled)),
      _ => const Icon(Icons.circle_outlined, size: 16, color: AppColors.border),
    };
  }
}

class _EmptyHabitsHint extends StatelessWidget {
  const _EmptyHabitsHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Aggiungi abitudini dalla sidebar',
        style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
