import 'package:range_line/shared/models/expense_category.dart';
import 'package:range_line/shared/models/fuel_grade.dart';

/// Debug seed payloads for UI development.
class SeedRecordDraft {
  const SeedRecordDraft.fuel({
    required this.date,
    required this.mileage,
    required this.fuelAmount,
    required this.pricePerL,
    required this.discountAmount,
    required this.totalCost,
    required this.isFull,
    required this.prevRecorded,
    required this.fuelGrade,
    this.station = '',
    this.notes = '',
    this.consumption,
  })  : type = fuelType,
        category = null,
        expenseNotes = null;

  const SeedRecordDraft.expense({
    required this.date,
    required this.category,
    required this.totalCost,
    this.expenseNotes = '',
  })  : type = expenseType,
        mileage = null,
        fuelAmount = null,
        pricePerL = null,
        discountAmount = null,
        isFull = null,
        prevRecorded = null,
        fuelGrade = null,
        station = null,
        notes = null,
        consumption = null;

  static const fuelType = 'fuel';
  static const expenseType = 'expense';

  final String type;
  final DateTime date;
  final int? mileage;
  final double? fuelAmount;
  final double? pricePerL;
  final double? discountAmount;
  final double totalCost;
  final bool? isFull;
  final bool? prevRecorded;
  final FuelGrade? fuelGrade;
  final String? station;
  final String? notes;
  final double? consumption;
  final ExpenseCategory? category;
  final String? expenseNotes;
}

final seedRecordDrafts = <SeedRecordDraft>[
  SeedRecordDraft.fuel(
    date: DateTime(2026, 5, 28),
    mileage: 12450,
    fuelAmount: 42.1,
    pricePerL: 7.48,
    discountAmount: 10,
    totalCost: 305,
    isFull: true,
    prevRecorded: true,
    fuelGrade: FuelGrade.g95,
    station: '中石化长宁路站',
    consumption: 7.2,
  ),
  SeedRecordDraft.expense(
    date: DateTime(2026, 5, 20),
    category: ExpenseCategory.carWash,
    totalCost: 38,
    expenseNotes: '加油站自助洗车',
  ),
  SeedRecordDraft.fuel(
    date: DateTime(2026, 5, 10),
    mileage: 11985,
    fuelAmount: 38.5,
    pricePerL: 7.48,
    discountAmount: 0,
    totalCost: 287.98,
    isFull: true,
    prevRecorded: true,
    fuelGrade: FuelGrade.g95,
    station: '中石油延安路站',
    consumption: 7.8,
  ),
  SeedRecordDraft.expense(
    date: DateTime(2026, 4, 28),
    category: ExpenseCategory.maintenance,
    totalCost: 680,
    expenseNotes: '4S店小保养换机油机滤',
  ),
  SeedRecordDraft.fuel(
    date: DateTime(2026, 4, 22),
    mileage: 11490,
    fuelAmount: 35.2,
    pricePerL: 7.55,
    discountAmount: 8,
    totalCost: 257.76,
    isFull: true,
    prevRecorded: true,
    fuelGrade: FuelGrade.g95,
    station: '中石化虹桥路站',
    notes: '会员折扣0.2元/L',
    consumption: 8.1,
  ),
  SeedRecordDraft.fuel(
    date: DateTime(2026, 4, 5),
    mileage: 11055,
    fuelAmount: 32.8,
    pricePerL: 7.55,
    discountAmount: 0,
    totalCost: 247.64,
    isFull: false,
    prevRecorded: true,
    fuelGrade: FuelGrade.g92,
    notes: '未加满',
    consumption: 7.5,
  ),
  SeedRecordDraft.expense(
    date: DateTime(2026, 3, 25),
    category: ExpenseCategory.parking,
    totalCost: 24,
    expenseNotes: '商场停车3小时',
  ),
  SeedRecordDraft.fuel(
    date: DateTime(2026, 3, 18),
    mileage: 10620,
    fuelAmount: 36.4,
    pricePerL: 7.42,
    discountAmount: 12,
    totalCost: 258.05,
    isFull: true,
    prevRecorded: true,
    fuelGrade: FuelGrade.g95,
    station: '中石化中山路站',
    notes: 'APP优惠券',
    consumption: 7.9,
  ),
  SeedRecordDraft.fuel(
    date: DateTime(2026, 3, 2),
    mileage: 10160,
    fuelAmount: 33.6,
    pricePerL: 7.42,
    discountAmount: 0,
    totalCost: 249.31,
    isFull: true,
    prevRecorded: false,
    fuelGrade: FuelGrade.g95,
    notes: '上次漏记里程',
  ),
  SeedRecordDraft.expense(
    date: DateTime(2026, 2, 20),
    category: ExpenseCategory.carWash,
    totalCost: 45,
    expenseNotes: '精洗内外',
  ),
  SeedRecordDraft.fuel(
    date: DateTime(2026, 2, 14),
    mileage: 9700,
    fuelAmount: 38.1,
    pricePerL: 7.38,
    discountAmount: 5,
    totalCost: 276.18,
    isFull: true,
    prevRecorded: true,
    fuelGrade: FuelGrade.g95,
    station: '中石化古北路站',
    consumption: 7.5,
  ),
];
