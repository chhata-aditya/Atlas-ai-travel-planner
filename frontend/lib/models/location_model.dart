import 'dart:math' as math;

class TravelLocation {
  final String id;
  final String name;
  final String country;
  final String region;
  final double latitude;
  final double longitude;
  final String emoji;
  final String? airportCode;
  final String? countryCode;
  final bool? isIsland;

  const TravelLocation({
    required this.id,
    required this.name,
    required this.country,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.emoji,
    this.airportCode,
    this.countryCode,
    this.isIsland,
  });

  String get displayName => '$name, $country';

  /// Calculate Haversine great-circle distance to another location in Kilometers
  double distanceTo(TravelLocation other) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _toRadians(other.latitude - latitude);
    final double dLon = _toRadians(other.longitude - longitude);

    final double lat1 = _toRadians(latitude);
    final double lat2 = _toRadians(other.latitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _toRadians(double degree) => degree * math.pi / 180.0;
}
