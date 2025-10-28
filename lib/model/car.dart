// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Car {
  final String make;
  final String model;
  final int year;

  Car({required this.make, required this.model, required this.year});

  Car copyWith({String? make, String? model, int? year}) {
    return Car(
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'make': make, 'model': model, 'year': year};
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      make: map['make'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Car.fromJson(String source) =>
      Car.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Car(make: $make, model: $model, year: $year)';

  @override
  bool operator ==(covariant Car other) {
    if (identical(this, other)) return true;

    return other.make == make && other.model == model && other.year == year;
  }

  @override
  int get hashCode => make.hashCode ^ model.hashCode ^ year.hashCode;
}
