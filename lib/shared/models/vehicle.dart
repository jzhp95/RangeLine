class Vehicle {
  const Vehicle({
    this.brand = '大众',
    this.model = '途岳',
    this.year = '2022款',
    this.plate = '沪A·12345',
    this.purchaseDate = '2022年03月15日',
    this.purchasePrice = '198,800',
    this.displacement = '1.4T',
    this.transmission = '7速双离合',
    this.fuelType = '95号汽油',
    this.color = '炫黑色',
    this.annualInspection = '2027年03月',
    this.insurance = '2026年12月31日',
    this.commercial = '2026年12月31日',
    this.vin = 'LVVDB17B4LD123456',
  });

  final String brand;
  final String model;
  final String year;
  final String plate;
  final String purchaseDate;
  final String purchasePrice;
  final String displacement;
  final String transmission;
  final String fuelType;
  final String color;
  final String annualInspection;
  final String insurance;
  final String commercial;
  final String vin;

  String get displayName => '$brand $model';

  Vehicle copyWith({
    String? brand,
    String? model,
    String? year,
    String? plate,
    String? purchaseDate,
    String? purchasePrice,
    String? displacement,
    String? transmission,
    String? fuelType,
    String? color,
    String? annualInspection,
    String? insurance,
    String? commercial,
    String? vin,
  }) {
    return Vehicle(
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      plate: plate ?? this.plate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      displacement: displacement ?? this.displacement,
      transmission: transmission ?? this.transmission,
      fuelType: fuelType ?? this.fuelType,
      color: color ?? this.color,
      annualInspection: annualInspection ?? this.annualInspection,
      insurance: insurance ?? this.insurance,
      commercial: commercial ?? this.commercial,
      vin: vin ?? this.vin,
    );
  }
}

const defaultVehicle = Vehicle();
