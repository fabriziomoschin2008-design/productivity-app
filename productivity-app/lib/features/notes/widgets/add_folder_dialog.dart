import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/layout/adaptive_layout.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/notes_providers.dart';

class AddFolderDialog extends ConsumerStatefulWidget {
  const AddFolderDialog({super.key});

  @override
  ConsumerState<AddFolderDialog> createState() => _AddFolderDialogState();
}

class _AddFolderDialogState extends ConsumerState<AddFolderDialog> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    await ref.read(notesProvider.notifier).createFolder(name);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: AdaptiveLayout.dialogWidth(context, 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nuova cartella',
                style: AppTextStyles.headingCard.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Nome cartella'),
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 24),
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
                    child: const Text('Crea'),
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
