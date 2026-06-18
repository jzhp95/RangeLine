import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_spacing.dart';
import 'package:range_line/app/theme/app_typography.dart';
import 'package:range_line/data/providers/database_providers.dart';
import 'package:range_line/features/history/providers/history_filter_provider.dart';
import 'package:range_line/shared/models/expense_category.dart';
import 'package:range_line/shared/models/expense_record.dart';
import 'package:range_line/shared/models/fuel_grade.dart';
import 'package:range_line/shared/models/fuel_record.dart';
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
        final fuelRecords = records.whereType<FuelRecordItem>().map((e) => e.record).toList();
        final expenseRecords =
            records.whereType<ExpenseRecordItem>().map((e) => e.record).toList();
        final sortedFuel = [...fuelRecords]..sort((a, b) => b.mileage.compareTo(a.mileage));
        Future<void> onDelete(int id) async {
          await ref.read(recordRepositoryProvider).deleteRecord(id);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('记录已删除')),
          );
        }

        Future<void> onEditFuel(FuelRecord record) async {
          final mileageController = TextEditingController(text: record.mileage.toString());
          final amountController =
              TextEditingController(text: record.fuelAmount.toStringAsFixed(1));
          final priceController =
              TextEditingController(text: record.pricePerL.toStringAsFixed(2));
          final discountController =
              TextEditingController(text: record.discountAmount.toStringAsFixed(2));
          final stationController = TextEditingController(text: record.station);
          final notesController = TextEditingController(text: record.notes);
          var isFull = record.isFull;
          var prevRecorded = record.prevRecorded;
          var grade = record.fuelGrade;

          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('编辑加油记录'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: mileageController,
                        decoration: const InputDecoration(labelText: '当前总里程'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        decoration: const InputDecoration(labelText: '本次加油量'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: '机显单价'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: discountController,
                        decoration: const InputDecoration(labelText: '优惠金额'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<FuelGrade>(
                        initialValue: grade,
                        items: FuelGrade.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => grade = v);
                          }
                        },
                        decoration: const InputDecoration(labelText: '油号'),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('本次是否加满'),
                        value: isFull,
                        onChanged: (v) => setState(() => isFull = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('上次是否有记录'),
                        value: prevRecorded,
                        onChanged: (v) => setState(() => prevRecorded = v),
                      ),
                      TextField(
                        controller: stationController,
                        decoration: const InputDecoration(labelText: '加油站（选填）'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: notesController,
                        decoration: const InputDecoration(labelText: '备注（选填）'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('取消'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('保存'),
                  ),
                ],
              ),
            ),
          );

          if (confirmed != true) return;

          final mileage = int.tryParse(mileageController.text.trim());
          final fuelAmount = double.tryParse(amountController.text.trim());
          final price = double.tryParse(priceController.text.trim());
          final discount = double.tryParse(discountController.text.trim()) ?? 0;
          if (mileage == null || mileage <= 0 || fuelAmount == null || fuelAmount <= 0) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('请输入有效的里程和加油量')),
            );
            return;
          }
          await ref.read(recordRepositoryProvider).updateFuelRecord(
                id: record.id,
                date: record.date,
                createdAt: record.createdAt,
                mileage: mileage,
                fuelAmount: fuelAmount,
                pricePerL: price ?? record.pricePerL,
                discountAmount: discount,
                isFull: isFull,
                prevRecorded: prevRecorded,
                fuelGrade: grade,
                station: stationController.text.trim(),
                notes: notesController.text.trim(),
              );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('加油记录已更新')),
          );
        }

        Future<void> onEditExpense(ExpenseRecord record) async {
          final amountController = TextEditingController(
            text: record.totalCost.toStringAsFixed(2),
          );
          final notesController = TextEditingController(text: record.notes);
          var category = record.category;

          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('编辑费用记录'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<ExpenseCategory>(
                        initialValue: category,
                        items: ExpenseCategory.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => category = v);
                          }
                        },
                        decoration: const InputDecoration(labelText: '费用类型'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        decoration: const InputDecoration(labelText: '费用金额'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: notesController,
                        decoration: const InputDecoration(labelText: '备注（选填）'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('取消'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('保存'),
                  ),
                ],
              ),
            ),
          );

          if (confirmed != true) return;
          final amount = double.tryParse(amountController.text.trim());
          if (amount == null || amount <= 0) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('请输入有效的费用金额')),
            );
            return;
          }

          await ref.read(recordRepositoryProvider).updateExpenseRecord(
                id: record.id,
                date: record.date,
                createdAt: record.createdAt,
                category: category,
                totalCost: amount,
                notes: notesController.text.trim(),
              );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('费用记录已更新')),
          );
        }

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
                    '${fuelRecords.length} 次加油 · ${expenseRecords.length} 条其他费用',
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
              child: switch (filter) {
                HistoryFilter.fuel => sortedFuel.isEmpty
                    ? const EmptyState()
                    : _FuelTimeline(
                        records: sortedFuel,
                        onDelete: onDelete,
                        onEdit: onEditFuel,
                      ),
                HistoryFilter.expense => expenseRecords.isEmpty
                    ? const EmptyState()
                    : _ExpenseList(
                        records: expenseRecords,
                        onDelete: onDelete,
                        onEdit: onEditExpense,
                      ),
                HistoryFilter.all => records.isEmpty
                    ? const EmptyState()
                    : _AllMixedList(
                        records: records,
                        onDelete: onDelete,
                        onEditFuel: onEditFuel,
                        onEditExpense: onEditExpense,
                      ),
              },
            ),
          ],
        );
      },
    );
  }
}

class _FuelTimeline extends StatelessWidget {
  const _FuelTimeline({
    required this.records,
    required this.onDelete,
    required this.onEdit,
  });

  final List<FuelRecord> records;
  final Future<void> Function(int id) onDelete;
  final Future<void> Function(FuelRecord record) onEdit;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        14,
        AppSpacing.pageHorizontal,
        28,
      ),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final current = records[index];
        final next = index + 1 < records.length ? records[index + 1] : null;
        return _DeleteDismissible(
          id: current.id,
          onDelete: onDelete,
          onTap: () => onEdit(current),
          child: Column(
            children: [
              _FuelStopWithSpine(
                record: current,
                top: index == 0,
                bottom: index == records.length - 1,
              ),
              if (next != null)
                _SegmentRow(
                  deltaKm: current.mileage - next.mileage,
                  fuelConsumed: current.fuelAmount,
                  consumption: current.consumption,
                  skipped: !current.prevRecorded,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FuelStopWithSpine extends StatelessWidget {
  const _FuelStopWithSpine({
    required this.record,
    required this.top,
    required this.bottom,
  });

  final FuelRecord record;
  final bool top;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Spine(filled: record.isFull, top: top, bottom: bottom),
        const SizedBox(width: 8),
        Expanded(
          child: _FuelStopCard(record: record),
        ),
      ],
    );
  }
}

class _FuelStopCard extends StatelessWidget {
  const _FuelStopCard({required this.record});

  final FuelRecord record;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
                  '${record.fuelAmount.toStringAsFixed(1)} L',
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
          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              record.notes,
              style: AppTypography.label.copyWith(fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({
    required this.deltaKm,
    required this.fuelConsumed,
    required this.consumption,
    required this.skipped,
  });

  final int deltaKm;
  final double fuelConsumed;
  final double? consumption;
  final bool skipped;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SpineLine(),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
            child: skipped
                ? Row(
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 7),
                      Text(
                        '上次漏记里程，此段油耗无法计算',
                        style: AppTypography.label.copyWith(
                          fontSize: 11.5,
                          color: AppColors.warningText,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.label.copyWith(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(text: '行驶 '),
                              TextSpan(
                                text: '$deltaKm',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const TextSpan(text: ' km  ·  耗 '),
                              TextSpan(
                                text: fuelConsumed.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const TextSpan(text: ' L'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ConsumptionText(consumption: consumption),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _Spine extends StatelessWidget {
  const _Spine({
    required this.filled,
    required this.top,
    required this.bottom,
  });

  final bool filled;
  final bool top;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Stack(
        children: [
          Positioned(
            left: 15,
            top: top ? 18 : 0,
            bottom: bottom ? null : 0,
            height: bottom ? 18 : null,
            child: Container(width: 2, color: AppColors.outline),
          ),
          Positioned(
            left: 9.5,
            top: 11.5,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.primary : Colors.white,
                border: Border.all(color: AppColors.primary, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.surface,
                    blurRadius: 0,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpineLine extends StatelessWidget {
  const _SpineLine();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 32,
      child: Center(
        child: SizedBox(width: 2, child: ColoredBox(color: AppColors.outline)),
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList({
    required this.records,
    required this.onDelete,
    required this.onEdit,
  });

  final List<ExpenseRecord> records;
  final Future<void> Function(int id) onDelete;
  final Future<void> Function(ExpenseRecord record) onEdit;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      itemCount: records.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => _DeleteDismissible(
        id: records[index].id,
        onDelete: onDelete,
        onTap: () => onEdit(records[index]),
        child: _ExpenseCard(record: records[index]),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.record});

  final ExpenseRecord record;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
              _iconForCategory(record.category.label),
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
                if (record.notes.isNotEmpty)
                  Text(
                    record.notes,
                    style: AppTypography.label.copyWith(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            '¥${record.totalCost.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String label) {
    switch (label) {
      case '保养':
        return Icons.build_outlined;
      case '洗车':
        return Icons.local_car_wash_outlined;
      case '停车':
        return Icons.local_parking_outlined;
      case '维修':
        return Icons.settings_outlined;
      case '违章':
        return Icons.warning_amber_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }
}

class _AllMixedList extends StatelessWidget {
  const _AllMixedList({
    required this.records,
    required this.onDelete,
    required this.onEditFuel,
    required this.onEditExpense,
  });

  final List<AppRecord> records;
  final Future<void> Function(int id) onDelete;
  final Future<void> Function(FuelRecord record) onEditFuel;
  final Future<void> Function(ExpenseRecord record) onEditExpense;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      itemCount: records.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = records[index];
        return switch (item) {
          FuelRecordItem(:final record) => _DeleteDismissible(
              id: record.id,
              onDelete: onDelete,
              onTap: () => onEditFuel(record),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                backgroundColor: Colors.white,
                child: Column(
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (record.station.isNotEmpty)
                                Text(
                                  '📍 ${record.station}',
                                  style: AppTypography.label.copyWith(fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  GradeBadge(grade: record.fuelGrade),
                                  const SizedBox(width: 6),
                                  FullBadge(isFull: record.isFull),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '¥${record.totalCost.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${record.fuelAmount.toStringAsFixed(1)}L',
                              style: AppTypography.label.copyWith(fontSize: 12),
                            ),
                            if (record.consumption != null)
                              Text(
                                '${record.consumption!.toStringAsFixed(1)} L/100',
                                style: AppTypography.label.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ExpenseRecordItem(:final record) => _DeleteDismissible(
              id: record.id,
              onDelete: onDelete,
              onTap: () => onEditExpense(record),
              child: _ExpenseCard(record: record),
            ),
        };
      },
    );
  }
}

class _DeleteDismissible extends StatelessWidget {
  const _DeleteDismissible({
    required this.id,
    required this.onDelete,
    this.onTap,
    required this.child,
  });

  final int id;
  final Future<void> Function(int id) onDelete;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('record-$id'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete_outline, color: AppColors.danger),
      ),
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('删除记录'),
                content: const Text('确认删除这条记录吗？删除后不可恢复。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('取消'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                    child: const Text('删除'),
                  ),
                ],
              ),
            );
        return confirmed ?? false;
      },
      onDismissed: (_) => onDelete(id),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
