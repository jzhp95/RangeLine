import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:range_line/data/database/tables/records_table.dart';
import 'package:range_line/data/database/tables/vehicle_table.dart';
import 'package:range_line/shared/models/expense_category.dart';
import 'package:range_line/shared/models/expense_record.dart';
import 'package:range_line/shared/models/fuel_grade.dart';
import 'package:range_line/shared/models/fuel_record.dart';
import 'package:range_line/shared/models/record.dart';
import 'package:range_line/shared/models/vehicle.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Records, Vehicles])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  static Future<AppDatabase> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'range_line.db'));
    return AppDatabase(NativeDatabase.createInBackground(file));
  }

  Stream<List<AppRecord>> watchAllRecords() {
    return (select(records)
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .watch()
        .map(_mapRows);
  }

  Future<List<FuelRecord>> getFuelRecords() async {
    final rows = await (select(records)
          ..where((t) => t.type.equals('fuel'))
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
    return rows.map(_toFuelRecord).toList();
  }

  Future<List<ExpenseRecord>> getExpenseRecords() async {
    final rows = await (select(records)
          ..where((t) => t.type.equals('expense'))
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
    return rows.map(_toExpenseRecord).toList();
  }

  Future<FuelRecord?> getPreviousFuelRecord(int beforeMileage) async {
    final rows = await (select(records)
          ..where(
            (t) =>
                t.type.equals('fuel') &
                t.mileage.isSmallerThanValue(beforeMileage),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.mileage)]))
        .get();
    if (rows.isEmpty) return null;
    return _toFuelRecord(rows.first);
  }

  Future<FuelRecord?> getPreviousFuelRecordExcluding({
    required int beforeMileage,
    required int excludeId,
  }) async {
    final rows = await (select(records)
          ..where(
            (t) =>
                t.type.equals('fuel') &
                t.mileage.isSmallerThanValue(beforeMileage) &
                t.id.equals(excludeId).not(),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.mileage)]))
        .get();
    if (rows.isEmpty) return null;
    return _toFuelRecord(rows.first);
  }

  Future<int> insertFuelRecord(RecordsCompanion companion) {
    return into(records).insert(companion);
  }

  Future<int> insertExpenseRecord(RecordsCompanion companion) {
    return into(records).insert(companion);
  }

  Future<int> deleteRecord(int id) {
    return (delete(records)..where((t) => t.id.equals(id))).go();
  }

  Future<bool> updateRecord(RecordsCompanion companion) {
    return update(records).replace(companion);
  }

  Future<Vehicle?> getVehicle() async {
    final row = await (select(vehicles)..where((t) => t.id.equals(1))).getSingleOrNull();
    if (row == null) return null;
    return _toVehicle(row);
  }

  Future<void> saveVehicle(Vehicle vehicle) async {
    await into(vehicles).insertOnConflictUpdate(_vehicleCompanion(vehicle));
  }

  Future<bool> hasAnyRecords() async {
    final count = await records.count().getSingle();
    return count > 0;
  }

  List<AppRecord> _mapRows(List<RecordRow> rows) {
    return rows.map((row) {
      if (row.type == 'fuel') {
        return FuelRecordItem(_toFuelRecord(row));
      }
      return ExpenseRecordItem(_toExpenseRecord(row));
    }).toList();
  }

  FuelRecord _toFuelRecord(RecordRow row) {
    return FuelRecord(
      id: row.id,
      date: row.date,
      createdAt: row.createdAt,
      mileage: row.mileage ?? 0,
      fuelAmount: row.fuelAmount ?? 0,
      pricePerL: row.pricePerL ?? 0,
      discountAmount: row.discountAmount,
      totalCost: row.totalCost,
      isFull: row.isFull ?? false,
      prevRecorded: row.prevRecorded ?? true,
      fuelGrade: FuelGrade.fromCode(row.fuelGrade ?? '95'),
      station: row.station,
      notes: row.notes,
      consumption: row.consumption,
    );
  }

  ExpenseRecord _toExpenseRecord(RecordRow row) {
    return ExpenseRecord(
      id: row.id,
      date: row.date,
      createdAt: row.createdAt,
      category: ExpenseCategory.fromLabel(row.category ?? '其他'),
      totalCost: row.totalCost,
      notes: row.notes,
    );
  }

  Vehicle _toVehicle(VehicleRow row) {
    return Vehicle(
      brand: row.brand,
      model: row.model,
      year: row.year,
      plate: row.plate,
      purchaseDate: row.purchaseDate,
      purchasePrice: row.purchasePrice,
      displacement: row.displacement,
      transmission: row.transmission,
      fuelType: row.fuelType,
      color: row.color,
      annualInspection: row.annualInspection,
      insurance: row.insurance,
      commercial: row.commercial,
      vin: row.vin,
    );
  }

  VehiclesCompanion _vehicleCompanion(Vehicle vehicle) {
    return VehiclesCompanion(
      id: const Value(1),
      brand: Value(vehicle.brand),
      model: Value(vehicle.model),
      year: Value(vehicle.year),
      plate: Value(vehicle.plate),
      purchaseDate: Value(vehicle.purchaseDate),
      purchasePrice: Value(vehicle.purchasePrice),
      displacement: Value(vehicle.displacement),
      transmission: Value(vehicle.transmission),
      fuelType: Value(vehicle.fuelType),
      color: Value(vehicle.color),
      annualInspection: Value(vehicle.annualInspection),
      insurance: Value(vehicle.insurance),
      commercial: Value(vehicle.commercial),
      vin: Value(vehicle.vin),
    );
  }
}
