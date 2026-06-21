import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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
  return showDialog(
    context: context,
    useRootNavigator: false,
    builder: (_) => _AddEventDialog(initialDate: initialDate),
  );
}

class _AddEventDialog extends ConsumerStatefulWidget {
  final DateTime initialDate;
  const _AddEventDialog({required this.initialDate});

  @override
  ConsumerState<_AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends ConsumerState<_AddEventDialog> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _selectedDate;
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _allDay = true;
  Color _selectedColor = _eventColors.first;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    // Round up to next quarter hour as default time
    final now = TimeOfDay.now();
    final minutes = ((now.minute ~/ 15) + 1) * 15;
    _selectedTime = TimeOfDay(hour: now.hour + minutes ~/ 60, minute: minutes % 60);
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
    if (picked != null) setState(() => _selectedDate = picked);
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
      title: const Text('Nuovo evento'),
      content: SizedBox(
        width: 360,
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
            // Date row
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: AppColors.textSecondary),
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
            // All-day toggle
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
            // Time picker — visible only when not all-day
            if (!_allDay) ...[
              const SizedBox(height: 4),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:'
                        '${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primary),
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
                final selected = c == _selectedColor;
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
          child: const Text('Aggiungi'),
        ),
      ],
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final startDate = _allDay
        ? _selectedDate
        : DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedTime.hour,
            _selectedTime.minute,
          );

    ref.read(calendarProvider.notifier).createEvent(
          title: title,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          startDate: startDate,
          allDay: _allDay,
          colorValue: _selectedColor.toARGB32(),
        );
    Navigator.of(context).pop();
  }
}
