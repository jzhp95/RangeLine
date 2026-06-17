import 'package:flutter/foundation.dart';
import 'package:range_line/data/repositories/record_repository.dart';
import 'package:range_line/data/seed/seed_records.dart';

Future<void> importSeedRecordsIfEmpty(RecordRepository repository) async {
  if (!kDebugMode) return;
  if (await repository.hasAnyRecords()) return;

  for (final draft in seedRecordDrafts.reversed) {
    if (draft.type == SeedRecordDraft.fuelType) {
      await repository.addFuelRecord(
        date: draft.date,
        mileage: draft.mileage!,
        fuelAmount: draft.fuelAmount!,
        pricePerL: draft.pricePerL!,
        discountAmount: draft.discountAmount ?? 0,
        isFull: draft.isFull!,
        prevRecorded: draft.prevRecorded!,
        fuelGrade: draft.fuelGrade!,
        station: draft.station ?? '',
        notes: draft.notes ?? '',
      );
    } else {
      await repository.addExpenseRecord(
        date: draft.date,
        category: draft.category!,
        totalCost: draft.totalCost,
        notes: draft.expenseNotes ?? '',
      );
    }
  }
}
