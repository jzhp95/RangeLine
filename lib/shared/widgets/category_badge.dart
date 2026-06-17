import 'package:flutter/material.dart';
import 'package:range_line/shared/models/expense_category.dart';

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.094),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: category.color,
        ),
      ),
    );
  }
}
