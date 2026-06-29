import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/layout/adaptive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/todo_providers.dart';

class AddListDialog extends ConsumerStatefulWidget {
  const AddListDialog({super.key});

  @override
  ConsumerState<AddListDialog> createState() => _AddListDialogState();
}

class _AddListDialogState extends ConsumerState<AddListDialog> {
  final _nameController = TextEditingController();
  int _selectedColorIndex = 0;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    await ref
        .read(todoProvider.notifier)
        .addList(
          name: name,
          colorValue: AppColors.accountColors[_selectedColorIndex].toARGB32(),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: AdaptiveLayout.dialogWidth(context, 360),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nuova lista',
                style: AppTextStyles.headingCard.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome lista'),
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 20),
              Text('Colore', style: AppTextStyles.label),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: List.generate(AppColors.accountColors.length, (i) {
                  final color = AppColors.accountColors[i];
                  final selected = i == _selectedColorIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(
                                color: AppColors.textPrimary,
                                width: 2.5,
                              )
                            : null,
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annulla'),
                  ),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: const Text('Crea lista'),
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
