import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../providers/notes_providers.dart';

class NoteEditorPanel extends ConsumerWidget {
  const NoteEditorPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(notesProvider.select((s) => s.selectedNote));
    if (note == null) return const _EmptyEditorState();
    return _NoteEditor(key: ValueKey(note.id), note: note);
  }
}

// --- Editor ---

class _NoteEditor extends ConsumerStatefulWidget {
  final Note note;
  const _NoteEditor({required super.key, required this.note});

  @override
  ConsumerState<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<_NoteEditor> {
  late QuillController _controller;
  late TextEditingController _titleController;
  StreamSubscription? _changesSub;
  Timer? _saveTimer;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _initController();
  }

  void _initController() {
    if (widget.note.content.isEmpty) {
      _controller = QuillController.basic();
    } else {
      try {
        final json = jsonDecode(widget.note.content) as List<dynamic>;
        _controller = QuillController(
          document: Document.fromJson(json),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {
        _controller = QuillController.basic();
      }
    }
    _changesSub = _controller.changes.listen((change) {
      if (change.source == ChangeSource.local) {
        _hasChanges = true;
        _scheduleSave();
      }
    });
  }

  @override
  void dispose() {
    _changesSub?.cancel();
    _saveTimer?.cancel();
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), _save);
  }

  Future<void> _save() async {
    if (!mounted || !_hasChanges) return;
    _hasChanges = false;
    await ref.read(notesProvider.notifier).updateNote(
          id: widget.note.id,
          title: _titleController.text,
          content: jsonEncode(_controller.document.toDelta().toJson()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isPinned = ref.watch(notesProvider.select((s) =>
        s.notes
            .where((n) => n.id == widget.note.id)
            .firstOrNull
            ?.isPinned ??
        widget.note.isPinned));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: titolo + pin
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 24, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  style: AppTextStyles.headingCard.copyWith(fontSize: 26),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Senza titolo',
                    hintStyle: TextStyle(
                        color: AppColors.textDisabled, fontSize: 26),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (_) {
                    _hasChanges = true;
                    _scheduleSave();
                  },
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(notesProvider.notifier).togglePin(widget.note.id),
                icon: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 18,
                ),
                color: isPinned ? AppColors.accent : AppColors.textDisabled,
                tooltip: isPinned ? 'Rimuovi pin' : 'Pinna nota',
              ),
            ],
          ),
        ),
        // Toolbar
        QuillSimpleToolbar(
          controller: _controller,
          config: const QuillSimpleToolbarConfig(
            showFontFamily: false,
            showFontSize: false,
            showColorButton: false,
            showBackgroundColorButton: false,
            showClearFormat: false,
            showAlignmentButtons: false,
            showIndent: false,
            showSearchButton: false,
            showSubscript: false,
            showSuperscript: false,
          ),
        ),
        const Divider(height: 1),
        // Editor: SingleChildScrollView esterno gestisce lo scroll
        // mentre il QuillEditor cresce con il contenuto
        Expanded(
          child: SingleChildScrollView(
            child: QuillEditor.basic(
              controller: _controller,
              config: QuillEditorConfig(
                placeholder: 'Inizia a scrivere...',
                padding: const EdgeInsets.fromLTRB(40, 16, 40, 80),
                scrollable: false,
                expands: false,
                onLaunchUrl: (url) async {
                  final uri = Uri.tryParse(url);
                  if (uri != null) {
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Stato vuoto ---

class _EmptyEditorState extends StatelessWidget {
  const _EmptyEditorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined,
              size: 40, color: AppColors.textDisabled),
          const SizedBox(height: 14),
          Text('Nessuna nota selezionata',
              style: AppTextStyles.bodyRegular
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Seleziona o crea una nota', style: AppTextStyles.label),
        ],
      ),
    );
  }
}
