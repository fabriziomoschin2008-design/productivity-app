import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ImportDialog extends StatefulWidget {
  final Function(File) onImport;

  const ImportDialog({
    super.key,
    required this.onImport,
  });

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  File? _selectedFile;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Importa Conti da Excel', style: AppTextStyles.headingCard),
              const SizedBox(height: 16),
              if (_selectedFile == null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seleziona un file Excel (.xlsx)',
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Seleziona File'),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('File selezionato:', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFile!.path.split('\\').last,
                              style: AppTextStyles.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _selectedFile = null),
                          child: const Text('Annulla Selezione'),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Chiudi'),
                  ),
                  const SizedBox(width: 8),
                  if (_selectedFile != null)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _import,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Importa'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = File(result.files.first.path!));
    }
  }

  Future<void> _import() async {
    if (_selectedFile == null) return;

    setState(() => _isLoading = true);

    try {
      widget.onImport(_selectedFile!);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
