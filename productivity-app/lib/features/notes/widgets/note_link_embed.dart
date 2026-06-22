import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/notes_providers.dart';
import 'chart_embed.dart' show EmbedActionBtn;

const noteLinkEmbedKey = 'note_link';

// ---------------------------------------------------------------------------
// Embed builder
// ---------------------------------------------------------------------------

class NoteLinkEmbedBuilder extends EmbedBuilder {
  const NoteLinkEmbedBuilder();

  @override
  String get key => noteLinkEmbedKey;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final raw = embedContext.node.value.data as String;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return _NoteLinkWidget(
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

class _NoteLinkWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final String rawData;
  final bool readOnly;
  final QuillController controller;
  final dynamic embedNode;

  const _NoteLinkWidget({
    required this.data,
    required this.rawData,
    required this.readOnly,
    required this.controller,
    required this.embedNode,
  });

  String get _pageId => data['pageId'] as String? ?? '';
  String get _pageType => data['pageType'] as String? ?? 'note';
  String get _pageTitle => data['pageTitle'] as String? ?? 'Senza titolo';

  void _navigate(WidgetRef ref) {
    if (_pageType == 'goal') {
      ref.read(noteGoalsProvider.notifier).selectGoal(_pageId);
      ref.read(notesProvider.notifier).selectNote(null);
    } else {
      ref.read(notesProvider.notifier).selectNote(_pageId);
      ref.read(noteGoalsProvider.notifier).selectGoal(null);
    }
  }

  void _delete() {
    FocusManager.instance.primaryFocus?.unfocus();
    _withOffset((offset) {
      AppLogger.instance.info('Elimino collegamento al offset $offset');
      controller.replaceText(offset, 1, '', null);
    });
  }

  void _withOffset(void Function(int) callback) {
    if (embedNode != null && (embedNode as Node).parent != null) {
      try {
        final offset = (embedNode as Node).documentOffset;
        AppLogger.instance
            .info('Offset collegamento trovato via albero nodi: $offset');
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
          .info('Ricerca offset collegamento nel Delta con ID: $selfId');
      int offset = 0;
      for (final op in controller.document.toDelta().toList()) {
        if (op.isInsert && op.data is Map) {
          final map = op.data as Map;
          dynamic stored;
          if (map.containsKey(noteLinkEmbedKey)) {
            stored = map[noteLinkEmbedKey];
          } else if (map.containsKey('custom')) {
            final customVal = map['custom'];
            if (customVal is Map) {
              stored = customVal[noteLinkEmbedKey];
            } else if (customVal is String) {
              try {
                final decoded = jsonDecode(customVal) as Map;
                stored = decoded[noteLinkEmbedKey];
              } catch (_) {}
            }
          }
          if (stored != null) {
            try {
              final storedId =
                  (jsonDecode(stored as String) as Map<String, dynamic>)['id'];
              if (storedId == selfId) {
                AppLogger.instance.info(
                    'Offset collegamento trovato via Delta (ID matching): $offset');
                callback(offset);
                return;
              }
            } catch (_) {
              if (stored == rawData) {
                AppLogger.instance.info(
                    'Offset collegamento trovato via Delta (raw matching): $offset');
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
          .warning("Impossibile trovare l'offset del collegamento nel Delta");
    } catch (e) {
      AppLogger.instance
          .error('Errore durante la ricerca fallback nel Delta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: () => _navigate(ref),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35)),
                borderRadius: BorderRadius.circular(10),
                color: AppColors.primary.withValues(alpha: 0.04),
              ),
              child: Row(
                children: [
                  Icon(
                    _pageType == 'goal'
                        ? Icons.flag_outlined
                        : Icons.description_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _pageTitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward,
                      size: 14, color: AppColors.textSecondary),
                  if (!readOnly) ...[
                    const SizedBox(width: 4),
                    EmbedActionBtn(
                      icon: Icons.close,
                      tooltip: 'Rimuovi collegamento',
                      onPressed: _delete,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Link Note Dialog
// ---------------------------------------------------------------------------

class LinkNoteDialog extends ConsumerStatefulWidget {
  const LinkNoteDialog({super.key});

  @override
  ConsumerState<LinkNoteDialog> createState() => _LinkNoteDialogState();
}

class _LinkNoteDialogState extends ConsumerState<LinkNoteDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider.select((s) => s.notes));
    final goals = ref.watch(noteGoalsProvider.select((s) => s.goals));

    final q = _query.toLowerCase();
    final filteredNotes = q.isEmpty
        ? notes
        : notes.where((n) => n.title.toLowerCase().contains(q)).toList();
    final filteredGoals = q.isEmpty
        ? goals
        : goals.where((g) => g.title.toLowerCase().contains(q)).toList();

    return AlertDialog(
      title: const Text('Collega una pagina'),
      content: SizedBox(
        width: 360,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Cerca nota o obiettivo...',
                prefixIcon: const Icon(Icons.search, size: 16),
                contentPadding: EdgeInsets.zero,
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border)),
              ),
              style: AppTextStyles.bodySmall,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  if (filteredNotes.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('NOTE', style: AppTextStyles.label),
                    ),
                    for (final note in filteredNotes)
                      _LinkItem(
                        icon: Icons.description_outlined,
                        title: note.title.isEmpty ? 'Senza titolo' : note.title,
                        onTap: () => Navigator.of(context).pop({
                          'pageId': note.id,
                          'pageType': 'note',
                          'pageTitle':
                              note.title.isEmpty ? 'Senza titolo' : note.title,
                        }),
                      ),
                  ],
                  if (filteredGoals.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text('OBIETTIVI', style: AppTextStyles.label),
                    ),
                    for (final goal in filteredGoals)
                      _LinkItem(
                        icon: Icons.flag_outlined,
                        title: goal.title.isEmpty ? 'Senza titolo' : goal.title,
                        onTap: () => Navigator.of(context).pop({
                          'pageId': goal.id,
                          'pageType': 'goal',
                          'pageTitle':
                              goal.title.isEmpty ? 'Senza titolo' : goal.title,
                        }),
                      ),
                  ],
                  if (filteredNotes.isEmpty && filteredGoals.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text('Nessun risultato',
                            style: AppTextStyles.label),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
      ],
    );
  }
}

class _LinkItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _LinkItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
