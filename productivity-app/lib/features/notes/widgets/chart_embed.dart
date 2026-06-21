import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/theme/app_text_styles.dart';

const chartEmbedKey = 'note_chart';
const _uuid = Uuid();

const _chartColors = [
  Color(0xFF6C63FF),
  Color(0xFF27AE60),
  Color(0xFFE74C3C),
  Color(0xFFD4821A),
  Color(0xFF0097A7),
  Color(0xFF795548),
];

// ---------------------------------------------------------------------------
// Embed builder
// ---------------------------------------------------------------------------

class ChartEmbedBuilder extends EmbedBuilder {
  const ChartEmbedBuilder();

  @override
  String get key => chartEmbedKey;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final raw = embedContext.node.value.data as String;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return _ChartEmbedWidget(
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

class _ChartEmbedWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final String rawData;
  final bool readOnly;
  final QuillController controller;
  // Il nodo embed nel document tree: serve per calcolare l'offset assoluto
  // senza dover percorrere il Delta (più affidabile in flutter_quill v11).
  final dynamic embedNode;

  const _ChartEmbedWidget({
    required this.data,
    required this.rawData,
    required this.readOnly,
    required this.controller,
    required this.embedNode,
  });

  @override
  Widget build(BuildContext context) {
    final chartType = data['chartType'] as String? ?? 'bar';
    final title = data['title'] as String? ?? '';
    final labels =
        (data['labels'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final values = (data['values'] as List?)
            ?.map((e) => (e as num).toDouble())
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
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 0),
            child: Row(
              children: [
                Icon(
                  chartType == 'pie'
                      ? Icons.pie_chart_outline
                      : chartType == 'line'
                          ? Icons.show_chart
                          : Icons.bar_chart_outlined,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title.isNotEmpty ? title : 'Grafico',
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (!readOnly) ...[
                  EmbedActionBtn(
                    icon: Icons.edit_outlined,
                    tooltip: 'Modifica grafico',
                    onPressed: () => _edit(context),
                  ),
                  EmbedActionBtn(
                    icon: Icons.delete_outline,
                    tooltip: 'Elimina grafico',
                    onPressed: _delete,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 190,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 14),
              child: _buildChart(chartType, labels, values),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
      String type, List<String> labels, List<double> values) {
    if (values.isEmpty) {
      return Center(
          child: Text('Nessun dato', style: AppTextStyles.label));
    }
    return switch (type) {
      'line' => _LineChartWidget(labels: labels, values: values),
      'pie' => _PieChartWidget(labels: labels, values: values),
      _ => _BarChartWidget(labels: labels, values: values),
    };
  }

  void _edit(BuildContext context) async {
    // Rilascia il focus globalmente: FocusScope è scope-locale e non basta
    // perché QuillEditor può avere handler HardwareKeyboard al di fuori dello scope.
    FocusManager.instance.primaryFocus?.unfocus();
    // Aspetta un microtask affinché Flutter processi l'unfocus prima di aprire
    // la dialog (altrimenti Quill può re-acquisire il focus immediatamente).
    await Future.microtask(() {});
    if (!context.mounted) return;
    // useRootNavigator: true apre la dialog SOPRA il subtree del QuillEditor,
    // così i suoi gesture/keyboard handler non interferiscono con i TextField.
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      useRootNavigator: true,
      builder: (_) => ChartConfigDialog(initialData: data),
    );
    if (result == null) return;
    _withOffset((offset) {
      controller.replaceText(
        offset,
        1,
        BlockEmbed.custom(
            CustomBlockEmbed(chartEmbedKey, jsonEncode(result))),
        null,
      );
    });
  }

  void _delete() {
    FocusManager.instance.primaryFocus?.unfocus();
    _withOffset((offset) {
      AppLogger.instance.info('Elimino grafico al offset $offset');
      controller.replaceText(offset, 1, '', null);
    });
  }

  void _withOffset(void Function(int) callback) {
    // Strategia primaria: calcola l'offset assoluto percorrendo l'albero dei nodi
    // solo se il nodo è effettivamente attaccato (il parent non è nullo).
    // Se il parent è nullo (es. nodo disattivato o rimosso da rebuild asincroni),
    // questa strategia darebbe 0 erroneamente, quindi la saltiamo per usare il fallback.
    if (embedNode != null && embedNode.parent != null) {
      try {
        final offset = (embedNode as Node).documentOffset;
        AppLogger.instance.info('Offset grafico trovato via albero nodi: $offset');
        callback(offset);
        return;
      } catch (e) {
        AppLogger.instance.warning('Fallita strategia primaria di offset: $e');
      }
    }

    // Fallback robusto: percorre il Delta per trovare l'embed tramite il suo ID.
    // Funziona anche se il widget/nodo ha perso l'aggancio all'albero dei nodi.
    try {
      final selfId = (jsonDecode(rawData) as Map<String, dynamic>)['id'];
      AppLogger.instance.info('Ricerca offset grafico nel Delta con ID: $selfId');
      int offset = 0;
      for (final op in controller.document.toDelta().toList()) {
        if (op.isInsert && op.data is Map) {
          final map = op.data as Map;
          dynamic stored;
          
          if (map.containsKey(chartEmbedKey)) {
            stored = map[chartEmbedKey];
          } else if (map.containsKey('custom')) {
            final customVal = map['custom'];
            if (customVal is Map) {
              stored = customVal[chartEmbedKey];
            } else if (customVal is String) {
              try {
                final decoded = jsonDecode(customVal) as Map;
                stored = decoded[chartEmbedKey];
              } catch (_) {}
            }
          }

          if (stored != null) {
            try {
              final storedId =
                  (jsonDecode(stored as String) as Map<String, dynamic>)['id'];
              if (storedId == selfId) {
                AppLogger.instance.info('Offset grafico trovato via Delta (ID matching): $offset');
                callback(offset);
                return;
              }
            } catch (_) {
              if (stored == rawData) {
                AppLogger.instance.info('Offset grafico trovato via Delta (raw matching): $offset');
                callback(offset);
                return;
              }
            }
          }
        }
        final d = op.data;
        offset += d is String ? d.length : 1;
      }
      AppLogger.instance.warning('Impossibile trovare l\'offset del grafico nel Delta');
    } catch (e) {
      AppLogger.instance.error('Errore durante la ricerca fallback nel Delta: $e');
    }
  }
}


// ---------------------------------------------------------------------------
// Chart renderers
// ---------------------------------------------------------------------------

class _BarChartWidget extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  const _BarChartWidget({required this.labels, required this.values});

  @override
  Widget build(BuildContext context) {
    final maxY = values.reduce((a, b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        maxY: maxY * 1.25,
        barGroups: List.generate(
          values.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: _chartColors[i % _chartColors.length],
                width: 18,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(3)),
              ),
            ],
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(labels[i],
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (v, _) => Text(
                v.toStringAsFixed(v == v.truncateToDouble() ? 0 : 1),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.surface,
            tooltipBorder: const BorderSide(color: AppColors.border),
            getTooltipItem: (group, groupIndex, rod, _) {
              final label = groupIndex < labels.length
                  ? labels[groupIndex]
                  : '';
              final v = rod.toY;
              final valStr = v == v.truncateToDouble()
                  ? v.toInt().toString()
                  : v.toStringAsFixed(2);
              return BarTooltipItem(
                '$label\n$valStr',
                TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _chartColors[groupIndex % _chartColors.length],
                ),
              );
            },
          ),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.divider, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  const _LineChartWidget({required this.labels, required this.values});

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
        values.length, (i) => FlSpot(i.toDouble(), values[i]));
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY) * 0.2 + 1;

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: const Color(0xFF6C63FF),
            barWidth: 2,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
            ),
          ),
        ],
        minY: minY - pad,
        maxY: maxY + pad,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(labels[i],
                      style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (v, _) => Text(
                v.toStringAsFixed(v == v.truncateToDouble() ? 0 : 1),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surface,
            tooltipBorder: const BorderSide(color: AppColors.border),
            getTooltipItems: (spots) => spots.map((s) {
              final i = s.x.toInt();
              final label =
                  i >= 0 && i < labels.length ? labels[i] : '';
              final v = s.y;
              final valStr = v == v.truncateToDouble()
                  ? v.toInt().toString()
                  : v.toStringAsFixed(2);
              return LineTooltipItem(
                '$label\n$valStr',
                const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C63FF),
                ),
              );
            }).toList(),
          ),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.divider, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _PieChartWidget extends StatefulWidget {
  final List<String> labels;
  final List<double> values;
  const _PieChartWidget({required this.labels, required this.values});

  @override
  State<_PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<_PieChartWidget> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.values.fold(0.0, (s, v) => s + v);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: List.generate(widget.values.length, (i) {
                final hit = i == _touched;
                return PieChartSectionData(
                  value: widget.values[i],
                  color: _chartColors[i % _chartColors.length],
                  radius: hit ? 72 : 60,
                  title: hit
                      ? '${(widget.values[i] / total * 100).toStringAsFixed(1)}%'
                      : '',
                  titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                );
              }),
              pieTouchData: PieTouchData(
                touchCallback: (event, res) => setState(() {
                  if (!event.isInterestedForInteractions ||
                      res?.touchedSection == null) {
                    _touched = -1;
                  } else {
                    _touched = res!.touchedSection!.touchedSectionIndex;
                  }
                }),
              ),
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < widget.labels.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _chartColors[i % _chartColors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(widget.labels[i],
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Config dialog
// ---------------------------------------------------------------------------

class ChartConfigDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const ChartConfigDialog({super.key, this.initialData});

  @override
  State<ChartConfigDialog> createState() => _ChartConfigDialogState();
}

class _ChartConfigDialogState extends State<ChartConfigDialog> {
  late String _type;
  late TextEditingController _titleCtrl;
  late List<_DataRow> _rows;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _type = d?['chartType'] as String? ?? 'bar';
    _titleCtrl =
        TextEditingController(text: d?['title'] as String? ?? '');
    final labels =
        (d?['labels'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final values = (d?['values'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [];
    _rows = List.generate(
      labels.isEmpty ? 3 : labels.length,
      (i) => _DataRow(
        label: TextEditingController(
            text: i < labels.length ? labels[i] : ''),
        value: TextEditingController(
            text: i < values.length ? values[i].toString() : ''),
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addRow() => setState(() => _rows
      .add(_DataRow(label: TextEditingController(), value: TextEditingController())));

  void _removeRow(int i) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows[i].dispose();
      _rows.removeAt(i);
    });
  }

  void _save() {
    final id =
        (widget.initialData?['id'] as String?) ?? _uuid.v4();
    Navigator.of(context).pop({
      'id': id,
      'chartType': _type,
      'title': _titleCtrl.text.trim(),
      'labels':
          _rows.map((r) => r.label.text.trim()).toList(),
      'values': _rows
          .map((r) =>
              double.tryParse(r.value.text.replaceAll(',', '.')) ?? 0.0)
          .toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 440,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configura grafico',
                  style: AppTextStyles.headingCard.copyWith(fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (final t in ['bar', 'line', 'pie'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_typeName(t)),
                        selected: _type == t,
                        onSelected: (_) => setState(() => _type = t),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: 'Titolo', isDense: true),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Text('Etichetta',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600))),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('Valore',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600))),
                  SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < _rows.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _rows[i].label,
                                  decoration: const InputDecoration(
                                      isDense: true, hintText: 'Etichetta'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _rows[i].value,
                                  decoration: const InputDecoration(
                                      isDense: true, hintText: '0'),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: _rows.length > 1
                                    ? () => _removeRow(i)
                                    : null,
                                icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 16),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                color: AppColors.expense,
                              ),
                            ],
                          ),
                        ),
                    ],
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

  String _typeName(String t) => switch (t) {
        'bar' => 'Barre',
        'line' => 'Linea',
        'pie' => 'Torta',
        _ => t,
      };
}

class _DataRow {
  final TextEditingController label;
  final TextEditingController value;
  _DataRow({required this.label, required this.value});
  void dispose() {
    label.dispose();
    value.dispose();
  }
}

// ---------------------------------------------------------------------------
// Shared action button
// ---------------------------------------------------------------------------

class EmbedActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  const EmbedActionBtn({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      color: AppColors.textSecondary,
      tooltip: tooltip,
      padding: const EdgeInsets.all(4),
      constraints:
          const BoxConstraints(minWidth: 28, minHeight: 28),
    );
  }
}
