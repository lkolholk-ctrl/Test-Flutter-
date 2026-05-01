import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/category.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TaskProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = provider.getStatistics();
    final completion = provider.getCompletionStats();
    final total = provider.totalCount;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Статистика',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSummaryCards(context, provider),
          ),
          if (total > 0) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Выполнено vs Активно',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildCompletionChart(context, completion),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'По категориям',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildCategoryChart(context, stats),
            ),
          ] else
            const SliverFillRemaining(
              child: Center(
                child: Text('Недостаточно данных для статистики'),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _SummaryCard(
            label: 'Всего',
            value: provider.totalCount.toString(),
            color: const Color(0xFF6366F1),
            icon: Icons.format_list_bulleted,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            label: 'Выполнено',
            value: provider.completedCount.toString(),
            color: const Color(0xFF10B981),
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            label: 'Высокий приоритет',
            value: provider.highPriorityCount.toString(),
            color: const Color(0xFFEF4444),
            icon: Icons.priority_high,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionChart(BuildContext context, Map<String, int> data) {
    final completed = data['completed'] ?? 0;
    final pending = data['pending'] ?? 0;
    final total = completed + pending;

    if (total == 0) return const SizedBox();

    final sections = [
      PieChartSectionData(
        color: const Color(0xFF10B981),
        value: completed.toDouble(),
        title: completed > 0 ? '$completed' : '',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFFF59E0B),
        value: pending.toDouble(),
        title: pending > 0 ? '$pending' : '',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(
                  color: const Color(0xFF10B981),
                  label: 'Выполнено',
                  value: completed,
                ),
                const SizedBox(width: 24),
                _LegendItem(
                  color: const Color(0xFFF59E0B),
                  label: 'Активно',
                  value: pending,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(BuildContext context, Map<String, int> stats) {
    final categories = stats.entries.toList();
    if (categories.isEmpty) return const SizedBox();

    final maxValue = categories.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: (maxValue + 1).toDouble(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final cat = TaskCategory.getById(categories[groupIndex].key);
                        return BarTooltipItem(
                          '${cat.name}\n${rod.toY.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= categories.length) {
                            return const SizedBox();
                          }
                          final cat = TaskCategory.getById(categories[index].key);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Icon(cat.icon, size: 18, color: cat.color),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(categories.length, (index) {
                    final cat = TaskCategory.getById(categories[index].key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: categories[index].value.toDouble(),
                          color: cat.color,
                          width: 24,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: categories.map((entry) {
                final cat = TaskCategory.getById(entry.key);
                return _LegendItem(
                  color: cat.color,
                  label: cat.name,
                  value: entry.value,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(width: 4),
        Text(
          '($value)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
