import 'package:drift/drift.dart';

@DataClassName('RecordRow')
class Records extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get mileage => integer().nullable()();
  RealColumn get fuelAmount => real().nullable()();
  RealColumn get pricePerL => real().nullable()();
  RealColumn get discountAmount => real().withDefault(const Constant(0))();
  RealColumn get totalCost => real()();
  BoolColumn get isFull => boolean().nullable()();
  BoolColumn get prevRecorded => boolean().nullable()();
  TextColumn get fuelGrade => text().nullable()();
  TextColumn get station => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  RealColumn get consumption => real().nullable()();
  TextColumn get category => text().nullable()();
}
