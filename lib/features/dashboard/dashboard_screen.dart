import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_spacing.dart';
import 'package:range_line/app/theme/app_typography.dart';
import 'package:range_line/data/providers/database_providers.dart';
import 'package:range_line/shared/models/record.dart';
import 'package:range_line/shared/services/dashboard_calculator.dart';
import 'package:range_line/shared/services/date_formatter.dart';
import 'package:range_line/shared/widgets/hero_card.dart';
import 'package:range_line/shared/widgets/page_scaffold.dart';
import 'package:range_line/shared/widgets/pill_badge.dart';
import 'package:range_line/shared/widgets/section_header.dart';
import 'package:range_line/shared/widgets/stats_grid.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsStreamProvider);

    return recordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (records) {
        final fuel = records.whereType<FuelRecordItem>().map((e) => e.record).toList();
        final expense =
            records.whereType<ExpenseRecordItem>().map((e) => e.record).toList();
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_gas_station_outlined, size: 18, color: AppColors.primary),
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
                    '较上月${stats.trendUp ? '升高' : '降低'} ${stats.trendDiff.abs().toStringAsFixed(1)} L，共 ${stats.fuelRecordCount} 次加油记录',
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
                const SectionHeader(title: '详细统计', trailingLabel: '全部时间'),
                const SizedBox(height: AppSpacing.sm),
                StatsGrid(rows: statsRows),
              ],
            ),
          ],
        );
      },
    );
  }
}
