import 'package:range_line/shared/models/dashboard_stats.dart';
import 'package:range_line/shared/models/expense_record.dart';
import 'package:range_line/shared/models/fuel_record.dart';

abstract final class DashboardCalculator {
  static DashboardStats compute({
    required List<FuelRecord> fuelRecords,
    required List<ExpenseRecord> expenseRecords,
  }) {
    final withConsumption = fuelRecords
        .where((r) => r.consumption != null && r.consumption! > 0)
        .toList();

    final avgConsumption = withConsumption.isEmpty
        ? 0.0
        : withConsumption.map((r) => r.consumption!).reduce((a, b) => a + b) /
            withConsumption.length;

    final totalFuelCost =
        fuelRecords.fold<double>(0, (sum, r) => sum + r.totalCost);
    final totalExpenseCost =
        expenseRecords.fold<double>(0, (sum, r) => sum + r.totalCost);
    final avgFuelCost =
        fuelRecords.isEmpty ? 0.0 : totalFuelCost / fuelRecords.length;

    final miles = fuelRecords.map((r) => r.mileage).toList()..sort();
    final totalMiles =
        miles.length >= 2 ? miles.last - miles.first : 0;
    final currentMileage = miles.isEmpty ? 0 : miles.last;
    final avgTrip = fuelRecords.length > 1
        ? totalMiles / (fuelRecords.length - 1)
        : 0.0;

    final totalSavings =
        fuelRecords.fold<double>(0, (sum, r) => sum + r.discountAmount);
    final totalFuelAmount =
        fuelRecords.fold<double>(0, (sum, r) => sum + r.fuelAmount);

    final recent = withConsumption.take(2).toList();
    final previous = withConsumption.skip(2).take(2).toList();
    final recentAvg = recent.isEmpty
        ? 0.0
        : recent.map((r) => r.consumption!).reduce((a, b) => a + b) /
            recent.length;
    final prevAvg = previous.isEmpty
        ? 0.0
        : previous.map((r) => r.consumption!).reduce((a, b) => a + b) /
            previous.length;
    final trendDiff = recentAvg - prevAvg;

    return DashboardStats(
      avgConsumption: avgConsumption,
      fuelRecordCount: fuelRecords.length,
      trendDiff: trendDiff,
      showTrend: withConsumption.length >= 4,
      trendUp: trendDiff > 0,
      currentMileage: currentMileage,
      totalSpending: totalFuelCost + totalExpenseCost,
      totalMiles: totalMiles,
      avgTrip: avgTrip,
      totalFuelCost: totalFuelCost,
      avgFuelCost: avgFuelCost,
      totalFuelAmount: totalFuelAmount,
      totalSavings: totalSavings,
      totalExpenseCost: totalExpenseCost,
    );
  }
}
