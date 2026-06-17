import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:range_line/app/theme/app_spacing.dart';
import 'package:range_line/app/theme/app_typography.dart';
import 'package:range_line/data/providers/database_providers.dart';

class VehicleScreen extends ConsumerWidget {
  const VehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleProvider);

    return vehicleAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (vehicle) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('我的车辆', style: AppTypography.headline),
              const SizedBox(height: AppSpacing.lg),
              Text(vehicle.displayName, style: AppTypography.title),
              Text(vehicle.year, style: AppTypography.label),
              const SizedBox(height: AppSpacing.sm),
              Text('车牌 ${vehicle.plate}', style: AppTypography.body),
              Text('${vehicle.displacement} · ${vehicle.transmission}', style: AppTypography.body),
            ],
          ),
        );
      },
    );
  }
}
