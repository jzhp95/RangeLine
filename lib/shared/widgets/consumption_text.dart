import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_typography.dart';

class ConsumptionText extends StatelessWidget {
  const ConsumptionText({
    super.key,
    required this.consumption,
    this.valueStyle,
  });

  final double? consumption;
  final TextStyle? valueStyle;

  static Color colorFor(double? consumption) {
    if (consumption == null) return AppColors.onSurfaceVariant;
    if (consumption < 7.5) return AppColors.primary;
    if (consumption > 8.5) return AppColors.danger;
    return AppColors.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(consumption);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          consumption != null ? consumption!.toStringAsFixed(1) : '—',
          style: (valueStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)).copyWith(
            color: color,
            height: 1,
          ),
        ),
        const SizedBox(width: 3),
        Text('L/100km', style: AppTypography.label.copyWith(fontSize: 10.5)),
      ],
    );
  }
}
