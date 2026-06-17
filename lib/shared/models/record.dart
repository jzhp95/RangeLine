import 'package:range_line/shared/models/expense_record.dart';
import 'package:range_line/shared/models/fuel_record.dart';

sealed class AppRecord {
  const AppRecord();
}

class FuelRecordItem extends AppRecord {
  const FuelRecordItem(this.record);
  final FuelRecord record;
}

class ExpenseRecordItem extends AppRecord {
  const ExpenseRecordItem(this.record);
  final ExpenseRecord record;
}
