import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/finance_providers.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  final String accountId;
  const AddTransactionDialog({super.key, required this.accountId});

  @override
  ConsumerState<AddTransactionDialog> createState() =>
      _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  static const _customSentinel = '— Personalizzata —';

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _customCategoryController = TextEditingController();

  String _type = 'expense';
  String _category = Categories.expense.first;
  bool _isCustomCategory = false;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  List<String> get _categories =>
      _type == 'expense' ? Categories.expense : Categories.income;

  List<String> get _allCategories => [..._categories, _customSentinel];

  void _onTypeChanged(String type) {
    setState(() {
      _type = type;
      _category =
          (type == 'expense' ? Categories.expense : Categories.income).first;
      _isCustomCategory = false;
      _customCategoryController.clear();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;

    final category = _isCustomCategory
        ? _customCategoryController.text.trim()
        : _category;
    if (category.isEmpty) return;

    setState(() => _saving = true);
    await ref.read(financeProvider.notifier).addTransaction(
          accountId: widget.accountId,
          amount: amount,
          type: _type,
          category: category,
          date: _date,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
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
              Text('Aggiungi movimento',
                  style: AppTextStyles.headingCard.copyWith(fontSize: 17)),
              const SizedBox(height: 24),
              Row(
                children: [
                  _TypeToggle(
                    label: 'Spesa',
                    selected: _type == 'expense',
                    color: AppColors.expense,
                    onTap: () => _onTypeChanged('expense'),
                  ),
                  const SizedBox(width: 10),
                  _TypeToggle(
                    label: 'Entrata',
                    selected: _type == 'income',
                    color: AppColors.income,
                    onTap: () => _onTypeChanged('income'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Importo',
                  prefixText: '€ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _isCustomCategory ? _customSentinel : _category,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: _allCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v == _customSentinel) {
                    setState(() => _isCustomCategory = true);
                  } else {
                    setState(() {
                      _isCustomCategory = false;
                      _category = v!;
                    });
                  }
                },
              ),
              if (_isCustomCategory) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _customCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Scrivi la categoria',
                    hintText: 'Es. Carburante, Palestra, ...',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Data'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatDateMedium(_date),
                          style: AppTextStyles.bodyRegular),
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: AppColors.textSecondary),
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

class _TypeToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeToggle({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
