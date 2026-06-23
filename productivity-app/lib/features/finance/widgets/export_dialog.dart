import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ExportDialog extends StatelessWidget {
  /// Percorso della cartella export (o cartella del template).
  final String exportedDir;

  const ExportDialog({super.key, required this.exportedDir});

  @override
  Widget build(BuildContext context) {
    final files = _listFiles();

    return Dialog(
      backgroundColor: AppColors.surface,
      child: SizedBox(
        width: 460,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Export completato', style: AppTextStyles.headingCard),
              const SizedBox(height: 16),
              Text('Cartella:', style: AppTextStyles.label),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  exportedDir,
                  style: AppTextStyles.bodySmall,
                ),
              ),
              if (files.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text('File generati:', style: AppTextStyles.label),
                const SizedBox(height: 6),
                ...files.map((f) => _FileLine(file: f)),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Chiudi'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _openDir,
                    icon: const Icon(Icons.folder_open, size: 16),
                    label: const Text('Apri Cartella'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<File> _listFiles() {
    try {
      return Directory(exportedDir)
          .listSync()
          .whereType<File>()
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
    } catch (_) {
      return [];
    }
  }

  Future<void> _openDir() async {
    await Process.run('explorer', [exportedDir.replaceAll('/', '\\')]);
  }
}

class _FileLine extends StatelessWidget {
  final File file;
  const _FileLine({required this.file});

  @override
  Widget build(BuildContext context) {
    final name = file.path.split('\\').last;
    final isXlsx = name.endsWith('.xlsx');
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isXlsx ? Icons.table_chart_outlined : Icons.bar_chart_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name,
                style: AppTextStyles.bodySmall,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
