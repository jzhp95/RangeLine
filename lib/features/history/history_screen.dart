import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_spacing.dart';
import 'package:range_line/app/theme/app_typography.dart';
import 'package:range_line/data/providers/database_providers.dart';
import 'package:range_line/features/history/providers/history_filter_provider.dart';
import 'package:range_line/shared/models/record.dart';
import 'package:range_line/shared/services/date_formatter.dart';
import 'package:range_line/shared/widgets/app_card.dart';
import 'package:range_line/shared/widgets/category_badge.dart';
import 'package:range_line/shared/widgets/consumption_text.dart';
import 'package:range_line/shared/widgets/empty_state.dart';
import 'package:range_line/shared/widgets/filter_tabs.dart';
import 'package:range_line/shared/widgets/full_badge.dart';
import 'package:range_line/shared/widgets/grade_badge.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsStreamProvider);
    final filter = ref.watch(historyFilterProvider);

    return recordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (records) {
        final fuel = records.whereType<FuelRecordItem>().map((e) => e.record).toList();
        final expense =
            records.whereType<ExpenseRecordItem>().map((e) => e.record).toList();

        final filtered = switch (filter) {
          HistoryFilter.all => records,
          HistoryFilter.fuel => records.whereType<FuelRecordItem>().toList(),
          HistoryFilter.expense => records.whereType<ExpenseRecordItem>().toList(),
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                16,
                AppSpacing.pageHorizontal,
                8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('历史明细', style: AppTypography.headline),
                  const SizedBox(height: 2),
                  Text(
                    '${fuel.length} 次加油 · ${expense.length} 条其他费用',
                    style: AppTypography.label,
                  ),
                ],
              ),
            ),
            FilterTabs(
              options: HistoryFilter.values.map((f) => f.label).toList(),
              value: filter.label,
              onChanged: (label) {
                ref.read(historyFilterProvider.notifier).state =
                    HistoryFilterLabel.fromLabel(label);
              },
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return switch (item) {
                          FuelRecordItem(:final record) => AppCard(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                              backgroundColor: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormatter.monthDay(record.date),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (record.station.isNotEmpty)
                                              Text(
                                                '📍 ${record.station}',
                                                style: AppTypography.label.copyWith(fontSize: 11.5),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '¥${record.totalCost.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (record.discountAmount > 0)
                                            Text(
                                              '省 ¥${record.discountAmount.toStringAsFixed(2)}',
                                              style: AppTypography.label.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceContainer,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${record.fuelAmount} L',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '里程 ${record.mileage} km',
                                        style: AppTypography.label.copyWith(fontSize: 12),
                                      ),
                                      const Spacer(),
                                      GradeBadge(grade: record.fuelGrade),
                                      const SizedBox(width: 6),
                                      FullBadge(isFull: record.isFull),
                                    ],
                                  ),
                                  if (record.consumption != null) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ConsumptionText(consumption: record.consumption),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ExpenseRecordItem(:final record) => AppCard(
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: record.category.color.withValues(alpha: 0.094),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.receipt_long_outlined,
                                      color: record.category.color,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CategoryBadge(category: record.category),
                                        Text(
                                          DateFormatter.monthDay(record.date),
                                          style: AppTypography.label.copyWith(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '¥${record.totalCost.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                        };
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
