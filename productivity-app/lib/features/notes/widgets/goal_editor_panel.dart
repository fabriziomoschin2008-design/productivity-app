import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../providers/notes_providers.dart';
import 'chart_embed.dart';
import 'file_embed.dart';
import 'note_link_embed.dart';
import 'table_embed.dart';

const _uuid = Uuid();

class GoalEditorPanel extends ConsumerStatefulWidget {
  final NoteGoal goal;
  const GoalEditorPanel({required super.key, required this.goal});

  @override
  ConsumerState<GoalEditorPanel> createState() => _GoalEditorState();
}

class _GoalEditorState extends ConsumerState<GoalEditorPanel> {
  late QuillController _controller;
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _deadline;
  StreamSubscription? _changesSub;
  Timer? _saveTimer;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _descController =
        TextEditingController(text: widget.goal.description ?? '');
    _deadline = widget.goal.deadline;
    _initController();
  }

  void _initController() {
    final content = widget.goal.content;
    if (content.isEmpty || content == '[]') {
      _controller = QuillController.basic();
    } else {
      try {
        final json = jsonDecode(content) as List<dynamic>;
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
    _descController.dispose();
    super.dispose();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), _save);
  }

  Future<void> _save() async {
    if (!mounted || !_hasChanges) return;
    _hasChanges = false;
    await ref.read(noteGoalsProvider.notifier).updateGoal(
          id: widget.goal.id,
          title: _titleController.text,
          description:
              _descController.text.isEmpty ? null : _descController.text,
          deadline: _deadline,
          content: jsonEncode(_controller.document.toDelta().toJson()),
        );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('it'),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
      _hasChanges = true;
      _scheduleSave();
    }
  }

  void _clearDeadline() {
    setState(() => _deadline = null);
    _hasChanges = true;
    _scheduleSave();
  }

  void _insertEmbed(String key, String jsonData) {
    final index = _controller.selection.extentOffset;
    _controller.replaceText(
      index,
      0,
      BlockEmbed.custom(CustomBlockEmbed(key, jsonData)),
      null,
    );
  }

  Future<void> _insertChart() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const ChartConfigDialog(),
    );
    if (!mounted || result == null) return;
    _insertEmbed(chartEmbedKey, jsonEncode(result));
  }

  Future<void> _insertTable() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const TableConfigDialog(),
    );
    if (!mounted || result == null) return;
    _insertEmbed(tableEmbedKey, jsonEncode(result));
  }

  Future<void> _insertFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (!mounted || result == null) return;
    for (final file in result.files) {
      if (file.path == null) continue;
      final appData = Platform.environment['LOCALAPPDATA'] ?? '';
      final destDir = Directory(
          '$appData\\ProductivityApp\\attachments\\${widget.goal.id}');
      await destDir.create(recursive: true);
      final ext = file.name.contains('.') ? file.name.split('.').last : '';
      final fileId = _uuid.v4();
      final destPath = ext.isEmpty
          ? '${destDir.path}\\$fileId'
          : '${destDir.path}\\$fileId.$ext';
      await File(file.path!).copy(destPath);
      _insertEmbed(
          fileEmbedKey,
          jsonEncode({
            'id': fileId,
            'fileName': file.name,
            'storedPath': destPath,
            'mimeType': mimeFromName(file.name),
            'sizeBytes': file.size,
          }));
    }
  }

  Future<void> _insertNoteLink() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.microtask(() {});
    if (!mounted) return;
    final result = await showDialog<Map<String, String>>(
      context: context,
      useRootNavigator: false,
      builder: (_) => const LinkNoteDialog(),
    );
    if (!mounted || result == null) return;
    _insertEmbed(
        noteLinkEmbedKey,
        jsonEncode({
          'id': _uuid.v4(),
          ...result,
        }));
  }

  String _formatDeadline(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Structured header ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 24, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.flag_outlined,
                      size: 22, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      style: AppTextStyles.headingCard.copyWith(fontSize: 26),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Obiettivo',
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
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descController,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Aggiungi una descrizione...',
                  hintStyle: TextStyle(color: AppColors.textDisabled),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                maxLines: null,
                onChanged: (_) {
                  _hasChanges = true;
                  _scheduleSave();
                },
              ),
              const SizedBox(height: 10),
              _deadline == null
                  ? TextButton.icon(
                      onPressed: _pickDeadline,
                      icon: const Icon(Icons.calendar_today_outlined,
                          size: 14),
                      label: const Text('Aggiungi scadenza'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: AppTextStyles.bodySmall,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          _formatDeadline(_deadline!),
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _pickDeadline,
                          borderRadius: BorderRadius.circular(4),
                          child: Text('Modifica',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.primary)),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: _clearDeadline,
                          borderRadius: BorderRadius.circular(4),
                          child: const Icon(Icons.close,
                              size: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        const Divider(height: 16, indent: 40, endIndent: 16),
        // ── Quill toolbar ────────────────────────────────────────
        QuillSimpleToolbar(
          controller: _controller,
          config: const QuillSimpleToolbarConfig(
            showFontFamily: false,
            showFontSize: false,
            showColorButton: true,
            showBackgroundColorButton: true,
            showClearFormat: false,
            showAlignmentButtons: false,
            showIndent: false,
            showSearchButton: false,
            showSubscript: false,
            showSuperscript: false,
          ),
        ),
        // ── Embed bar ─────────────────────────────────────────────
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              _EmbedBtn(
                  icon: Icons.table_chart_outlined,
                  label: 'Tabella',
                  onPressed: _insertTable),
              const SizedBox(width: 4),
              _EmbedBtn(
                  icon: Icons.bar_chart_outlined,
                  label: 'Grafico',
                  onPressed: _insertChart),
              const SizedBox(width: 4),
              _EmbedBtn(
                  icon: Icons.attach_file_rounded,
                  label: 'Allega',
                  onPressed: _insertFile),
              const SizedBox(width: 4),
              _EmbedBtn(
                  icon: Icons.link,
                  label: 'Collega',
                  onPressed: _insertNoteLink),
            ],
          ),
        ),
        // ── Quill editor ──────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            child: QuillEditor.basic(
              controller: _controller,
              config: QuillEditorConfig(
                placeholder: 'Aggiungi note o piano di azione...',
                padding: const EdgeInsets.fromLTRB(40, 16, 40, 80),
                scrollable: false,
                expands: false,
                embedBuilders: const [
                  ChartEmbedBuilder(),
                  TableEmbedBuilder(),
                  FileEmbedBuilder(),
                  NoteLinkEmbedBuilder(),
                ],
                onLaunchUrl: (url) async {
                  final uri = Uri.tryParse(url);
                  if (uri != null) {
                    try {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
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

class _EmbedBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _EmbedBtn(
      {required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label,
                style: AppTextStyles.label
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
