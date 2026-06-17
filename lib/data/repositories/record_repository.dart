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

  Future<void> deleteRecord(int id) => _db.deleteRecord(id);

  Future<bool> hasAnyRecords() => _db.hasAnyRecords();
}
