import 'package:range_line/shared/models/fuel_grade.dart';

class FuelRecord {
  const FuelRecord({
    required this.id,
    required this.date,
    required this.createdAt,
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
  });

  final int id;
  final DateTime date;
  final DateTime createdAt;
  final int mileage;
  final double fuelAmount;
  final double pricePerL;
  final double discountAmount;
  final double totalCost;
  final bool isFull;
  final bool prevRecorded;
  final FuelGrade fuelGrade;
  final String station;
  final String notes;
  final double? consumption;

  FuelRecord copyWith({
    int? id,
    DateTime? date,
    DateTime? createdAt,
    int? mileage,
    double? fuelAmount,
    double? pricePerL,
    double? discountAmount,
    double? totalCost,
    bool? isFull,
    bool? prevRecorded,
    FuelGrade? fuelGrade,
    String? station,
    String? notes,
    double? consumption,
  }) {
    return FuelRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      mileage: mileage ?? this.mileage,
      fuelAmount: fuelAmount ?? this.fuelAmount,
      pricePerL: pricePerL ?? this.pricePerL,
      discountAmount: discountAmount ?? this.discountAmount,
      totalCost: totalCost ?? this.totalCost,
      isFull: isFull ?? this.isFull,
      prevRecorded: prevRecorded ?? this.prevRecorded,
      fuelGrade: fuelGrade ?? this.fuelGrade,
      station: station ?? this.station,
      notes: notes ?? this.notes,
      consumption: consumption ?? this.consumption,
    );
  }
}
