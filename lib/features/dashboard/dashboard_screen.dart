import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_spacing.dart';
import 'package:range_line/app/theme/app_typography.dart';
import 'package:range_line/data/providers/database_providers.dart';
import 'package:range_line/shared/models/expense_record.dart';
import 'package:range_line/shared/models/expense_category.dart';
import 'package:range_line/shared/models/fuel_record.dart';
import 'package:range_line/shared/models/record.dart';
import 'package:range_line/shared/services/dashboard_calculator.dart';
import 'package:range_line/shared/services/date_formatter.dart';
import 'package:range_line/shared/widgets/app_card.dart';
import 'package:range_line/shared/widgets/hero_card.dart';
import 'package:range_line/shared/widgets/page_scaffold.dart';
import 'package:range_line/shared/widgets/pill_badge.dart';
import 'package:range_line/shared/widgets/section_header.dart';
import 'package:range_line/shared/widgets/stats_grid.dart';

enum _DashboardPeriod { all, recentHalfYear, currentYear }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  _DashboardPeriod _period = _DashboardPeriod.all;

  String get _periodLabel => switch (_period) {
        _DashboardPeriod.all => '全部时间',
        _DashboardPeriod.recentHalfYear => '近半年',
        _DashboardPeriod.currentYear => '今年',
      };

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(recordsStreamProvider);

    return recordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (records) {
        final allFuel = records.whereType<FuelRecordItem>().map((e) => e.record).toList();
        final allExpense = records.whereType<ExpenseRecordItem>().map((e) => e.record).toList();
        final now = DateTime.now();
        final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
        bool inPeriod(DateTime d) => switch (_period) {
              _DashboardPeriod.all => true,
              _DashboardPeriod.recentHalfYear =>
                d.isAfter(sixMonthsAgo.subtract(const Duration(days: 1))),
              _DashboardPeriod.currentYear => d.year == now.year,
            };

        final fuel = allFuel.where((r) => inPeriod(r.date)).toList();
        final expense = allExpense.where((r) => inPeriod(r.date)).toList();
        final stats = DashboardCalculator.compute(
          fuelRecords: fuel,
          expenseRecords: expense,
        );

        final statsRows = [
          [
            StatCell(
              value: '${stats.totalMiles > 0 ? stats.totalMiles : stats.currentMileage} km',
              label: '累计行程',
            ),
            StatCell(
              value: stats.avgTrip > 0 ? '${stats.avgTrip.toStringAsFixed(0)} km/次' : '— km/次',
              label: '平均行程',
            ),
          ],
          [
            StatCell(value: '¥${stats.totalFuelCost.toStringAsFixed(0)}', label: '累计油费'),
            StatCell(value: '¥${stats.avgFuelCost.toStringAsFixed(0)}/次', label: '平均油费'),
          ],
          [
            StatCell(value: '${stats.totalFuelAmount.toStringAsFixed(1)} L', label: '累计加油量'),
            StatCell(
              value: '¥${stats.totalSavings.toStringAsFixed(0)}',
              label: '累计优惠',
              highlight: stats.totalSavings > 0,
            ),
          ],
          [
            StatCell(value: '${stats.fuelRecordCount} 次', label: '累计加油次数'),
            StatCell(
              value: '¥${stats.totalSpending.toStringAsFixed(0)}',
              label: '累计总支出',
            ),
          ],
        ];

        return PageScaffold(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormatter.monthYear(DateTime.now()), style: AppTypography.label),
                    const Text('数据看板', style: AppTypography.headline),
                  ],
                ),
                PopupMenuButton<_DashboardPeriod>(
                  tooltip: '统计周期',
                  initialValue: _period,
                  onSelected: (v) => setState(() => _period = v),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _DashboardPeriod.all,
                      child: Text('全部时间'),
                    ),
                    PopupMenuItem(
                      value: _DashboardPeriod.recentHalfYear,
                      child: Text('近半年'),
                    ),
                    PopupMenuItem(
                      value: _DashboardPeriod.currentYear,
                      child: Text('今年'),
                    ),
                  ],
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tune, size: 18, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            HeroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '平均油耗',
                    style: AppTypography.label.copyWith(color: AppColors.onPrimaryContainer.withValues(alpha: 0.65)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        stats.avgConsumption > 0 ? stats.avgConsumption.toStringAsFixed(1) : '—',
                        style: AppTypography.display.copyWith(color: AppColors.onPrimaryContainer),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6, bottom: 8),
                        child: Text(
                          'L/100km',
                          style: AppTypography.label.copyWith(
                            color: AppColors.onPrimaryContainer.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      if (stats.showTrend) ...[
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PillBadge(
                            label: '${stats.trendUp ? '↑' : '↓'} ${stats.trendDiff.abs().toStringAsFixed(1)}',
                            backgroundColor: stats.trendUp
                                ? AppColors.danger.withValues(alpha: 0.12)
                                : AppColors.primary.withValues(alpha: 0.12),
                            foregroundColor: stats.trendUp ? AppColors.danger : AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stats.showTrend
                        ? '较上月${stats.trendUp ? '升高' : '降低'} ${stats.trendDiff.abs().toStringAsFixed(1)} L，共 ${stats.fuelRecordCount} 次加油记录'
                        : '共 ${stats.fuelRecordCount} 次加油记录',
                    style: AppTypography.label.copyWith(
                      color: AppColors.onPrimaryContainer.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: AppColors.onPrimaryContainer.withValues(alpha: 0.15), height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '当前里程',
                              style: AppTypography.label.copyWith(
                                color: AppColors.onPrimaryContainer.withValues(alpha: 0.65),
                              ),
                            ),
                            Text(
                              '${stats.currentMileage} km',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 36, color: AppColors.onPrimaryContainer.withValues(alpha: 0.15)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '总支出',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.onPrimaryContainer.withValues(alpha: 0.65),
                                ),
                              ),
                              Text(
                                '¥${stats.totalSpending.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: '详细统计', trailingLabel: _periodLabel),
                const SizedBox(height: AppSpacing.sm),
                StatsGrid(rows: statsRows),
              ],
            ),
            _TrendCard(records: fuel),
            _CostBreakdownCard(
              fuelTotal: stats.totalFuelCost,
              expenseTotal: stats.totalExpenseCost,
            ),
            _MaintenanceCard(
              remainingKm: _estimateRemainingMaintenanceKm(
                fuelRecords: allFuel,
                expenseRecords: allExpense,
                currentMileage: stats.currentMileage,
              ),
            ),
          ],
        );
      },
    );
  }

  int _estimateRemainingMaintenanceKm({
    required List<FuelRecord> fuelRecords,
    required List<ExpenseRecord> expenseRecords,
    required int currentMileage,
  }) {
    final maintenance = expenseRecords
        .where((e) => e.category == ExpenseCategory.maintenance)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (maintenance.isEmpty || fuelRecords.isEmpty) {
      return 2300;
    }
    final latestMaintenance = maintenance.first;

    final beforeOrOn = fuelRecords
        .where(
          (f) =>
              f.date.isBefore(latestMaintenance.date.add(const Duration(days: 1))),
        )
        .toList()
      ..sort((a, b) => b.mileage.compareTo(a.mileage));

    final baselineMileage = beforeOrOn.isNotEmpty ? beforeOrOn.first.mileage : currentMileage;
    return (baselineMileage + 5000 - currentMileage);
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.records});

  final List<FuelRecord> records;

  @override
  Widget build(BuildContext context) {
    final points = _buildTrendPoints(records);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: '油耗趋势', trailingLabel: '近半年'),
          const SizedBox(height: AppSpacing.md),
          if (points.length < 2)
            const SizedBox(
              height: 120,
              child: Center(
                child: Text('有效油耗记录不足，无法绘制趋势', style: AppTypography.label),
              ),
            )
          else
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  minY: points.map((e) => e.value).reduce((a, b) => a < b ? a : b) - 0.4,
                  maxY: points.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 0.4,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: AppColors.outline),
                    ),
                  ),
                  lineTouchData: const LineTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= points.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(points[idx].label, style: AppTypography.label.copyWith(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: points.map((e) => e.value).reduce((a, b) => a + b) / points.length,
                        color: AppColors.outline,
                        strokeWidth: 1,
                        dashArray: const [4, 4],
                      ),
                    ],
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < points.length; i++)
                          FlSpot(i.toDouble(), points[i].value),
                      ],
                      isCurved: false,
                      color: AppColors.primary,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryContainer.withValues(alpha: 0.5),
                            AppColors.primaryContainer.withValues(alpha: 0),
                          ],
                        ),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: AppColors.primary,
                            strokeWidth: 3,
                            strokeColor: AppColors.primaryContainer,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<_TrendPoint> _buildTrendPoints(List<FuelRecord> records) {
    final valid = records.where((r) => r.consumption != null).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final latest = valid.length > 6 ? valid.sublist(valid.length - 6) : valid;
    return latest
        .map(
          (r) => _TrendPoint(
            label: '${r.date.month}月',
            value: r.consumption!,
          ),
        )
        .toList();
  }
}

class _CostBreakdownCard extends StatelessWidget {
  const _CostBreakdownCard({
    required this.fuelTotal,
    required this.expenseTotal,
  });

  final double fuelTotal;
  final double expenseTotal;

  @override
  Widget build(BuildContext context) {
    final total = (fuelTotal + expenseTotal) == 0 ? 1 : (fuelTotal + expenseTotal);
    final fuelPct = fuelTotal / total;
    final expensePct = expenseTotal / total;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('费用结构', style: AppTypography.title),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: (fuelPct * 1000).round().clamp(1, 999),
                    child: Container(color: AppColors.primary),
                  ),
                  Expanded(
                    flex: (expensePct * 1000).round().clamp(1, 999),
                    child: Container(color: AppColors.outline),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _legendItem(
                color: AppColors.primary,
                text: '燃油费  ¥${fuelTotal.toStringAsFixed(0)} (${(fuelPct * 100).toStringAsFixed(0)}%)',
              ),
              _legendItem(
                color: AppColors.outline,
                text: '保养/洗车  ¥${expenseTotal.toStringAsFixed(0)} (${(expensePct * 100).toStringAsFixed(0)}%)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem({required Color color, required String text}) {
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
        Text(text, style: AppTypography.label),
      ],
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  const _MaintenanceCard({required this.remainingKm});

  final int remainingKm;

  @override
  Widget build(BuildContext context) {
    final overdue = remainingKm < 0;
    return AppCard(
      onTap: () {},
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.build_outlined, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('智能保养预测', style: AppTypography.label),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
                    children: [
                      const TextSpan(text: '距离下次保养还剩 '),
                      TextSpan(
                        text: overdue
                            ? '${remainingKm.abs().toString()} km（已超）'
                            : '${remainingKm.toString()} km',
                        style: TextStyle(
                          color: overdue ? AppColors.danger : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _TrendPoint {
  const _TrendPoint({required this.label, required this.value});
  final String label;
  final double value;
}
