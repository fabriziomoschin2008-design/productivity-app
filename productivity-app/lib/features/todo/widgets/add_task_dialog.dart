import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/local/database.dart';
import '../providers/todo_providers.dart';

class AddTaskDialog extends ConsumerStatefulWidget {
  final String? defaultListId;
  final List<TodoList> lists;

  const AddTaskDialog({
    super.key,
    required this.defaultListId,
    required this.lists,
  });

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  late String? _selectedListId;
  int _priority = 0;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedListId = widget.defaultListId;
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
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        // se si rimuove la data, rimuove anche l'ora
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    DateTime? finalDueDate;
    bool hasDueTime = false;

    if (_dueDate != null) {
      if (_dueTime != null) {
        finalDueDate = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          _dueTime!.hour,
          _dueTime!.minute,
        );
        hasDueTime = true;
      } else {
        // Scade a mezzanotte del giorno indicato (fine giornata = 23:59:59)
        finalDueDate = DateTime(
            _dueDate!.year, _dueDate!.month, _dueDate!.day, 23, 59, 59);
      }
    }

    final note = _noteController.text.trim();
    setState(() => _saving = true);
    await ref.read(todoProvider.notifier).addTask(
          title: title,
          listId: _selectedListId,
          note: note.isEmpty ? null : note,
          priority: _priority,
          dueDate: finalDueDate,
          hasDueTime: hasDueTime,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 440,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nuova attività',
                  style: AppTextStyles.headingCard.copyWith(fontSize: 17)),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titolo'),
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 14),
              if (widget.lists.isNotEmpty)
                DropdownButtonFormField<String?>(
                  // ignore: deprecated_member_use
                  value: _selectedListId,
                  decoration: const InputDecoration(labelText: 'Lista'),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('Nessuna lista')),
                    ...widget.lists.map((l) => DropdownMenuItem<String?>(
                          value: l.id,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: Color(l.colorValue),
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(l.name),
                            ],
                          ),
                        )),
                  ],
                  onChanged: (v) => setState(() => _selectedListId = v),
                ),
              if (widget.lists.isNotEmpty) const SizedBox(height: 14),
              // Priorità
              Text('Priorità', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PriorityChip(
                      label: 'Nessuna',
                      color: AppColors.textDisabled,
                      selected: _priority == 0,
                      onTap: () => setState(() => _priority = 0)),
                  const SizedBox(width: 8),
                  _PriorityChip(
                      label: 'Bassa',
                      color: const Color(0xFF27AE60),
                      selected: _priority == 1,
                      onTap: () => setState(() => _priority = 1)),
                  const SizedBox(width: 8),
                  _PriorityChip(
                      label: 'Media',
                      color: AppColors.accent,
                      selected: _priority == 2,
                      onTap: () => setState(() => _priority = 2)),
                  const SizedBox(width: 8),
                  _PriorityChip(
                      label: 'Alta',
                      color: AppColors.expense,
                      selected: _priority == 3,
                      onTap: () => setState(() => _priority = 3)),
                ],
              ),
              const SizedBox(height: 14),
              // Data scadenza
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration:
                      const InputDecoration(labelText: 'Scadenza (opzionale)'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dueDate != null
                            ? formatDateMedium(_dueDate!)
                            : 'Nessuna scadenza',
                        style: AppTextStyles.bodyRegular.copyWith(
                          color: _dueDate != null
                              ? null
                              : AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_dueDate != null)
                            GestureDetector(
                              onTap: () => setState(() {
                                _dueDate = null;
                                _dueTime = null;
                              }),
                              child: const Icon(Icons.clear,
                                  size: 14,
                                  color: AppColors.textSecondary),
                            ),
                          const SizedBox(width: 4),
                          const Icon(Icons.calendar_today_outlined,
                              size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Ora specifica (visibile solo se data è selezionata)
              if (_dueDate != null) ...[
                const SizedBox(height: 10),
                InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration:
                        const InputDecoration(labelText: 'Ora specifica (opzionale)'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dueTime != null
                              ? _dueTime!.format(context)
                              : 'Scade a mezzanotte',
                          style: AppTextStyles.bodyRegular.copyWith(
                            color: _dueTime != null
                                ? null
                                : AppColors.textSecondary,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_dueTime != null)
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _dueTime = null),
                                child: const Icon(Icons.clear,
                                    size: 14,
                                    color: AppColors.textSecondary),
                              ),
                            const SizedBox(width: 4),
                            const Icon(Icons.schedule_outlined,
                                size: 16, color: AppColors.textSecondary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: _noteController,
                decoration:
                    const InputDecoration(labelText: 'Nota (opzionale)'),
                maxLines: 2,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: const Text('Aggiungi'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? color : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
