import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/layout/adaptive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../providers/notes_providers.dart';

class NotesListPanel extends ConsumerStatefulWidget {
  const NotesListPanel({super.key});

  @override
  ConsumerState<NotesListPanel> createState() => _NotesListPanelState();
}

class _NotesListPanelState extends ConsumerState<NotesListPanel> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider.select((s) => s.visibleNotes));
    final selectedNoteId = ref.watch(
      notesProvider.select((s) => s.selectedNoteId),
    );

    return SizedBox(
      width: AdaptiveLayout.sidePanelWidth(context, desktopWidth: 280),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cerca...',
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 16,
                          color: AppColors.textDisabled,
                        ),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                      ),
                      style: AppTextStyles.bodySmall,
                      onChanged: (q) =>
                          ref.read(notesProvider.notifier).search(q),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(notesProvider.notifier).createNote(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: Size.zero,
                    ),
                    child: const Icon(Icons.add, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: notes.isEmpty
                ? const _EmptyNotesList()
                : ListView.separated(
                    itemCount: notes.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (_, i) {
                      final note = notes[i];
                      return _NoteTile(
                        note: note,
                        selected: note.id == selectedNoteId,
                        onTap: () {
                          ref.read(notesProvider.notifier).selectNote(note.id);
                          ref.read(noteGoalsProvider.notifier).selectGoal(null);
                        },
                        onDelete: () => ref
                            .read(notesProvider.notifier)
                            .deleteNote(note.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  final Note note;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteTile({
    required this.note,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  String _preview(String content) {
    if (content.isEmpty) return '';
    try {
      // Formato Quill Delta: List<{insert: String, ...}>
      final ops = jsonDecode(content) as List<dynamic>;
      final text = ops
          .map((op) {
            final insert = op['insert'];
            return insert is String ? insert : '';
          })
          .join('')
          .replaceAll('\n', ' ')
          .trim();
      return text.length > 120 ? '${text.substring(0, 120)}…' : text;
    } catch (_) {
      return '';
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview(note.content);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? AppColors.primary.withValues(alpha: 0.06) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (note.isPinned) ...[
                  const Icon(Icons.push_pin, size: 11, color: AppColors.accent),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    note.title.isEmpty ? 'Senza titolo' : note.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: note.title.isEmpty
                          ? AppColors.textDisabled
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Elimina nota'),
                    ),
                  ],
                  icon: const Icon(Icons.more_horiz, size: 14),
                  iconColor: AppColors.textDisabled,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                preview,
                style: AppTextStyles.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatDate(note.updatedAt),
              style: AppTextStyles.label.copyWith(
                color: AppColors.textDisabled,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotesList extends StatelessWidget {
  const _EmptyNotesList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_outlined, size: 36, color: AppColors.textDisabled),
          const SizedBox(height: 12),
          Text(
            'Nessuna nota',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text('Premi + per crearne una', style: AppTextStyles.label),
        ],
      ),
    );
  }
}
