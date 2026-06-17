class DashboardStats {
  const DashboardStats({
    required this.avgConsumption,
    required this.fuelRecordCount,
    required this.trendDiff,
    required this.showTrend,
    required this.trendUp,
    required this.currentMileage,
    required this.totalSpending,
    required this.totalMiles,
    required this.avgTrip,
    required this.totalFuelCost,
    required this.avgFuelCost,
    required this.totalFuelAmount,
    required this.totalSavings,
    required this.totalExpenseCost,
  });

  final double avgConsumption;
  final int fuelRecordCount;
  final double trendDiff;
  final bool showTrend;
  final bool trendUp;
  final int currentMileage;
  final double totalSpending;
  final int totalMiles;
  final double avgTrip;
  final double totalFuelCost;
  final double avgFuelCost;
  final double totalFuelAmount;
  final double totalSavings;
  final double totalExpenseCost;
}
