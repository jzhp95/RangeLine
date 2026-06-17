import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:range_line/app/app.dart';
import 'package:range_line/data/providers/database_providers.dart';
import 'package:range_line/data/repositories/record_repository.dart';
import 'package:range_line/data/seed/seed_importer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await bootstrapDatabase();
  final recordRepo = RecordRepository(db);
  await importSeedRecordsIfEmpty(recordRepo);

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const RangeLineApp(),
    ),
  );
}
