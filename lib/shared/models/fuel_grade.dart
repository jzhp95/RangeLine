enum FuelGrade {
  g92('92'),
  g95('95'),
  g98('98');

  const FuelGrade(this.code);
  final String code;

  String get label => '$code号';

  static FuelGrade fromCode(String code) {
    return FuelGrade.values.firstWhere(
      (g) => g.code == code,
      orElse: () => FuelGrade.g95,
    );
  }
}
