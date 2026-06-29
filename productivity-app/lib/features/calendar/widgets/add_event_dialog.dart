import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/adaptive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../providers/calendar_providers.dart';

final _eventColors = [
  const Color(0xFF6C63FF),
  const Color(0xFF1E3A5F),
  const Color(0xFF1A7A45),
  const Color(0xFFD4821A),
  const Color(0xFFC0392B),
  const Color(0xFF0097A7),
];

Future<void> showAddEventDialog(BuildContext context, DateTime initialDate) {
  return showEventDialog(context, initialDate: initialDate);
}

Future<void> showEventDialog(
  BuildContext context, {
  required DateTime initialDate,
  CalendarEvent? existingEvent,
}) {
  return showDialog(
    context: context,
    useRootNavigator: false,
    builder: (_) =>
        _EventDialog(initialDate: initialDate, existingEvent: existingEvent),
  );
}

class _EventDialog extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final CalendarEvent? existingEvent;

  const _EventDialog({required this.initialDate, this.existingEvent});

  @override
  ConsumerState<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends ConsumerState<_EventDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _allDay;
  late Color _selectedColor;

  bool get _isEditing => widget.existingEvent != null;

  @override
  void initState() {
    super.initState();
    final event = widget.existingEvent;
    _titleController = TextEditingController(text: event?.title ?? '');
    _noteController = TextEditingController(text: event?.note ?? '');
    _selectedDate = event?.startDate ?? widget.initialDate;
    _allDay = event?.allDay ?? true;
    _selectedColor = Color(event?.colorValue ?? _eventColors.first.toARGB32());

    if (event != null && !event.allDay) {
      _selectedTime = TimeOfDay(
        hour: event.startDate.hour,
        minute: event.startDate.minute,
      );
    } else {
      final now = TimeOfDay.now();
      final totalMinutes = now.hour * 60 + now.minute;
      final roundedMinutes = ((totalMinutes / 15).ceil() * 15) % (24 * 60);
      _selectedTime = TimeOfDay(
        hour: roundedMinutes ~/ 60,
        minute: roundedMinutes % 60,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('it'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Modifica evento' : 'Nuovo evento'),
      content: SizedBox(
        width: AdaptiveLayout.dialogWidth(context, 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Titolo evento',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Nota (opzionale)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/'
                      '${_selectedDate.month.toString().padLeft(2, '0')}/'
                      '${_selectedDate.year}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Tutto il giorno', style: AppTextStyles.bodySmall),
                const Spacer(),
                Switch(
                  value: _allDay,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => _allDay = v),
                ),
              ],
            ),
            if (!_allDay) ...[
              const SizedBox(height: 4),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:'
                        '${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text('Colore', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _eventColors.map((c) {
                final selected = c.toARGB32() == _selectedColor.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: AppColors.textPrimary, width: 2)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Salva' : 'Aggiungi'),
        ),
      ],
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final startDate = _allDay
        ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
        : DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedTime.hour,
            _selectedTime.minute,
          );

    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    final notifier = ref.read(calendarProvider.notifier);
    if (_isEditing) {
      notifier.updateEvent(
        id: widget.existingEvent!.id,
        title: title,
        note: note,
        startDate: startDate,
        endDate: widget.existingEvent!.endDate,
        allDay: _allDay,
        colorValue: _selectedColor.toARGB32(),
      );
    } else {
      notifier.createEvent(
        title: title,
        note: note,
        startDate: startDate,
        allDay: _allDay,
        colorValue: _selectedColor.toARGB32(),
      );
    }
    Navigator.of(context).pop();
  }
}
