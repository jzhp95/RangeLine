import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:range_line/data/database/app_database.dart';
import 'package:range_line/data/repositories/record_repository.dart';
import 'package:range_line/data/repositories/vehicle_repository.dart';
import 'package:range_line/shared/models/record.dart';
import 'package:range_line/shared/models/vehicle.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in main()');
});

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  return RecordRepository(ref.watch(databaseProvider));
});

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository(ref.watch(databaseProvider));
});

final recordsStreamProvider = StreamProvider<List<AppRecord>>((ref) {
  return ref.watch(recordRepositoryProvider).watchAllRecords();
});

final vehicleProvider = FutureProvider<Vehicle>((ref) async {
  return ref.watch(vehicleRepositoryProvider).getVehicle();
});

Future<AppDatabase> bootstrapDatabase() async {
  final db = await AppDatabase.open();
  final vehicleRepo = VehicleRepository(db);
  await vehicleRepo.ensureDefaultVehicle();
  return db;
}
