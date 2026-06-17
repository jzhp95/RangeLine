import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:range_line/shared/widgets/stats_grid.dart';

void main() {
  testWidgets('StatsGrid renders cells', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatsGrid(
            rows: const [
              [
                StatCell(value: '100 km', label: '累计行程'),
                StatCell(value: '50 km/次', label: '平均行程'),
              ],
            ],
          ),
        ),
      ),
    );

    expect(find.text('100 km'), findsOneWidget);
    expect(find.text('累计行程'), findsOneWidget);
    expect(find.text('平均行程'), findsOneWidget);
  });
}
