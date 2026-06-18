import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:range_line/data/database/app_database.dart';
import 'package:range_line/data/repositories/record_repository.dart';
import 'package:range_line/shared/models/fuel_grade.dart';

void main() {
  group('RecordRepository recompute chain', () {
    late AppDatabase db;
    late RecordRepository repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = RecordRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('editing one fuel record recomputes downstream consumption', () async {
      await repository.addFuelRecord(
        date: DateTime(2026, 1, 1),
        mileage: 10000,
        fuelAmount: 40,
        pricePerL: 7.5,
        discountAmount: 0,
        isFull: true,
        prevRecorded: true,
        fuelGrade: FuelGrade.g95,
      );
      final r2 = await repository.addFuelRecord(
        date: DateTime(2026, 1, 10),
        mileage: 10400,
        fuelAmount: 32,
        pricePerL: 7.5,
        discountAmount: 0,
        isFull: true,
        prevRecorded: true,
        fuelGrade: FuelGrade.g95,
      );
      final r3 = await repository.addFuelRecord(
        date: DateTime(2026, 1, 20),
        mileage: 10800,
        fuelAmount: 36,
        pricePerL: 7.5,
        discountAmount: 0,
        isFull: true,
        prevRecorded: true,
        fuelGrade: FuelGrade.g95,
      );

      await repository.updateFuelRecord(
        id: r2.id,
        date: r2.date,
        createdAt: r2.createdAt,
        mileage: 10500,
        fuelAmount: 32,
        pricePerL: 7.5,
        discountAmount: 0,
        isFull: true,
        prevRecorded: true,
        fuelGrade: FuelGrade.g95,
      );

      final fuels = await repository.getFuelRecords();
      final updatedR3 = fuels.firstWhere((e) => e.id == r3.id);
      expect(updatedR3.consumption, 12.0); // 36 / (10800-10500) * 100
    });

    test('deleting middle fuel record recomputes downstream consumption', () async {
      await repository.addFuelRecord(
        date: DateTime(2026, 1, 1),
        mileage: 10000,
        fuelAmount: 40,
        pricePerL: 7.5,
        discountAmount: 0,
        isFull: true,
        prevRecorded: true,
        fuelGrade: FuelGrade.g95,
      );
      final r2 = await repository.addFuelRecord(
        date: DateTime(2026, 1, 10),
        mileage: 10400,
        fuelAmount: 32,
        pricePerL: 7.5,
        discountAmount: 0,
        isFull: true,
        prevRecorded: true,
        fuelGrade: FuelGrade.g95,
      );
      final r3 = await repository.addFuelRecord(
        date: DateTime(2026, 1, 20),
        mileage: 10800,
        fuelAmount: 36,
        pricePerL: 7.5,
        discountAmount: 0,
        isFull: true,
        prevRecorded: true,
        fuelGrade: FuelGrade.g95,
      );

      await repository.deleteRecord(r2.id);

      final fuels = await repository.getFuelRecords();
      final updatedR3 = fuels.firstWhere((e) => e.id == r3.id);
      expect(updatedR3.consumption, 4.5); // 36 / (10800-10000) * 100
    });
  });
}
