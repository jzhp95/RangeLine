abstract final class FuelCalculator {
  static double? calcPumpTotal(double fuelAmount, double pricePerL) {
    if (fuelAmount <= 0 || pricePerL <= 0) return null;
    return fuelAmount * pricePerL;
  }

  static double calcActualTotal(double pumpTotal, double discount) {
    return (pumpTotal - discount).clamp(0, double.infinity);
  }

  static double? calcActualPricePerL(double actualTotal, double fuelAmount) {
    if (fuelAmount <= 0) return null;
    final value = actualTotal / fuelAmount;
    return (value * 1000).round() / 1000;
  }
}
