import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../providers/calendar_providers.dart';
import 'add_event_dialog.dart';

class EventsCalendarView extends ConsumerWidget {
  const EventsCalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final selectedEvents = state.eventsForDate(state.selectedDate);

    return Column(
      children: [
        TableCalendar<CalendarEvent>(
          locale: 'it_IT',
          firstDay: DateTime(2020),
          lastDay: DateTime(2100),
          focusedDay: state.focusedMonth,
          selectedDayPredicate: (d) => isSameDay(d, state.selectedDate),
          onDaySelected: (selected, focused) =>
              ref.read(calendarProvider.notifier).selectDate(selected),
          onPageChanged: (focusedDay) =>
              ref.read(calendarProvider.notifier).setFocusedMonth(focusedDay),
          eventLoader: (day) => state.eventsForDate(day),
          calendarFormat: CalendarFormat.month,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: AppTextStyles.headingCard.copyWith(fontSize: 14),
            leftChevronIcon: const Icon(Icons.chevron_left, size: 20),
            rightChevronIcon: const Icon(Icons.chevron_right, size: 20),
          ),
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            todayTextStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
            ),
            defaultTextStyle: AppTextStyles.bodySmall,
            weekendTextStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            outsideTextStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textDisabled,
            ),
            markerDecoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            markerSize: 5,
            markersMaxCount: 3,
          ),
        ),
        const Divider(height: 1),
        // Bottone aggiungi evento
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Text(
                _formatDate(state.selectedDate),
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 28,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      showAddEventDialog(context, state.selectedDate),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Evento'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    textStyle: AppTextStyles.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: selectedEvents.isEmpty
              ? const _NoEvents()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: selectedEvents.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (_, i) => _EventTile(event: selectedEvents[i]),
                ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'gennaio',
      'febbraio',
      'marzo',
      'aprile',
      'maggio',
      'giugno',
      'luglio',
      'agosto',
      'settembre',
      'ottobre',
      'novembre',
      'dicembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _EventTile extends ConsumerWidget {
  final CalendarEvent event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(event.colorValue);
    return ListTile(
      dense: true,
      leading: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text(event.title, style: AppTextStyles.bodySmall),
      subtitle: event.note != null && event.note!.isNotEmpty
          ? Text(
              event.note!,
              style: AppTextStyles.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: () => showEventDialog(
        context,
        initialDate: event.startDate,
        existingEvent: event,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 16),
        color: AppColors.textDisabled,
        onPressed: () =>
            ref.read(calendarProvider.notifier).deleteEvent(event.id),
        tooltip: 'Elimina',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}

class _NoEvents extends StatelessWidget {
  const _NoEvents();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_available_outlined,
            size: 36,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 10),
          Text(
            'Nessun evento',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
