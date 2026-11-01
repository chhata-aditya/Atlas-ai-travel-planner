import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/world_locations_data.dart';
import '../models/location_model.dart';

/// Resolves user supplied place names to real coordinates via OpenStreetMap Nominatim.
class LocationGeocodingService {
  LocationGeocodingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<TravelLocation>> search(String query) async {
    final clean = query.trim();
    if (clean.length < 2) return const [];

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': clean,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '5',
    });
    final response = await _client.get(uri, headers: {
      'Accept': 'application/json',
      'User-Agent': 'AtlasTravelPlanner/1.0 (location search)',
    }).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw const LocationSearchException('Could not search places right now. Try again.');
    }

    final results = jsonDecode(response.body) as List<dynamic>;
    return results.map((raw) {
      final item = raw as Map<String, dynamic>;
      final address = item['address'] as Map<String, dynamic>? ?? const {};
      final name = (item['name'] as String?)?.trim().isNotEmpty == true
          ? (item['name'] as String).trim()
          : clean;
      final country = address['country'] as String? ?? 'Unknown country';
      final countryCode = (address['country_code'] as String?)?.toUpperCase();
      final category = item['category'] as String?;
      return TravelLocation(
        id: 'geo_${item['place_id']}',
        name: name,
        country: country,
        region: address['state'] as String? ?? country,
        latitude: double.parse(item['lat'] as String),
        longitude: double.parse(item['lon'] as String),
        emoji: '📍',
        countryCode: countryCode,
        isIsland: category == 'place' &&
            (item['type'] == 'island' || item['type'] == 'islet'),
      );
    }).toList();
  }

  void dispose() => _client.close();
}

class LocationSearchException implements Exception {
  const LocationSearchException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Uses the local catalog instantly, then falls back to real worldwide geocoding.
Future<TravelLocation> resolveRouteLocation(String query) async {
  final clean = query.trim();
  if (clean.isEmpty) throw const LocationSearchException('Enter a place to plan this route.');

  final known = WorldLocationsData.findExact(clean);
  if (known != null) return _withCountryCode(known);

  final service = LocationGeocodingService();
  try {
    final results = await service.search(clean);
    if (results.isEmpty) {
      throw const LocationSearchException('No matching place found. Try adding a region or country.');
    }
    return results.first;
  } finally {
    service.dispose();
  }
}

TravelLocation _withCountryCode(TravelLocation location) {
  final countryCode = location.countryCode ?? _countryCodes[location.country];
  final island = location.isIsland ?? _knownIslands.contains(location.id);
  return TravelLocation(
    id: location.id,
    name: location.name,
    country: location.country,
    region: location.region,
    latitude: location.latitude,
    longitude: location.longitude,
    emoji: location.emoji,
    airportCode: location.airportCode,
    countryCode: countryCode,
    isIsland: island,
  );
}

const Map<String, String> _countryCodes = {
  'India': 'IN',
  'Indonesia': 'ID',
  'Singapore': 'SG',
  'Thailand': 'TH',
  'Malaysia': 'MY',
  'Vietnam': 'VN',
  'Japan': 'JP',
  'South Korea': 'KR',
  'China': 'CN',
  'Taiwan': 'TW',
  'United Kingdom': 'GB',
  'France': 'FR',
  'Italy': 'IT',
  'Spain': 'ES',
  'Netherlands': 'NL',
  'Germany': 'DE',
  'Switzerland': 'CH',
  'Austria': 'AT',
  'Czech Republic': 'CZ',
  'Hungary': 'HU',
  'Greece': 'GR',
  'Portugal': 'PT',
  'Ireland': 'IE',
  'Norway': 'NO',
  'Sweden': 'SE',
  'Denmark': 'DK',
  'Finland': 'FI',
  'Iceland': 'IS',
  'United Arab Emirates': 'AE',
  'Qatar': 'QA',
  'Saudi Arabia': 'SA',
  'Egypt': 'EG',
  'Morocco': 'MA',
  'South Africa': 'ZA',
  'Kenya': 'KE',
  'Maldives': 'MV',
  'United States': 'US',
  'Canada': 'CA',
  'Mexico': 'MX',
  'Australia': 'AU',
  'New Zealand': 'NZ',
  'Brazil': 'BR',
  'Argentina': 'AR',
  'Peru': 'PE',
  'Chile': 'CL',
};

const Set<String> _knownIslands = {
  'bali',
  'singapore',
  'phuket',
  'hong_kong',
  'taipei',
  'santorini',
  'maldives',
};

/// Distance based comparison can only estimate typical options, it does not
/// query live schedules, fares, road connections, or ferry availability.
