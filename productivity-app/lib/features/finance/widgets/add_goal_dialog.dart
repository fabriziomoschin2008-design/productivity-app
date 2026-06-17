import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/finance_providers.dart';

class AddGoalDialog extends ConsumerStatefulWidget {
  const AddGoalDialog({super.key});

  @override
  ConsumerState<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends ConsumerState<AddGoalDialog> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  DateTime? _deadline;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final target =
        double.tryParse(_targetController.text.replaceAll(',', '.'));
    if (name.isEmpty || target == null || target <= 0) return;

    final current =
        double.tryParse(_currentController.text.replaceAll(',', '.')) ?? 0.0;
    final note = _noteController.text.trim();

    setState(() => _saving = true);
    await ref.read(goalsProvider.notifier).addGoal(
          name: name,
          targetAmount: target,
          currentAmount: current,
          deadline: _deadline,
          note: note.isEmpty ? null : note,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nuovo obiettivo',
                  style: AppTextStyles.headingCard.copyWith(fontSize: 17)),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'Nome obiettivo'),
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _targetController,
                decoration: const InputDecoration(
                  labelText: 'Importo obiettivo',
                  prefixText: '€ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _currentController,
                decoration: const InputDecoration(
                  labelText: 'Importo già risparmiato (opzionale)',
                  prefixText: '€ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickDeadline,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration:
                      const InputDecoration(labelText: 'Scadenza (opzionale)'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _deadline != null
                            ? formatDateMedium(_deadline!)
                            : 'Nessuna scadenza',
                        style: AppTextStyles.bodyRegular.copyWith(
                          color: _deadline != null
                              ? null
                              : AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_deadline != null)
                            GestureDetector(
                              onTap: () => setState(() => _deadline = null),
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
                    child: const Text('Crea obiettivo'),
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
