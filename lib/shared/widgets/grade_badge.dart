import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/shared/models/fuel_grade.dart';

class GradeBadge extends StatelessWidget {
  const GradeBadge({super.key, required this.grade});

  final FuelGrade grade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        grade.label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 1.6,
          color: AppColors.onPrimaryContainer,
        ),
      ),
    );
  }
}
