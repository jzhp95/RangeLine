import 'package:drift/drift.dart';
import 'package:range_line/data/database/app_database.dart';
import 'package:range_line/shared/models/expense_category.dart';
import 'package:range_line/shared/models/expense_record.dart';
import 'package:range_line/shared/models/fuel_grade.dart';
import 'package:range_line/shared/models/fuel_record.dart';
import 'package:range_line/shared/models/record.dart';
import 'package:range_line/shared/services/consumption_calculator.dart';
import 'package:range_line/shared/services/fuel_calculator.dart';

class RecordRepository {
  RecordRepository(this._db);

  final AppDatabase _db;

  Stream<List<AppRecord>> watchAllRecords() => _db.watchAllRecords();

  Future<List<FuelRecord>> getFuelRecords() => _db.getFuelRecords();

  Future<List<ExpenseRecord>> getExpenseRecords() => _db.getExpenseRecords();

  Future<FuelRecord> addFuelRecord({
    required DateTime date,
    required int mileage,
    required double fuelAmount,
    required double pricePerL,
    required double discountAmount,
    required bool isFull,
    required bool prevRecorded,
    required FuelGrade fuelGrade,
    String station = '',
    String notes = '',
  }) async {
    final pumpTotal = FuelCalculator.calcPumpTotal(fuelAmount, pricePerL) ?? 0;
    final totalCost = FuelCalculator.calcActualTotal(pumpTotal, discountAmount);

    final previous = await _db.getPreviousFuelRecord(mileage);
    final consumption = ConsumptionCalculator.calcConsumption(
      currentMileage: mileage,
      previousMileage: previous?.mileage,
      fuelAmount: fuelAmount,
      isFull: isFull,
      prevRecorded: prevRecorded,
    );

    final now = DateTime.now();
    final id = await _db.insertFuelRecord(
      RecordsCompanion.insert(
        type: 'fuel',
        date: date,
        createdAt: now,
        mileage: Value(mileage),
        fuelAmount: Value(fuelAmount),
        pricePerL: Value(pricePerL),
        discountAmount: Value(discountAmount),
        totalCost: totalCost,
        isFull: Value(isFull),
        prevRecorded: Value(prevRecorded),
        fuelGrade: Value(fuelGrade.code),
        station: Value(station),
        notes: Value(notes),
        consumption: Value(consumption),
      ),
    );
    await _recomputeFuelConsumptions();

    return FuelRecord(
      id: id,
      date: date,
      createdAt: now,
      mileage: mileage,
      fuelAmount: fuelAmount,
      pricePerL: pricePerL,
      discountAmount: discountAmount,
      totalCost: totalCost,
      isFull: isFull,
      prevRecorded: prevRecorded,
      fuelGrade: fuelGrade,
      station: station,
      notes: notes,
      consumption: consumption,
    );
  }

  Future<ExpenseRecord> addExpenseRecord({
    required DateTime date,
    required ExpenseCategory category,
    required double totalCost,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final id = await _db.insertExpenseRecord(
      RecordsCompanion.insert(
        type: 'expense',
        date: date,
        createdAt: now,
        totalCost: totalCost,
        category: Value(category.label),
        notes: Value(notes),
      ),
    );

    return ExpenseRecord(
      id: id,
      date: date,
      createdAt: now,
      category: category,
      totalCost: totalCost,
      notes: notes,
    );
  }

  Future<FuelRecord> updateFuelRecord({
    required int id,
    required DateTime date,
    required DateTime createdAt,
    required int mileage,
    required double fuelAmount,
    required double pricePerL,
    required double discountAmount,
    required bool isFull,
    required bool prevRecorded,
    required FuelGrade fuelGrade,
    String station = '',
    String notes = '',
  }) async {
    final pumpTotal = FuelCalculator.calcPumpTotal(fuelAmount, pricePerL) ?? 0;
    final totalCost = FuelCalculator.calcActualTotal(pumpTotal, discountAmount);

    final previous = await _db.getPreviousFuelRecordExcluding(
      beforeMileage: mileage,
      excludeId: id,
    );
    final consumption = ConsumptionCalculator.calcConsumption(
      currentMileage: mileage,
      previousMileage: previous?.mileage,
      fuelAmount: fuelAmount,
      isFull: isFull,
      prevRecorded: prevRecorded,
    );

    await _db.updateRecord(
      _fuelCompanion(
        record: FuelRecord(
          id: id,
          date: date,
          createdAt: createdAt,
          mileage: mileage,
          fuelAmount: fuelAmount,
          pricePerL: pricePerL,
          discountAmount: discountAmount,
          totalCost: totalCost,
          isFull: isFull,
          prevRecorded: prevRecorded,
          fuelGrade: fuelGrade,
          station: station,
          notes: notes,
          consumption: consumption,
        ),
      ),
    );
    await _recomputeFuelConsumptions();

    return FuelRecord(
      id: id,
      date: date,
      createdAt: createdAt,
      mileage: mileage,
      fuelAmount: fuelAmount,
      pricePerL: pricePerL,
      discountAmount: discountAmount,
      totalCost: totalCost,
      isFull: isFull,
      prevRecorded: prevRecorded,
      fuelGrade: fuelGrade,
      station: station,
      notes: notes,
      consumption: consumption,
    );
  }

  Future<ExpenseRecord> updateExpenseRecord({
    required int id,
    required DateTime date,
    required DateTime createdAt,
    required ExpenseCategory category,
    required double totalCost,
    String notes = '',
  }) async {
    await _db.updateRecord(
      RecordsCompanion(
        id: Value(id),
        type: const Value('expense'),
        date: Value(date),
        createdAt: Value(createdAt),
        mileage: const Value(null),
        fuelAmount: const Value(null),
        pricePerL: const Value(null),
        discountAmount: const Value(0),
        totalCost: Value(totalCost),
        isFull: const Value(null),
        prevRecorded: const Value(null),
        fuelGrade: const Value(null),
        station: const Value(''),
        category: Value(category.label),
        notes: Value(notes),
        consumption: const Value(null),
      ),
    );

    return ExpenseRecord(
      id: id,
      date: date,
      createdAt: createdAt,
      category: category,
      totalCost: totalCost,
      notes: notes,
    );
  }

  Future<void> deleteRecord(int id) async {
    await _db.deleteRecord(id);
    await _recomputeFuelConsumptions();
  }

  Future<bool> hasAnyRecords() => _db.hasAnyRecords();

  Future<void> _recomputeFuelConsumptions() async {
    final records = await _db.getFuelRecords();
    if (records.isEmpty) return;

    final sorted = [...records]
      ..sort((a, b) {
        final byMileage = a.mileage.compareTo(b.mileage);
        if (byMileage != 0) return byMileage;
        return a.createdAt.compareTo(b.createdAt);
      });

    for (var i = 0; i < sorted.length; i++) {
      final current = sorted[i];
      int? previousMileage;
      for (var j = i - 1; j >= 0; j--) {
        if (sorted[j].mileage < current.mileage) {
          previousMileage = sorted[j].mileage;
          break;
        }
      }

      final recomputed = ConsumptionCalculator.calcConsumption(
        currentMileage: current.mileage,
        previousMileage: previousMileage,
        fuelAmount: current.fuelAmount,
        isFull: current.isFull,
        prevRecorded: current.prevRecorded,
      );

      if (_equalsNullableDouble(current.consumption, recomputed)) continue;

      await _db.updateRecord(
        _fuelCompanion(record: current, consumptionOverride: recomputed),
      );
    }
  }

  RecordsCompanion _fuelCompanion({
    required FuelRecord record,
    double? consumptionOverride,
  }) {
    return RecordsCompanion(
      id: Value(record.id),
      type: const Value('fuel'),
      date: Value(record.date),
      createdAt: Value(record.createdAt),
      mileage: Value(record.mileage),
      fuelAmount: Value(record.fuelAmount),
      pricePerL: Value(record.pricePerL),
      discountAmount: Value(record.discountAmount),
      totalCost: Value(record.totalCost),
      isFull: Value(record.isFull),
      prevRecorded: Value(record.prevRecorded),
      fuelGrade: Value(record.fuelGrade.code),
      station: Value(record.station),
      notes: Value(record.notes),
      consumption: Value(consumptionOverride ?? record.consumption),
      category: const Value(null),
    );
  }

  bool _equalsNullableDouble(double? a, double? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return (a - b).abs() < 0.0001;
  }
}
