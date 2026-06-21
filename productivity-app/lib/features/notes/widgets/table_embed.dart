import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'chart_embed.dart' show EmbedActionBtn;

const tableEmbedKey = 'note_table';
const _uuid = Uuid();

// ---------------------------------------------------------------------------
// Embed builder
// ---------------------------------------------------------------------------

class TableEmbedBuilder extends EmbedBuilder {
  const TableEmbedBuilder();

  @override
  String get key => tableEmbedKey;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final raw = embedContext.node.value.data as String;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return _TableEmbedWidget(
      data: data,
      rawData: raw,
      readOnly: embedContext.readOnly,
      controller: embedContext.controller,
    );
  }
}

// ---------------------------------------------------------------------------
// Embed widget
// ---------------------------------------------------------------------------

class _TableEmbedWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final String rawData;
  final bool readOnly;
  final QuillController controller;

  const _TableEmbedWidget({
    required this.data,
    required this.rawData,
    required this.readOnly,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final headers = (data['headers'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final rows = (data['rows'] as List?)
            ?.map((r) => (r as List).map((c) => c.toString()).toList())
            .toList() ??
        [];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 6, 6),
            child: Row(
              children: [
                Icon(Icons.table_chart_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Tabella',
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                if (!readOnly) ...[
                  EmbedActionBtn(
                    icon: Icons.edit_outlined,
                    tooltip: 'Modifica tabella',
                    onPressed: () => _edit(context),
                  ),
                  EmbedActionBtn(
                    icon: Icons.delete_outline,
                    tooltip: 'Elimina tabella',
                    onPressed: _delete,
                  ),
                ],
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: _buildTable(headers, rows),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<String> headers, List<List<String>> rows) {
    if (headers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text('Tabella vuota', style: AppTextStyles.label),
      );
    }

    final cols = headers.length;
    const cellPad = EdgeInsets.symmetric(horizontal: 12, vertical: 7);
    const minWidth = 90.0;

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(flex: 1.0),
      border: TableBorder.all(color: AppColors.divider, width: 1),
      children: [
        // Header row
        TableRow(
          decoration: const BoxDecoration(color: AppColors.surfaceElevated),
          children: [
            for (final h in headers)
              TableCell(
                child: Padding(
                  padding: cellPad,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: minWidth),
                    child: Text(h,
                        style: AppTextStyles.bodySmall
                            .copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
          ],
        ),
        // Data rows
        for (final row in rows)
          TableRow(
            children: [
              for (int c = 0; c < cols; c++)
                TableCell(
                  child: Padding(
                    padding: cellPad,
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: minWidth),
                      child: Text(
                        c < row.length ? row[c] : '',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  void _edit(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => TableConfigDialog(initialData: data),
    );
    if (result == null) return;
    _withOffset((offset) {
      controller.replaceText(
        offset,
        1,
        BlockEmbed.custom(
            CustomBlockEmbed(tableEmbedKey, jsonEncode(result))),
        null,
      );
    });
  }

  void _delete() {
    _withOffset(
        (offset) => controller.replaceText(offset, 1, '', null));
  }

  void _withOffset(void Function(int) callback) {
    final selfId = (jsonDecode(rawData) as Map<String, dynamic>)['id'];
    int offset = 0;
    for (final op in controller.document.toDelta().toList()) {
      if (op.isInsert && op.data is Map) {
        final d = op.data as Map;
        final stored = d[tableEmbedKey];
        if (stored != null) {
          try {
            final storedId =
                (jsonDecode(stored as String) as Map<String, dynamic>)['id'];
            if (storedId == selfId) {
              callback(offset);
              return;
            }
          } catch (_) {
            if (stored == rawData) {
              callback(offset);
              return;
            }
          }
        }
      }
      final d = op.data;
      offset += d is String ? d.length : 1;
    }
  }
}

// ---------------------------------------------------------------------------
// Config dialog
// ---------------------------------------------------------------------------

class TableConfigDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const TableConfigDialog({super.key, this.initialData});

  @override
  State<TableConfigDialog> createState() => _TableConfigDialogState();
}

class _TableConfigDialogState extends State<TableConfigDialog> {
  late List<TextEditingController> _headers;
  late List<List<TextEditingController>> _rows;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    final hList = (d?['headers'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        ['', '', ''];
    _headers =
        hList.map((h) => TextEditingController(text: h)).toList();

    final rList = (d?['rows'] as List?)
            ?.map((r) => (r as List).map((c) => c.toString()).toList())
            .toList() ??
        [List.filled(hList.length, ''), List.filled(hList.length, '')];

    _rows = rList
        .map((r) => List<TextEditingController>.generate(
              hList.length,
              (i) =>
                  TextEditingController(text: i < r.length ? r[i] : ''),
            ))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _headers) {
      c.dispose();
    }
    for (final row in _rows) {
      for (final c in row) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _addColumn() {
    setState(() {
      _headers.add(TextEditingController());
      for (final row in _rows) {
        row.add(TextEditingController());
      }
    });
  }

  void _removeColumn() {
    if (_headers.length <= 1) return;
    setState(() {
      _headers.last.dispose();
      _headers.removeLast();
      for (final row in _rows) {
        row.last.dispose();
        row.removeLast();
      }
    });
  }

  void _addRow() {
    setState(() => _rows.add(
        List.generate(_headers.length, (_) => TextEditingController())));
  }

  void _removeRow(int i) {
    if (_rows.length <= 1) return;
    setState(() {
      for (final c in _rows[i]) {
        c.dispose();
      }
      _rows.removeAt(i);
    });
  }

  void _save() {
    final id =
        (widget.initialData?['id'] as String?) ?? _uuid.v4();
    Navigator.of(context).pop({
      'id': id,
      'headers': _headers.map((c) => c.text).toList(),
      'rows': _rows
          .map((r) => r.map((c) => c.text).toList())
          .toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final cols = _headers.length;
    const cellW = 120.0;

    return Dialog(
      child: SizedBox(
        width: 160.0 + cols * (cellW + 8) + 60,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Configura tabella',
                      style: AppTextStyles.headingCard
                          .copyWith(fontSize: 16)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addColumn,
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Colonna'),
                  ),
                  if (cols > 1)
                    TextButton.icon(
                      onPressed: _removeColumn,
                      icon: const Icon(Icons.remove, size: 14),
                      label: const Text('Colonna'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.expense),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          children: [
                            const SizedBox(width: 32),
                            for (int c = 0; c < cols; c++)
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 4),
                                child: SizedBox(
                                  width: cellW,
                                  child: TextField(
                                    controller: _headers[c],
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Intestazione ${c + 1}',
                                      filled: true,
                                      fillColor: AppColors.surfaceElevated,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Data rows
                        for (int r = 0; r < _rows.length; r++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 32,
                                  child: IconButton(
                                    onPressed: _rows.length > 1
                                        ? () => _removeRow(r)
                                        : null,
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 14),
                                    padding: EdgeInsets.zero,
                                    constraints:
                                        const BoxConstraints(),
                                    color: AppColors.expense,
                                  ),
                                ),
                                for (int c = 0; c < cols; c++)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(right: 4),
                                    child: SizedBox(
                                      width: cellW,
                                      child: TextField(
                                        controller: _rows[r][c],
                                        decoration:
                                            const InputDecoration(
                                                isDense: true),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Aggiungi riga'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Inserisci'),
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
