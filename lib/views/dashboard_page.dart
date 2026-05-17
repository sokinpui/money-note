import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../providers/record_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(weeklySummaryProvider);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: summaryAsync.when(
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DailySummaryCard(
              dailyData: data['dailyData'],
              avg7Days: data['avg7Days'],
              avg30Days: data['avg30Days'],
            ),
            const SizedBox(height: 24),
            _NetEarningsCard(
              monthlyData: data['monthlyData'],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
      ),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  final List<Map<String, dynamic>> dailyData;
  final double avg7Days;
  final double avg30Days;

  const _DailySummaryCard({
    required this.dailyData,
    required this.avg7Days,
    required this.avg30Days,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.dailySummary, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const Row(
                  children: [
                    Icon(Icons.arrow_drop_down, size: 30),
                    SizedBox(width: 8),
                    Icon(Icons.edit_note, size: 28),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          rod.toY > 0 ? 'HK\$${rod.toY.toInt()}' : '',
                          TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final date = dailyData[value.toInt()]['date'] as DateTime;
                          return SideTitleWidget(
                            meta: meta,
                            space: 8,
                            child: Text(
                              DateFormat('E').format(date),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1)),
                  ),
                  barGroups: dailyData.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      showingTooltipIndicators: [0],
                      barRods: [
                        BarChartRodData(
                          toY: e.value['expense'],
                          color: const Color(0xFFE94D76),
                          width: 35,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                l10n.expense,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            _buildAverageRow(l10n.daysAverage(7), avg7Days),
            _buildAverageRow(l10n.daysAverage(30), avg30Days),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (var d in dailyData) {
      if (d['expense'] > max) max = d['expense'];
    }
    return max * 1.3; // Give some space for tooltips
  }

  Widget _buildAverageRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 15))),
          Expanded(
            flex: 3,
            child: Text(
              '-HK\$${value.toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFFE94D76), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetEarningsCard extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const _NetEarningsCard({required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.netEarnings, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const Row(
                  children: [
                    Icon(Icons.arrow_drop_down, size: 30),
                    SizedBox(width: 8),
                    Icon(Icons.edit_note, size: 28),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final date = monthlyData[value.toInt()]['month'] as DateTime;
                          return SideTitleWidget(
                            meta: meta,
                            space: 8,
                            child: Text(
                              DateFormat('MMM').format(date),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            space: 8,
                            child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.colorScheme.outlineVariant,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
                      left: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
                    ),
                  ),
                  barGroups: monthlyData.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value['expense'],
                          color: const Color(0xFFE94D76),
                          width: 40,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: e.value['income'],
                          color: const Color(0xFF4DB68E),
                          width: 40,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTypeHeader(l10n),
            const SizedBox(height: 8),
            _buildDataRow(l10n.income, const Color(0xFF4DB68E), (d) => d['income'], false),
            _buildDataRow(l10n.expense, const Color(0xFFE94D76), (d) => d['expense'], true),
            _buildDataRow(l10n.netEarnings, const Color(0xFF4A90E2), (d) => d['net'], false, isNet: true),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (var d in monthlyData) {
      if (d['income'] > max) max = d['income'];
      if (d['expense'] > max) max = d['expense'];
    }
    return (max / 1000).ceil() * 1000.0 + 1000;
  }

  Widget _buildTypeHeader(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(flex: 3, child: Text(l10n.type, style: const TextStyle(fontWeight: FontWeight.bold))),
        ...monthlyData.skip(1).map((d) => Expanded(
              flex: 3,
              child: Text(
                DateFormat('MMM').format(d['month']),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )),
      ],
    );
  }

  Widget _buildDataRow(String label, Color color, double Function(Map<String, dynamic>) getter, bool isNegative, {bool isNet = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          ...monthlyData.skip(1).map((d) {
            final val = getter(d);
            final displayVal = val.abs().toStringAsFixed(2);
            final isNeg = isNet ? val < 0 : isNegative;
            final textColor = isNet ? (val >= 0 ? const Color(0xFF4DB68E) : const Color(0xFFE94D76)) : color;
            return Expanded(
              flex: 3,
              child: Text(
                '${isNeg ? "-" : ""}HK\$$displayVal',
                textAlign: TextAlign.right,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            );
          }),
        ],
      ),
    );
  }
}
