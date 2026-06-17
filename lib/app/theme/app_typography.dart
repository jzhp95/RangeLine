import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_colors.dart';

abstract final class AppTypography {
  static const display = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    height: 1.1,
  );

  static const headline = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.3,
  );

  static const title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
    height: 1.4,
  );

  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.5,
  );

  static const label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    height: 1.4,
  );
}
