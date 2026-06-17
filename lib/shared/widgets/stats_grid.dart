import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_radius.dart';

class StatCell {
  const StatCell({
    required this.value,
    required this.label,
    this.highlight = false,
    this.accentUp,
    this.accentValue,
  });

  final String value;
  final String label;
  final bool highlight;
  final bool? accentUp;
  final String? accentValue;
}

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.rows});

  final List<List<StatCell>> rows;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          for (var ri = 0; ri < rows.length; ri++)
            Row(
              children: [
                for (var ci = 0; ci < rows[ri].length; ci++)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          right: ci < rows[ri].length - 1
                              ? const BorderSide(color: AppColors.outline)
                              : BorderSide.none,
                          bottom: ri < rows.length - 1
                              ? const BorderSide(color: AppColors.outline)
                              : BorderSide.none,
                        ),
                      ),
                      child: _StatCellView(cell: rows[ri][ci]),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatCellView extends StatelessWidget {
  const _StatCellView({required this.cell});

  final StatCell cell;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cell.accentUp != null && cell.accentValue != null) ...[
          Text(
            '${cell.accentUp! ? '↑ 较上月' : '↓ 较上月'}  ${cell.accentValue}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cell.accentUp! ? AppColors.danger : AppColors.primary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          cell.value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: cell.highlight ? AppColors.primary : AppColors.onSurface,
            height: 1.2,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          cell.label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
