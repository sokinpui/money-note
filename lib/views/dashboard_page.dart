import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/record.dart';
import '../providers/record_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(weeklySummaryProvider);
    final recordsAsync = ref.watch(recordProvider);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          summaryAsync.when(
            data: (summary) => Row(
              children: [
                Expanded(child: _SummaryCard(title: '7 Days', value: summary['week']!, color: Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _SummaryCard(title: '30 Days', value: summary['month']!, color: Colors.orange)),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('${l10n.error}: $e'),
          ),
          const SizedBox(height: 32),
          Text(l10n.dashboard, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: recordsAsync.when(
              data: (records) => _CategoryPieChart(records: records),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: recordsAsync.when(
              data: (records) => _buildChart(records),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<Record> records) {
    final now = DateTime.now();
    final List<BarChartGroupData> groups = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      double dailyTotal = 0;
      
      for (var record in records) {
        if (record.date.year == date.year && record.date.month == date.month && record.date.day == date.day) {
          if (record.type == 'Income') {
            dailyTotal += record.value;
          } else {
            dailyTotal -= record.value;
          }
        }
      }

      groups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: dailyTotal,
              color: dailyTotal >= 0 ? Colors.green : Colors.red,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: groups,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = now.subtract(Duration(days: 6 - value.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(DateFormat('E').format(date).substring(0, 1)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;

  const _SummaryCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: color)),
            const SizedBox(height: 8),
            Text(
              '${value >= 0 ? "+" : ""}${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: value >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final List<Record> records;
  const _CategoryPieChart({required this.records});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> categoryTotals = {};
    for (var record in records.where((r) => r.type == 'Expense')) {
      categoryTotals[record.category] = (categoryTotals[record.category] ?? 0) + record.value;
    }

    if (categoryTotals.isEmpty) {
      return const Center(child: Text('No expense data'));
    }

    final List<PieChartSectionData> sections = [];
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.yellow, Colors.purple, Colors.orange];
    int colorIndex = 0;

    categoryTotals.forEach((category, value) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: value,
          title: category,
          radius: 80,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
      colorIndex++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }
}
