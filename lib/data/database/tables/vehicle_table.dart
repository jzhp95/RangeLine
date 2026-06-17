import 'package:drift/drift.dart';

@DataClassName('VehicleRow')
class Vehicles extends Table {
  IntColumn get id => integer()();
  TextColumn get brand => text()();
  TextColumn get model => text()();
  TextColumn get year => text()();
  TextColumn get plate => text()();
  TextColumn get purchaseDate => text()();
  TextColumn get purchasePrice => text()();
  TextColumn get displacement => text()();
  TextColumn get transmission => text()();
  TextColumn get fuelType => text()();
  TextColumn get color => text()();
  TextColumn get annualInspection => text().withDefault(const Constant(''))();
  TextColumn get insurance => text().withDefault(const Constant(''))();
  TextColumn get commercial => text().withDefault(const Constant(''))();
  TextColumn get vin => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
