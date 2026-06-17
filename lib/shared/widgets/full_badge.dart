import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_colors.dart';

class FullBadge extends StatelessWidget {
  const FullBadge({super.key, required this.isFull});

  final bool isFull;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isFull ? AppColors.primary : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
        border: isFull ? null : Border.all(color: AppColors.outline),
      ),
      child: Text(
        isFull ? '满油' : '未满',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          height: 1.6,
          color: isFull ? AppColors.onPrimary : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
