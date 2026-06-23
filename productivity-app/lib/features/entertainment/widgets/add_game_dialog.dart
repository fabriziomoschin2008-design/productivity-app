import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/entertainment_providers.dart';
import '../state/games_state.dart';

class AddGameDialog extends ConsumerStatefulWidget {
  const AddGameDialog({super.key});

  @override
  ConsumerState<AddGameDialog> createState() => _AddGameDialogState();
}

class _AddGameDialogState extends ConsumerState<AddGameDialog> {
  final _titleCtrl = TextEditingController();
  final _platformCtrl = TextEditingController();
  String _status = 'playing';
  final List<TextEditingController> _objCtrls = [];
  final List<bool> _objDone = [];
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _platformCtrl.dispose();
    for (final c in _objCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addObjective() {
    setState(() {
      _objCtrls.add(TextEditingController());
      _objDone.add(false);
    });
  }

  void _removeObjective(int i) {
    setState(() {
      _objCtrls[i].dispose();
      _objCtrls.removeAt(i);
      _objDone.removeAt(i);
    });
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);

    final objectives = List.generate(
      _objCtrls.length,
      (i) => GameObjective(desc: _objCtrls[i].text.trim(), done: _objDone[i]),
    ).where((o) => o.desc.isNotEmpty).toList();

    await ref.read(gamesProvider.notifier).addGame(
          title,
          platform: _platformCtrl.text.trim().isEmpty
              ? null
              : _platformCtrl.text.trim(),
          objectives: objectives,
          status: _status,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Aggiungi gioco',
                  style: AppTextStyles.headingCard
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(
                controller: _titleCtrl,
                autofocus: true,
                decoration: _inputDec('Titolo *'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _platformCtrl,
                decoration: _inputDec('Piattaforma (opzionale)'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status, // ignore: deprecated_member_use
                decoration: _inputDec('Stato'),
                items: const [
                  DropdownMenuItem(value: 'playing', child: Text('In corso')),
                  DropdownMenuItem(
                      value: 'completed', child: Text('Completato')),
                  DropdownMenuItem(
                      value: 'want_to_play', child: Text('Da giocare')),
                ],
                onChanged: (v) => setState(() => _status = v ?? _status),
              ),
              if (_objCtrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Obiettivi', style: AppTextStyles.label),
                const SizedBox(height: 8),
                ...List.generate(
                  _objCtrls.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _objDone[i],
                          onChanged: (v) =>
                              setState(() => _objDone[i] = v ?? false),
                          activeColor: AppColors.income,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _objCtrls[i],
                            decoration: _inputDec('Obiettivo ${i + 1}'),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeObjective(i),
                          icon: const Icon(Icons.remove_circle_outline,
                              color: AppColors.expense, size: 18),
                          padding: const EdgeInsets.only(left: 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              TextButton.icon(
                onPressed: _addObjective,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Aggiungi obiettivo'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Salva'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
}
