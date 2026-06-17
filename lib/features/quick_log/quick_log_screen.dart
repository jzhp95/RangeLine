import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_spacing.dart';
import 'package:range_line/app/theme/app_typography.dart';

class QuickLogScreen extends StatelessWidget {
  const QuickLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Text(
          '极速记账\n（Phase 3 实现）',
          textAlign: TextAlign.center,
          style: AppTypography.headline,
        ),
      ),
    );
  }
}
