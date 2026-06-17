abstract final class ConsumptionCalculator {
  static double? calcConsumption({
    required int currentMileage,
    required int? previousMileage,
    required double fuelAmount,
    required bool isFull,
    required bool prevRecorded,
  }) {
    if (!isFull || !prevRecorded) return null;
    if (previousMileage == null) return null;
    if (currentMileage <= previousMileage) return null;
    if (fuelAmount <= 0) return null;

    final distance = currentMileage - previousMileage;
    final consumption = (fuelAmount / distance) * 100;
    return (consumption * 10).round() / 10;
  }
}
