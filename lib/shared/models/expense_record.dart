import 'package:range_line/shared/models/expense_category.dart';

class ExpenseRecord {
  const ExpenseRecord({
    required this.id,
    required this.date,
    required this.createdAt,
    required this.category,
    required this.totalCost,
    this.notes = '',
  });

  final int id;
  final DateTime date;
  final DateTime createdAt;
  final ExpenseCategory category;
  final double totalCost;
  final String notes;

  ExpenseRecord copyWith({
    int? id,
    DateTime? date,
    DateTime? createdAt,
    ExpenseCategory? category,
    double? totalCost,
    String? notes,
  }) {
    return ExpenseRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      totalCost: totalCost ?? this.totalCost,
      notes: notes ?? this.notes,
    );
  }
}
