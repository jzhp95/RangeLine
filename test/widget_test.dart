import 'package:flutter_test/flutter_test.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_theme.dart';

void main() {
  test('AppTheme uses PRD primary color', () {
    final theme = AppTheme.light;
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.scaffoldBackgroundColor, AppColors.surface);
  });
}
