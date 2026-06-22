import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'chart_embed.dart' show EmbedActionBtn;

const fileEmbedKey = 'note_file';

String mimeFromName(String name) {
  final ext = name.split('.').last.toLowerCase();
  return const {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'bmp': 'image/bmp',
    'svg': 'image/svg+xml',
    'mp4': 'video/mp4',
    'mov': 'video/quicktime',
    'mp3': 'audio/mpeg',
    'm4a': 'audio/mp4',
    'wav': 'audio/wav',
    'pdf': 'application/pdf',
  }[ext] ??
      'application/octet-stream';
}

bool _isImage(String mime) =>
    mime.startsWith('image/') && mime != 'image/svg+xml';

IconData _iconForMime(String mime) {
  if (mime.startsWith('video/')) return Icons.video_file_outlined;
  if (mime.startsWith('audio/')) return Icons.audio_file_outlined;
  if (mime == 'application/pdf') return Icons.picture_as_pdf_outlined;
  return Icons.insert_drive_file_outlined;
}

Color _colorForMime(String mime) {
  if (mime.startsWith('video/')) return const Color(0xFF6C63FF);
  if (mime.startsWith('audio/')) return const Color(0xFF27AE60);
  if (mime == 'application/pdf') return AppColors.expense;
  return AppColors.textSecondary;
}

String _formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
}

// ---------------------------------------------------------------------------
// Embed builder
// ---------------------------------------------------------------------------

class FileEmbedBuilder extends EmbedBuilder {
  const FileEmbedBuilder();

  @override
  String get key => fileEmbedKey;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final raw = embedContext.node.value.data as String;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return _FileEmbedWidget(
      data: data,
      rawData: raw,
      readOnly: embedContext.readOnly,
      controller: embedContext.controller,
      embedNode: embedContext.node,
    );
  }
}

// ---------------------------------------------------------------------------
// Embed widget
// ---------------------------------------------------------------------------

class _FileEmbedWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final String rawData;
  final bool readOnly;
  final QuillController controller;
  final dynamic embedNode;

  const _FileEmbedWidget({
    required this.data,
    required this.rawData,
    required this.readOnly,
    required this.controller,
    required this.embedNode,
  });

  String get _storedPath => data['storedPath'] as String? ?? '';
  String get _fileName => data['fileName'] as String? ?? 'file';
  String get _mimeType =>
      data['mimeType'] as String? ?? 'application/octet-stream';
  int get _sizeBytes => (data['sizeBytes'] as num?)?.toInt() ?? 0;

  Future<void> _openFile() async {
    final uri = Uri.file(_storedPath);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _delete() {
    FocusManager.instance.primaryFocus?.unfocus();
    final path = _storedPath;
    _withOffset((offset) {
      AppLogger.instance.info('Elimino allegato al offset $offset');
      controller.replaceText(offset, 1, '', null);
      try {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      } catch (e) {
        AppLogger.instance.warning('Impossibile eliminare file allegato: $e');
      }
    });
  }

  void _withOffset(void Function(int) callback) {
    if (embedNode != null && (embedNode as Node).parent != null) {
      try {
        final offset = (embedNode as Node).documentOffset;
        AppLogger.instance
            .info('Offset allegato trovato via albero nodi: $offset');
        callback(offset);
        return;
      } catch (e) {
        AppLogger.instance
            .warning('Fallita strategia primaria di offset: $e');
      }
    }

    try {
      final selfId = (jsonDecode(rawData) as Map<String, dynamic>)['id'];
      AppLogger.instance
          .info('Ricerca offset allegato nel Delta con ID: $selfId');
      int offset = 0;
      for (final op in controller.document.toDelta().toList()) {
        if (op.isInsert && op.data is Map) {
          final map = op.data as Map;
          dynamic stored;
          if (map.containsKey(fileEmbedKey)) {
            stored = map[fileEmbedKey];
          } else if (map.containsKey('custom')) {
            final customVal = map['custom'];
            if (customVal is Map) {
              stored = customVal[fileEmbedKey];
            } else if (customVal is String) {
              try {
                final decoded = jsonDecode(customVal) as Map;
                stored = decoded[fileEmbedKey];
              } catch (_) {}
            }
          }
          if (stored != null) {
            try {
              final storedId =
                  (jsonDecode(stored as String) as Map<String, dynamic>)['id'];
              if (storedId == selfId) {
                AppLogger.instance.info(
                    'Offset allegato trovato via Delta (ID matching): $offset');
                callback(offset);
                return;
              }
            } catch (_) {
              if (stored == rawData) {
                AppLogger.instance.info(
                    'Offset allegato trovato via Delta (raw matching): $offset');
                callback(offset);
                return;
              }
            }
          }
        }
        final d = op.data;
        offset += d is String ? d.length : 1;
      }
      AppLogger.instance
          .warning("Impossibile trovare l'offset dell'allegato nel Delta");
    } catch (e) {
      AppLogger.instance
          .error('Errore durante la ricerca fallback nel Delta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isImage(_mimeType)) return _buildImageEmbed();
    return _buildFileCard();
  }

  Widget _buildImageEmbed() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: _openFile,
            child: Image.file(
              File(_storedPath),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 120,
                color: AppColors.surfaceElevated,
                child: Center(
                  child: Icon(Icons.broken_image_outlined,
                      color: AppColors.textDisabled, size: 32),
                ),
              ),
            ),
          ),
          _FileBar(
            fileName: _fileName,
            sizeBytes: _sizeBytes,
            onOpen: _openFile,
            onDelete: readOnly ? null : _delete,
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard() {
    final mime = _mimeType;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _colorForMime(mime).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_iconForMime(mime),
                size: 22, color: _colorForMime(mime)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fileName,
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(_formatSize(_sizeBytes), style: AppTextStyles.label),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _openFile,
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              textStyle: AppTextStyles.label,
            ),
            child: const Text('Apri'),
          ),
          if (!readOnly) ...[
            const SizedBox(width: 4),
            EmbedActionBtn(
              icon: Icons.delete_outline,
              tooltip: 'Rimuovi allegato',
              onPressed: _delete,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// File bar (shown below images)
// ---------------------------------------------------------------------------

class _FileBar extends StatelessWidget {
  final String fileName;
  final int sizeBytes;
  final VoidCallback onOpen;
  final VoidCallback? onDelete;

  const _FileBar({
    required this.fileName,
    required this.sizeBytes,
    required this.onOpen,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
        color: AppColors.surface,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style:
                      AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(_formatSize(sizeBytes), style: AppTextStyles.label),
              ],
            ),
          ),
          TextButton(
            onPressed: onOpen,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: AppTextStyles.label,
            ),
            child: const Text('Apri'),
          ),
          if (onDelete != null)
            EmbedActionBtn(
              icon: Icons.delete_outline,
              tooltip: 'Rimuovi allegato',
              onPressed: onDelete!,
            ),
        ],
      ),
    );
  }
}
