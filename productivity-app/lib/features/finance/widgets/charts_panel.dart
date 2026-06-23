import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/local/database.dart';

class ChartsPanel extends StatefulWidget {
  final List<TransactionEntry> transactions;

  const ChartsPanel({super.key, required this.transactions});

  @override
  State<ChartsPanel> createState() => _ChartsPanelState();
}

class _ChartsPanelState extends State<ChartsPanel> {
  int _selectedChart = 0;

  static const _chartLabels = ['Spese per categoria', 'Entrate vs Spese', 'Andamento saldo'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
      children: [
        _ChartTabs(
          selected: _selectedChart,
          labels: _chartLabels,
          onSelect: (i) => setState(() => _selectedChart = i),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
            child: switch (_selectedChart) {
              0 => _PieChartView(transactions: widget.transactions),
              1 => _BarChartView(transactions: widget.transactions),
              _ => _LineChartView(transactions: widget.transactions),
            },
          ),
        ),
      ],
      ),
    );
  }
}

class _ChartTabs extends StatelessWidget {
  final int selected;
  final List<String> labels;
  final ValueChanged<int> onSelect;

  const _ChartTabs(
      {required this.selected,
      required this.labels,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  labels[i],
                  style: AppTextStyles.label.copyWith(
                    color: active ? Colors.white : AppColors.textSecondary,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// --- Pie Chart: spese per categoria ---

class _PieChartView extends StatefulWidget {
  final List<TransactionEntry> transactions;
  const _PieChartView({required this.transactions});

  @override
  State<_PieChartView> createState() => _PieChartViewState();
}

class _PieChartViewState extends State<_PieChartView> {
  int _touched = -1;

  Map<String, double> get _expensesByCategory {
    final map = <String, double>{};
    for (final t in widget.transactions) {
      if (t.type == 'expense') {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  static const _colors = [
    Color(0xFF1E3A5F),
    Color(0xFFD4821A),
    Color(0xFF1A7A45),
    Color(0xFFC0392B),
    Color(0xFF6C5CE7),
    Color(0xFF0097A7),
    Color(0xFF795548),
    Color(0xFF546E7A),
    Color(0xFFE17055),
  ];

  @override
  Widget build(BuildContext context) {
    final data = _expensesByCategory;
    if (data.isEmpty) return _noData('Nessuna spesa registrata');

    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0.0, (s, e) => s + e.value);

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: List.generate(entries.length, (i) {
                final entry = entries[i];
                final isTouched = i == _touched;
                return PieChartSectionData(
                  value: entry.value,
                  color: _colors[i % _colors.length],
                  radius: isTouched ? 90 : 78,
                  title: isTouched
                      ? '${(entry.value / total * 100).toStringAsFixed(1)}%'
                      : '',
                  titleStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                );
              }),
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touched = -1;
                      return;
                    }
                    _touched =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              centerSpaceRadius: 48,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 32),
        SizedBox(
          width: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < entries.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _colors[i % _colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(entries[i].key,
                            style: AppTextStyles.bodySmall,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text(formatCurrency(entries[i].value),
                          style: AppTextStyles.amountSmall),
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

// --- Bar Chart: entrate vs spese per mese ---

class _BarChartView extends StatelessWidget {
  final List<TransactionEntry> transactions;
  const _BarChartView({required this.transactions});

  List<_MonthData> get _monthlyData {
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i));
      return _MonthData(year: m.year, month: m.month);
    });

    for (final t in transactions) {
      for (final m in months) {
        if (t.date.year == m.year && t.date.month == m.month) {
          if (t.type == 'income') {
            m.income += t.amount;
          } else {
            m.expense += t.amount;
          }
        }
      }
    }
    return months;
  }

  @override
  Widget build(BuildContext context) {
    final data = _monthlyData;
    final maxY = data.fold(0.0, (m, d) => [m, d.income, d.expense].reduce((a, b) => a > b ? a : b));

    if (maxY == 0) return _noData('Nessun dato per gli ultimi 6 mesi');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              _LegendDot(color: const Color(0xFF27AE60)),
              const SizedBox(width: 4),
              Text('Entrate', style: AppTextStyles.label),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFFE74C3C)),
              const SizedBox(width: 4),
              Text('Spese', style: AppTextStyles.label),
            ],
          ),
        ),
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxY * 1.25,
              barGroups: List.generate(data.length, (i) {
                final d = data[i];
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: d.income,
                      color: const Color(0xFF27AE60),
                      width: 12,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3)),
                    ),
                    BarChartRodData(
                      toY: d.expense,
                      color: const Color(0xFFE74C3C),
                      width: 12,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3)),
                    ),
                  ],
                  barsSpace: 4,
                );
              }),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surface,
                  tooltipBorder: const BorderSide(color: AppColors.border),
                  getTooltipItem: (group, _, rod, rodIndex) {
                    final label = rodIndex == 0 ? 'Entrate' : 'Spese';
                    final color = rodIndex == 0
                        ? const Color(0xFF27AE60)
                        : const Color(0xFFE74C3C);
                    return BarTooltipItem(
                      '$label\n${formatCurrency(rod.toY)}',
                      AppTextStyles.label.copyWith(
                          color: color, fontWeight: FontWeight.w600),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    getTitlesWidget: (v, _) => Text(
                      '€${v.toInt()}',
                      style: AppTextStyles.label,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final d = data[v.toInt()];
                      final dt = DateTime(d.year, d.month);
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(formatMonthShort(dt),
                            style: AppTextStyles.label),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: AppColors.divider,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// --- Line Chart: andamento saldo ---

class _LineChartView extends StatelessWidget {
  final List<TransactionEntry> transactions;
  const _LineChartView({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return _noData('Nessun movimento registrato');

    final sorted = [...transactions]..sort((a, b) => a.date.compareTo(b.date));

    double running = 0;
    final spots = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      final t = sorted[i];
      running += t.type == 'income' ? t.amount : -t.amount;
      spots.add(FlSpot(i.toDouble(), running));
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY).abs() * 0.15 + 50;

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: AppColors.primary,
            barWidth: 2,
            dotData: FlDotData(
              show: spots.length <= 30,
              getDotPainter: (spot, xPercentage, bar, index) => FlDotCirclePainter(
                radius: 3,
                color: AppColors.primary,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.07),
            ),
          ),
        ],
        minY: minY - padding,
        maxY: maxY + padding,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 64,
              getTitlesWidget: (v, _) =>
                  Text(formatCurrency(v), style: AppTextStyles.label),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (spots.length / 4).ceilToDouble(),
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= sorted.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(formatDateShort(sorted[idx].date),
                      style: AppTextStyles.label),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _MonthData {
  final int year;
  final int month;
  double income = 0;
  double expense = 0;

  _MonthData({required this.year, required this.month});
}

Widget _noData(String message) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.bar_chart_outlined, size: 36, color: AppColors.textDisabled),
        const SizedBox(height: 12),
        Text(message, style: AppTextStyles.bodySmall),
      ],
    ),
  );
}

/// Renders a single chart type for off-screen export capture.
class ExportChartWidget extends StatelessWidget {
  final int chartIndex; // 0 = pie, 1 = bar, 2 = line
  final List<TransactionEntry> transactions;

  const ExportChartWidget({
    super.key,
    required this.chartIndex,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: switch (chartIndex) {
        0 => _PieChartView(transactions: transactions),
        1 => _BarChartView(transactions: transactions),
        _ => _LineChartView(transactions: transactions),
      },
    );
  }
}
