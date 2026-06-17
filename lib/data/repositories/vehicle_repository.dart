import 'package:range_line/data/database/app_database.dart';
import 'package:range_line/shared/models/vehicle.dart';

class VehicleRepository {
  VehicleRepository(this._db);

  final AppDatabase _db;

  Future<Vehicle> getVehicle() async {
    return await _db.getVehicle() ?? defaultVehicle;
  }

  Future<void> saveVehicle(Vehicle vehicle) => _db.saveVehicle(vehicle);

  Future<void> ensureDefaultVehicle() async {
    final existing = await _db.getVehicle();
    if (existing == null) {
      await _db.saveVehicle(defaultVehicle);
    }
  }
}
