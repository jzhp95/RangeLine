import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_typography.dart';
import 'package:range_line/shared/widgets/pill_badge.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailingLabel,
    this.trailing,
  });

  final String title;
  final String? trailingLabel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTypography.title),
        const Spacer(),
        if (trailing != null)
          trailing!
        else if (trailingLabel != null)
          PillBadge(
            label: trailingLabel!,
            foregroundColor: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
      ],
    );
  }
}
