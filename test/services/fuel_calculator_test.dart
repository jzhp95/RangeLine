import 'package:flutter_test/flutter_test.dart';
import 'package:range_line/shared/services/consumption_calculator.dart';
import 'package:range_line/shared/services/fuel_calculator.dart';

void main() {
  group('FuelCalculator', () {
    test('calcPumpTotal', () {
      expect(FuelCalculator.calcPumpTotal(42.1, 7.48), closeTo(314.908, 0.001));
    });

    test('calcActualTotal with discount', () {
      expect(FuelCalculator.calcActualTotal(314.91, 10), closeTo(304.91, 0.001));
    });

    test('calcActualTotal discount exceeds pump total', () {
      expect(FuelCalculator.calcActualTotal(100, 150), 0);
    });

    test('calcActualPricePerL', () {
      expect(FuelCalculator.calcActualPricePerL(304.91, 42.1), closeTo(7.243, 0.001));
    });
  });

  group('ConsumptionCalculator', () {
    test('normal consumption', () {
      final result = ConsumptionCalculator.calcConsumption(
        currentMileage: 12450,
        previousMileage: 11985,
        fuelAmount: 42.1,
        isFull: true,
        prevRecorded: true,
      );
      expect(result, 9.1); // (42.1/465)*100 = 9.05 -> 9.1
    });

    test('PRD example consumption 7.2 case', () {
      // 42.1L over 585km (12450-11865) would be 7.2 - use exact PRD numbers
      final result = ConsumptionCalculator.calcConsumption(
        currentMileage: 12450,
        previousMileage: 11865,
        fuelAmount: 42.1,
        isFull: true,
        prevRecorded: true,
      );
      expect(result, 7.2);
    });

    test('not full tank', () {
      expect(
        ConsumptionCalculator.calcConsumption(
          currentMileage: 12450,
          previousMileage: 11985,
          fuelAmount: 42.1,
          isFull: false,
          prevRecorded: true,
        ),
        isNull,
      );
    });

    test('prev not recorded', () {
      expect(
        ConsumptionCalculator.calcConsumption(
          currentMileage: 10160,
          previousMileage: 9700,
          fuelAmount: 33.6,
          isFull: true,
          prevRecorded: false,
        ),
        isNull,
      );
    });

    test('mileage not increased', () {
      expect(
        ConsumptionCalculator.calcConsumption(
          currentMileage: 10000,
          previousMileage: 10000,
          fuelAmount: 40,
          isFull: true,
          prevRecorded: true,
        ),
        isNull,
      );
    });

    test('no previous record', () {
      expect(
        ConsumptionCalculator.calcConsumption(
          currentMileage: 12450,
          previousMileage: null,
          fuelAmount: 42.1,
          isFull: true,
          prevRecorded: true,
        ),
        isNull,
      );
    });
  });
}
