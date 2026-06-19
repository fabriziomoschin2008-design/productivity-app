import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/calendar_providers.dart';

const _categories = ['Mattina', 'Pomeriggio', 'Sera'];

Future<void> showAddHabitDialog(BuildContext context) async {
  return showDialog(context: context, builder: (_) => const _AddHabitDialog());
}

class _AddHabitDialog extends ConsumerStatefulWidget {
  const _AddHabitDialog();

  @override
  ConsumerState<_AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends ConsumerState<_AddHabitDialog> {
  final _nameController = TextEditingController();
  String _selectedCategory = 'Mattina';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuova abitudine'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nome abitudine',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          Text('Categoria', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _categories.map((cat) {
              final selected = cat == _selectedCategory;
              return ChoiceChip(
                label: Text(cat),
                selected: selected,
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (_) => setState(() => _selectedCategory = cat),
              );
            }).toList(),
          ),
        ],
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
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    ref.read(calendarProvider.notifier).createHabit(name, _selectedCategory);
    Navigator.of(context).pop();
  }
}
