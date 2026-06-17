import 'package:flutter_test/flutter_test.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/shared/widgets/consumption_text.dart';

void main() {
  group('ConsumptionText.colorFor', () {
    test('low consumption is green', () {
      expect(ConsumptionText.colorFor(7.0), AppColors.primary);
    });

    test('high consumption is red', () {
      expect(ConsumptionText.colorFor(9.0), AppColors.danger);
    });

    test('mid consumption is neutral', () {
      expect(ConsumptionText.colorFor(8.0), AppColors.onSurface);
    });

    test('null is variant', () {
      expect(ConsumptionText.colorFor(null), AppColors.onSurfaceVariant);
    });
  });
}
