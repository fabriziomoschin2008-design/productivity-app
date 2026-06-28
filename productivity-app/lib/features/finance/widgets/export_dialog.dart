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
    final dirPath = _resolvedDirectoryPath();
    final files = _listFiles(dirPath);

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
                child: SelectableText(dirPath, style: AppTextStyles.bodySmall),
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

  String _resolvedDirectoryPath() {
    final entity = FileSystemEntity.typeSync(exportedDir);
    if (entity == FileSystemEntityType.file) {
      return File(exportedDir).parent.path;
    }
    return exportedDir;
  }

  List<File> _listFiles(String dirPath) {
    try {
      return Directory(dirPath).listSync().whereType<File>().toList()
        ..sort((a, b) => a.path.compareTo(b.path));
    } catch (_) {
      return [];
    }
  }

  Future<void> _openDir() async {
    final dirPath = _resolvedDirectoryPath();
    await Process.run('explorer', [dirPath.replaceAll('/', '\\')]);
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
            child: Text(
              name,
              style: AppTextStyles.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
