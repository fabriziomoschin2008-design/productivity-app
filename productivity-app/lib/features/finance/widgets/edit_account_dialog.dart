import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/layout/adaptive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../providers/finance_providers.dart';

class EditAccountDialog extends ConsumerStatefulWidget {
  final Account account;
  const EditAccountDialog({super.key, required this.account});

  @override
  ConsumerState<EditAccountDialog> createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends ConsumerState<EditAccountDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late int _selectedColorIndex;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _balanceController = TextEditingController(
      text: widget.account.openingBalance
          .toStringAsFixed(2)
          .replaceAll('.', ','),
    );
    _selectedColorIndex = AppColors.accountColors.indexWhere(
      (c) => c.toARGB32() == widget.account.colorValue,
    );
    if (_selectedColorIndex < 0) _selectedColorIndex = 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final balance =
        double.tryParse(_balanceController.text.replaceAll(',', '.')) ??
        widget.account.openingBalance;

    setState(() => _saving = true);
    await ref
        .read(financeProvider.notifier)
        .editAccount(
          id: widget.account.id,
          name: name,
          colorValue: AppColors.accountColors[_selectedColorIndex].toARGB32(),
          openingBalance: balance,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: AdaptiveLayout.dialogWidth(context, 400),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifica conto',
                style: AppTextStyles.headingCard.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome conto'),
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _balanceController,
                decoration: const InputDecoration(
                  labelText: 'Saldo iniziale',
                  prefixText: '€ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
                      width: 32,
                      height: 32,
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
                    child: const Text('Salva'),
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
