import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HistoryFilter { all, fuel, expense }

extension HistoryFilterLabel on HistoryFilter {
  String get label => switch (this) {
        HistoryFilter.all => '全部',
        HistoryFilter.fuel => '加油',
        HistoryFilter.expense => '其他费用',
      };

  static HistoryFilter fromLabel(String label) => switch (label) {
        '全部' => HistoryFilter.all,
        '加油' => HistoryFilter.fuel,
        '其他费用' => HistoryFilter.expense,
        _ => HistoryFilter.fuel,
      };
}

final historyFilterProvider = StateProvider<HistoryFilter>(
  (ref) => HistoryFilter.fuel,
);
