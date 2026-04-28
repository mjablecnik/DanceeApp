import 'package:equatable/equatable.dart';

class Venue extends Equatable {
  const Venue({
    required this.id,
    required this.name,
    required this.street,
    required this.number,
    required this.town,
    required this.country,
    required this.postalCode,
    required this.region,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String name;
  final String street;
  final String number;
  final String town;
  final String country;
  final String postalCode;
  final String region;
  final double latitude;
  final double longitude;

  String get fullAddress {
    final streetPart = number.isNotEmpty ? '$street $number' : street;
    return '$streetPart, $postalCode $town, $country';
  }

  factory Venue.fromDirectus(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      street: (json['street'] as String?) ?? '',
      number: (json['number'] as String?) ?? '',
      town: (json['town'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      postalCode: (json['postal_code'] as String?) ?? '',
      region: (json['region'] as String?) ?? '',
      latitude: ((json['latitude'] as num?) ?? 0).toDouble(),
      longitude: ((json['longitude'] as num?) ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        street,
        number,
        town,
        country,
        postalCode,
        region,
        latitude,
        longitude,
      ];
}
