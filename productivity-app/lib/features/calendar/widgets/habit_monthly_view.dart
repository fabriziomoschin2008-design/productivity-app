import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/calendar_providers.dart';
import '../state/calendar_state.dart';

class HabitMonthlyView extends ConsumerWidget {
  const HabitMonthlyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final month = state.focusedMonth;
    final daysInMonth =
        DateUtils.getDaysInMonth(month.year, month.month);

    const months = [
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre',
    ];

    return Column(
      children: [
        // Navigazione mese
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () =>
                    ref.read(calendarProvider.notifier).navigateMonth(-1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: Text(
                  '${months[month.month - 1]} ${month.year}',
                  style: AppTextStyles.headingCard.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () =>
                    ref.read(calendarProvider.notifier).navigateMonth(1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: state.habits.isEmpty
              ? const _EmptyHint()
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _MonthGrid(
                      state: state,
                      month: month,
                      daysInMonth: daysInMonth,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final CalendarState state;
  final DateTime month;
  final int daysInMonth;

  const _MonthGrid({
    required this.state,
    required this.month,
    required this.daysInMonth,
  });

  static const _nameWidth = 160.0;
  static const _cellWidth = 34.0;
  static const _rowHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    final days = List.generate(
      daysInMonth,
      (i) => DateTime(month.year, month.month, i + 1),
    );

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder(
        horizontalInside:
            BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        verticalInside:
            BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
        bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      children: [
        // Header: numeri dei giorni
        TableRow(
          decoration: const BoxDecoration(color: AppColors.surfaceElevated),
          children: [
            SizedBox(
              width: _nameWidth,
              height: 32,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(''),
                ),
              ),
            ),
            for (final day in days)
              SizedBox(
                width: _cellWidth,
                height: 32,
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 10,
                      color: day == todayDay
                          ? AppColors.primary
                          : AppColors.textDisabled,
                      fontWeight: day == todayDay
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
          ],
        ),
        // Righe abitudini
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
                _MonthCell(
                  habitId: habit.id,
                  date: day,
                  status: state.statusForHabit(habit.id, day),
                ),
            ],
          ),
        // Footer: % completamento
        TableRow(
          decoration: const BoxDecoration(color: AppColors.surfaceElevated),
          children: [
            SizedBox(
              width: _nameWidth,
              height: 32,
              child: const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('%',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textDisabled)),
                ),
              ),
            ),
            for (final day in days)
              SizedBox(
                width: _cellWidth,
                height: 32,
                child: Center(
                  child: Text(
                    '${(state.completionRateForDate(day) * 100).round()}',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 9,
                      color: AppColors.textSecondary,
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

class _MonthCell extends ConsumerWidget {
  final String habitId;
  final DateTime date;
  final String status;

  const _MonthCell({
    required this.habitId,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 34,
      height: 40,
      child: InkWell(
        onTap: () =>
            ref.read(calendarProvider.notifier).logHabit(habitId, date),
        child: Center(child: _CellIcon(status: status)),
      ),
    );
  }
}

class _CellIcon extends StatelessWidget {
  final String status;
  const _CellIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      'done' => const Icon(Icons.check, size: 14, color: AppColors.income),
      'skip' => const Icon(Icons.remove, size: 14, color: AppColors.textDisabled),
      'na' => Text(
          'N/A',
          style: AppTextStyles.label
              .copyWith(fontSize: 8, color: AppColors.textDisabled),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

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
