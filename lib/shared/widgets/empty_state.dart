import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.title = '暂无记录',
    this.message = '点击「极速记账」添加第一次加油',
    this.icon = Icons.local_gas_station_outlined,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 28, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTypography.title),
            const SizedBox(height: 6),
            Text(message, style: AppTypography.label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
