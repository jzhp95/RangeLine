import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_radius.dart';
import 'package:range_line/app/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor = AppColors.surfaceContainer,
    this.borderRadius = AppRadius.card,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );

    final decoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.outline),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Ink(decoration: decoration, child: content),
        ),
      );
    }

    return DecoratedBox(decoration: decoration, child: content);
  }
}
