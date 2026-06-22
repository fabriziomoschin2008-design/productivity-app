import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../providers/tracker_providers.dart';

// Same palette as accountColors, with a teal swap for variety
const _trackerColors = [
  Color(0xFFFF6B45),
  Color(0xFF2E9B5E),
  Color(0xFFFFB347),
  Color(0xFF7C6EE8),
  Color(0xFF00A3B4),
  Color(0xFFE74C3C),
  Color(0xFF8D6E63),
  Color(0xFF546E7A),
];

class AddTrackerDialog extends ConsumerStatefulWidget {
  final Tracker? existing;

  const AddTrackerDialog({super.key, this.existing});

  @override
  ConsumerState<AddTrackerDialog> createState() => _AddTrackerDialogState();
}

class _AddTrackerDialogState extends ConsumerState<AddTrackerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _stepCtrl;
  late final TextEditingController _unitCtrl;
  late int _selectedColor;
  late bool _dailyAuto;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _targetCtrl =
        TextEditingController(text: e != null ? _fmt(e.targetValue) : '');
    _stepCtrl = TextEditingController(text: e != null ? _fmt(e.step) : '1');
    _unitCtrl = TextEditingController(text: e?.unit ?? '');
    _selectedColor = e?.colorValue ?? _trackerColors.first.toARGB32();
    _dailyAuto = e?.isDailyAutoIncrement ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _stepCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    final target = double.parse(_targetCtrl.text.trim());
    final step = double.parse(_stepCtrl.text.trim());
    final unit = _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim();
    final notifier = ref.read(trackerProvider.notifier);
    if (_isEdit) {
      await notifier.updateTrackerMeta(
        id: widget.existing!.id,
        name: name,
        targetValue: target,
        step: step,
        unit: unit,
        colorValue: _selectedColor,
        isDailyAutoIncrement: _dailyAuto,
      );
    } else {
      await notifier.createTracker(
        name: name,
        targetValue: target,
        step: step,
        unit: unit,
        colorValue: _selectedColor,
        isDailyAutoIncrement: _dailyAuto,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEdit ? 'Modifica tracker' : 'Nuovo tracker',
                  style: AppTextStyles.headingCard,
                ),
                const SizedBox(height: 24),
                _Field(
                  controller: _nameCtrl,
                  label: 'Nome',
                  hint: 'es. Capelli scrunchati',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Inserisci un nome' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _targetCtrl,
                        label: 'Obiettivo',
                        hint: '15',
                        keyboard: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Obbligatorio';
                          final n = double.tryParse(v.trim());
                          if (n == null || n <= 0) return 'Numero > 0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        controller: _stepCtrl,
                        label: 'Incremento',
                        hint: '1',
                        keyboard: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Obbligatorio';
                          final n = double.tryParse(v.trim());
                          if (n == null || n <= 0) return 'Numero > 0';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Field(
                  controller: _unitCtrl,
                  label: 'Unità (opzionale)',
                  hint: 'es. km, bicchieri, volte',
                ),
                const SizedBox(height: 20),
                Text('Colore', style: AppTextStyles.label),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _trackerColors.map((c) {
                    final selected = c.toARGB32() == _selectedColor;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = c.toARGB32()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(
                                  color: AppColors.textPrimary, width: 2.5)
                              : null,
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: c.withValues(alpha: 0.45),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Auto-increment toggle
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SwitchListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    title: Text(
                      'Incremento automatico giornaliero',
                      style: AppTextStyles.bodyRegular,
                    ),
                    subtitle: Text(
                      'Aggiunge l\'incremento ogni giorno a mezzanotte',
                      style:
                          AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                    ),
                    value: _dailyAuto,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _dailyAuto = v),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annulla'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(_isEdit ? 'Salva' : 'Crea'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboard;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboard,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppTextStyles.bodyRegular,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyRegular
                .copyWith(color: AppColors.textDisabled),
            filled: true,
            fillColor: AppColors.surfaceElevated,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.expense, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.expense, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
