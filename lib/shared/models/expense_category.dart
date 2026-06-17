import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_colors.dart';

enum ExpenseCategory {
  maintenance('保养', Color(0xFF7B5EA7)),
  carWash('洗车', Color(0xFF2B7AA6)),
  parking('停车', Color(0xFF8A6D3B)),
  repair('维修', AppColors.danger),
  violation('违章', Color(0xFFE67E22)),
  other('其他', AppColors.onSurfaceVariant);

  const ExpenseCategory(this.label, this.color);
  final String label;
  final Color color;

  static ExpenseCategory fromLabel(String label) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.label == label,
      orElse: () => ExpenseCategory.other,
    );
  }
}
