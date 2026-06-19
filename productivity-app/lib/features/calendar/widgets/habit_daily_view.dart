import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/calendar_providers.dart';
import '../state/calendar_state.dart';

class HabitDailyView extends ConsumerWidget {
  const HabitDailyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final habits = state.habits;
    final date = state.selectedDate;
    final isToday = date == state.today;

    return Column(
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => ref
                    .read(calendarProvider.notifier)
                    .selectDate(date.subtract(const Duration(days: 1))),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatDate(date, isToday),
                  style: AppTextStyles.headingCard.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => ref
                    .read(calendarProvider.notifier)
                    .selectDate(date.add(const Duration(days: 1))),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              if (!isToday) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => ref
                      .read(calendarProvider.notifier)
                      .selectDate(state.today),
                  child: const Text('Oggi'),
                ),
              ],
            ],
          ),
        ),
        if (habits.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: _CompletionBar(state: state, date: date),
          ),
        ],
        const Divider(height: 1),
        Expanded(
          child: habits.isEmpty
              ? const _EmptyHabitsHint()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: habits.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 72, endIndent: 24),
                  itemBuilder: (_, i) {
                    final h = habits[i];
                    final status = state.statusForHabit(h.id, date);
                    return _HabitRow(
                      habitId: h.id,
                      name: h.name,
                      category: h.category,
                      status: status,
                      date: date,
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date, bool isToday) {
    const weekdays = [
      'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì',
      'Venerdì', 'Sabato', 'Domenica',
    ];
    const months = [
      'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
      'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
    ];
    final prefix = isToday ? 'Oggi — ' : '';
    return '$prefix${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }
}

class _CompletionBar extends StatelessWidget {
  final CalendarState state;
  final DateTime date;
  const _CompletionBar({required this.state, required this.date});

  @override
  Widget build(BuildContext context) {
    final rate = state.completionRateForDate(date);
    final doneCount =
        state.habits.where((h) => state.statusForHabit(h.id, date) == 'done').length;
    final naCount =
        state.habits.where((h) => state.statusForHabit(h.id, date) == 'na').length;
    final total = state.habits.length;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: AppColors.border,
              color: AppColors.income,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$doneCount/${total - naCount}',
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _HabitRow extends ConsumerWidget {
  final String habitId;
  final String name;
  final String category;
  final String status;
  final DateTime date;

  const _HabitRow({
    required this.habitId,
    required this.name,
    required this.category,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              category,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textDisabled,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.bodySmall.copyWith(
                color: status == 'na'
                    ? AppColors.textDisabled
                    : AppColors.textPrimary,
                decoration:
                    status == 'skip' ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _StatusButtons(
            habitId: habitId,
            status: status,
            date: date,
          ),
        ],
      ),
    );
  }
}

class _StatusButtons extends ConsumerWidget {
  final String habitId;
  final String status;
  final DateTime date;

  const _StatusButtons({
    required this.habitId,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusBtn(
          label: 'Fatto',
          icon: Icons.check,
          active: status == 'done',
          activeColor: AppColors.income,
          onTap: () => ref
              .read(calendarProvider.notifier)
              .setHabitStatus(habitId, date, status == 'done' ? '' : 'done'),
        ),
        const SizedBox(width: 6),
        _StatusBtn(
          label: 'Salta',
          icon: Icons.remove,
          active: status == 'skip',
          activeColor: AppColors.textSecondary,
          onTap: () => ref
              .read(calendarProvider.notifier)
              .setHabitStatus(habitId, date, status == 'skip' ? '' : 'skip'),
        ),
        const SizedBox(width: 6),
        _StatusBtn(
          label: 'N/A',
          icon: Icons.block,
          active: status == 'na',
          activeColor: AppColors.textDisabled,
          onTap: () => ref
              .read(calendarProvider.notifier)
              .setHabitStatus(habitId, date, status == 'na' ? '' : 'na'),
        ),
      ],
    );
  }
}

class _StatusBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _StatusBtn({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: active
                ? activeColor.withValues(alpha: 0.12)
                : AppColors.surfaceElevated,
            border: Border.all(
              color: active ? activeColor : AppColors.border,
              width: active ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon,
              size: 14, color: active ? activeColor : AppColors.textDisabled),
        ),
      ),
    );
  }
}

class _EmptyHabitsHint extends StatelessWidget {
  const _EmptyHabitsHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.repeat_outlined, size: 40, color: AppColors.textDisabled),
          const SizedBox(height: 14),
          Text('Nessuna abitudine',
              style: AppTextStyles.bodyRegular
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Aggiungine una dalla sidebar', style: AppTextStyles.label),
        ],
      ),
    );
  }
}
