import '../models/location_model.dart';

class WorldLocationsData {
  static const List<TravelLocation> popularLocations = [
    // India & South Asia
    TravelLocation(id: 'delhi', name: 'New Delhi', country: 'India', region: 'South Asia', latitude: 28.6139, longitude: 77.2090, emoji: '🇮🇳', airportCode: 'DEL', countryCode: 'IN'),
    TravelLocation(id: 'mumbai', name: 'Mumbai', country: 'India', region: 'South Asia', latitude: 19.0760, longitude: 72.8777, emoji: '🇮🇳', airportCode: 'BOM', countryCode: 'IN'),
    TravelLocation(id: 'bengaluru', name: 'Bengaluru', country: 'India', region: 'South Asia', latitude: 12.9716, longitude: 77.5946, emoji: '🇮🇳', airportCode: 'BLR'),
    TravelLocation(id: 'pune', name: 'Pune', country: 'India', region: 'South Asia', latitude: 18.5204, longitude: 73.8567, emoji: '🇮🇳', airportCode: 'PNQ'),
    TravelLocation(id: 'jaipur', name: 'Jaipur', country: 'India', region: 'South Asia', latitude: 26.9124, longitude: 75.7873, emoji: '🇮🇳', airportCode: 'JAI'),
    TravelLocation(id: 'goa', name: 'Goa', country: 'India', region: 'South Asia', latitude: 15.2993, longitude: 74.1240, emoji: '🏖️', airportCode: 'GOI'),
    TravelLocation(id: 'hyderabad', name: 'Hyderabad', country: 'India', region: 'South Asia', latitude: 17.3850, longitude: 78.4867, emoji: '🇮🇳', airportCode: 'HYD'),
    TravelLocation(id: 'chennai', name: 'Chennai', country: 'India', region: 'South Asia', latitude: 13.0827, longitude: 80.2707, emoji: '🇮🇳', airportCode: 'MAA'),
    TravelLocation(id: 'kolkata', name: 'Kolkata', country: 'India', region: 'South Asia', latitude: 22.5726, longitude: 88.3639, emoji: '🇮🇳', airportCode: 'CCU'),
    TravelLocation(id: 'ahmedabad', name: 'Ahmedabad', country: 'India', region: 'South Asia', latitude: 23.0225, longitude: 72.5714, emoji: '🇮🇳', airportCode: 'AMD'),
    TravelLocation(id: 'agra', name: 'Agra', country: 'India', region: 'South Asia', latitude: 27.1767, longitude: 78.0081, emoji: '🕌', airportCode: 'AGR'),
    TravelLocation(id: 'varanasi', name: 'Varanasi', country: 'India', region: 'South Asia', latitude: 25.3176, longitude: 82.9739, emoji: '🪔', airportCode: 'VNS'),
    TravelLocation(id: 'shimla', name: 'Shimla', country: 'India', region: 'South Asia', latitude: 31.1048, longitude: 77.1734, emoji: '🏔️', airportCode: 'SLV'),
    TravelLocation(id: 'manali', name: 'Manali', country: 'India', region: 'South Asia', latitude: 32.2432, longitude: 77.1892, emoji: '❄️', airportCode: 'KUU'),
    TravelLocation(id: 'kochi', name: 'Kochi', country: 'India', region: 'South Asia', latitude: 9.9312, longitude: 76.2673, emoji: '🌴', airportCode: 'COK'),

    // Southeast & East Asia
    TravelLocation(id: 'bali', name: 'Bali', country: 'Indonesia', region: 'Southeast Asia', latitude: -8.4095, longitude: 115.1889, emoji: '🌴', airportCode: 'DPS'),
    TravelLocation(id: 'singapore', name: 'Singapore', country: 'Singapore', region: 'Southeast Asia', latitude: 1.3521, longitude: 103.8198, emoji: '🦁', airportCode: 'SIN'),
    TravelLocation(id: 'bangkok', name: 'Bangkok', country: 'Thailand', region: 'Southeast Asia', latitude: 13.7563, longitude: 100.5018, emoji: '🇹🇭', airportCode: 'BKK'),
    TravelLocation(id: 'phuket', name: 'Phuket', country: 'Thailand', region: 'Southeast Asia', latitude: 7.8804, longitude: 98.3923, emoji: '🏝️', airportCode: 'HKT'),
    TravelLocation(id: 'kuala_lumpur', name: 'Kuala Lumpur', country: 'Malaysia', region: 'Southeast Asia', latitude: 3.1390, longitude: 101.6869, emoji: '🇲🇾', airportCode: 'KUL'),
    TravelLocation(id: 'hanoi', name: 'Hanoi', country: 'Vietnam', region: 'Southeast Asia', latitude: 21.0285, longitude: 105.8542, emoji: '🇻🇳', airportCode: 'HAN'),
    TravelLocation(id: 'tokyo', name: 'Tokyo', country: 'Japan', region: 'East Asia', latitude: 35.6762, longitude: 139.6503, emoji: '🗼', airportCode: 'HND'),
    TravelLocation(id: 'kyoto', name: 'Kyoto', country: 'Japan', region: 'East Asia', latitude: 35.0116, longitude: 135.7681, emoji: '⛩️', airportCode: 'KIX'),
    TravelLocation(id: 'osaka', name: 'Osaka', country: 'Japan', region: 'East Asia', latitude: 34.6937, longitude: 135.5023, emoji: '🗾', airportCode: 'ITM'),
    TravelLocation(id: 'seoul', name: 'Seoul', country: 'South Korea', region: 'East Asia', latitude: 37.5665, longitude: 126.9780, emoji: '🇰🇷', airportCode: 'ICN'),
    TravelLocation(id: 'hong_kong', name: 'Hong Kong', country: 'China', region: 'East Asia', latitude: 22.3193, longitude: 114.1694, emoji: '🇭🇰', airportCode: 'HKG'),
    TravelLocation(id: 'shanghai', name: 'Shanghai', country: 'China', region: 'East Asia', latitude: 31.2304, longitude: 121.4737, emoji: '🇨🇳', airportCode: 'PVG'),
    TravelLocation(id: 'beijing', name: 'Beijing', country: 'China', region: 'East Asia', latitude: 39.9042, longitude: 116.4074, emoji: '🇨🇳', airportCode: 'PEK'),
    TravelLocation(id: 'taipei', name: 'Taipei', country: 'Taiwan', region: 'East Asia', latitude: 25.0330, longitude: 121.5654, emoji: '🇹🇼', airportCode: 'TPE'),

    // Europe
    TravelLocation(id: 'london', name: 'London', country: 'United Kingdom', region: 'Europe', latitude: 51.5074, longitude: -0.1278, emoji: '🇬🇧', airportCode: 'LHR'),
    TravelLocation(id: 'edinburgh', name: 'Edinburgh', country: 'United Kingdom', region: 'Europe', latitude: 55.9533, longitude: -3.1883, emoji: '🏰', airportCode: 'EDI'),
    TravelLocation(id: 'paris', name: 'Paris', country: 'France', region: 'Europe', latitude: 48.8566, longitude: 2.3522, emoji: '🇫🇷', airportCode: 'CDG'),
    TravelLocation(id: 'nice', name: 'Nice', country: 'France', region: 'Europe', latitude: 43.7102, longitude: 7.2620, emoji: '🌊', airportCode: 'NCE'),
    TravelLocation(id: 'rome', name: 'Rome', country: 'Italy', region: 'Europe', latitude: 41.9028, longitude: 12.4964, emoji: '🇮🇹', airportCode: 'FCO'),
    TravelLocation(id: 'milan', name: 'Milan', country: 'Italy', region: 'Europe', latitude: 45.4642, longitude: 9.1900, emoji: '🇮🇹', airportCode: 'MXP'),
    TravelLocation(id: 'venice', name: 'Venice', country: 'Italy', region: 'Europe', latitude: 45.4408, longitude: 12.3155, emoji: '🎭', airportCode: 'VCE'),
    TravelLocation(id: 'florence', name: 'Florence', country: 'Italy', region: 'Europe', latitude: 43.7696, longitude: 11.2558, emoji: '🎨', airportCode: 'FLR'),
    TravelLocation(id: 'barcelona', name: 'Barcelona', country: 'Spain', region: 'Europe', latitude: 41.3879, longitude: 2.1699, emoji: '🇪🇸', airportCode: 'BCN'),
    TravelLocation(id: 'madrid', name: 'Madrid', country: 'Spain', region: 'Europe', latitude: 40.4168, longitude: -3.7038, emoji: '🇪🇸', airportCode: 'MAD'),
    TravelLocation(id: 'amsterdam', name: 'Amsterdam', country: 'Netherlands', region: 'Europe', latitude: 52.3676, longitude: 4.9041, emoji: '🇳🇱', airportCode: 'AMS'),
    TravelLocation(id: 'berlin', name: 'Berlin', country: 'Germany', region: 'Europe', latitude: 52.5200, longitude: 13.4050, emoji: '🇩🇪', airportCode: 'BER'),
    TravelLocation(id: 'munich', name: 'Munich', country: 'Germany', region: 'Europe', latitude: 48.1351, longitude: 11.5820, emoji: '🍺', airportCode: 'MUC'),
    TravelLocation(id: 'frankfurt', name: 'Frankfurt', country: 'Germany', region: 'Europe', latitude: 50.1109, longitude: 8.6821, emoji: '🇩🇪', airportCode: 'FRA'),
    TravelLocation(id: 'zurich', name: 'Zurich', country: 'Switzerland', region: 'Europe', latitude: 47.3769, longitude: 8.5417, emoji: '🇨🇭', airportCode: 'ZRH'),
    TravelLocation(id: 'geneva', name: 'Geneva', country: 'Switzerland', region: 'Europe', latitude: 46.2044, longitude: 6.1432, emoji: '🇨🇭', airportCode: 'GVA'),
    TravelLocation(id: 'vienna', name: 'Vienna', country: 'Austria', region: 'Europe', latitude: 48.2082, longitude: 16.3738, emoji: '🇦🇹', airportCode: 'VIE'),
    TravelLocation(id: 'prague', name: 'Prague', country: 'Czech Republic', region: 'Europe', latitude: 50.0755, longitude: 14.4378, emoji: '🇨🇿', airportCode: 'PRG'),
    TravelLocation(id: 'budapest', name: 'Budapest', country: 'Hungary', region: 'Europe', latitude: 47.4979, longitude: 19.0402, emoji: '🇭🇺', airportCode: 'BUD'),
    TravelLocation(id: 'athens', name: 'Athens', country: 'Greece', region: 'Europe', latitude: 37.9838, longitude: 23.7275, emoji: '🇬🇷', airportCode: 'ATH'),
    TravelLocation(id: 'santorini', name: 'Santorini', country: 'Greece', region: 'Mediterranean', latitude: 36.3932, longitude: 25.4615, emoji: '🏛️', airportCode: 'JTR'),
    TravelLocation(id: 'lisbon', name: 'Lisbon', country: 'Portugal', region: 'Europe', latitude: 38.7223, longitude: -9.1393, emoji: '🇵🇹', airportCode: 'LIS'),
    TravelLocation(id: 'porto', name: 'Porto', country: 'Portugal', region: 'Europe', latitude: 41.1579, longitude: -8.6291, emoji: '🇵🇹', airportCode: 'OPO'),
    TravelLocation(id: 'dublin', name: 'Dublin', country: 'Ireland', region: 'Europe', latitude: 53.3498, longitude: -6.2603, emoji: '🇮🇪', airportCode: 'DUB'),
    TravelLocation(id: 'oslo', name: 'Oslo', country: 'Norway', region: 'Nordic', latitude: 59.9139, longitude: 10.7522, emoji: '🇳🇴', airportCode: 'OSL'),
    TravelLocation(id: 'tromso', name: 'Tromso', country: 'Norway', region: 'Nordic', latitude: 69.6492, longitude: 18.9553, emoji: '🌌', airportCode: 'TOS'),
    TravelLocation(id: 'stockholm', name: 'Stockholm', country: 'Sweden', region: 'Nordic', latitude: 59.3293, longitude: 18.0686, emoji: '🇸🇪', airportCode: 'ARN'),
    TravelLocation(id: 'copenhagen', name: 'Copenhagen', country: 'Denmark', region: 'Nordic', latitude: 55.6761, longitude: 12.5683, emoji: '🇩🇰', airportCode: 'CPH'),
    TravelLocation(id: 'helsinki', name: 'Helsinki', country: 'Finland', region: 'Nordic', latitude: 60.1699, longitude: 24.9384, emoji: '🇫🇮', airportCode: 'HEL'),
    TravelLocation(id: 'reykjavik', name: 'Reykjavik', country: 'Iceland', region: 'Europe', latitude: 64.1466, longitude: -21.9426, emoji: '🇮🇸', airportCode: 'KEF'),

    // Middle East & Africa
    TravelLocation(id: 'dubai', name: 'Dubai', country: 'United Arab Emirates', region: 'Middle East', latitude: 25.2048, longitude: 55.2708, emoji: '🇦🇪', airportCode: 'DXB'),
    TravelLocation(id: 'abu_dhabi', name: 'Abu Dhabi', country: 'United Arab Emirates', region: 'Middle East', latitude: 24.4539, longitude: 54.3773, emoji: '🇦🇪', airportCode: 'AUH'),
    TravelLocation(id: 'doha', name: 'Doha', country: 'Qatar', region: 'Middle East', latitude: 25.2854, longitude: 51.5310, emoji: '🇶🇦', airportCode: 'DOH'),
    TravelLocation(id: 'riyadh', name: 'Riyadh', country: 'Saudi Arabia', region: 'Middle East', latitude: 24.7136, longitude: 46.6753, emoji: '🇸🇦', airportCode: 'RUH'),
    TravelLocation(id: 'cairo', name: 'Cairo', country: 'Egypt', region: 'Africa', latitude: 30.0444, longitude: 31.2357, emoji: '🇪🇬', airportCode: 'CAI'),
    TravelLocation(id: 'marrakech', name: 'Marrakech', country: 'Morocco', region: 'Africa', latitude: 31.6295, longitude: -7.9811, emoji: '🇲🇦', airportCode: 'RAK'),
    TravelLocation(id: 'cape_town', name: 'Cape Town', country: 'South Africa', region: 'Africa', latitude: -33.9249, longitude: 18.4241, emoji: '🇿🇦', airportCode: 'CPT'),
    TravelLocation(id: 'nairobi', name: 'Nairobi', country: 'Kenya', region: 'Africa', latitude: -1.2921, longitude: 36.8219, emoji: '🇰🇪', airportCode: 'NBO'),
    TravelLocation(id: 'maldives', name: 'Malé', country: 'Maldives', region: 'South Asia', latitude: 4.1755, longitude: 73.5093, emoji: '🏝️', airportCode: 'MLE'),

    // North America
    TravelLocation(id: 'new_york', name: 'New York City', country: 'United States', region: 'North America', latitude: 40.7128, longitude: -74.0060, emoji: '🗽', airportCode: 'JFK'),
    TravelLocation(id: 'los_angeles', name: 'Los Angeles', country: 'United States', region: 'North America', latitude: 34.0522, longitude: -118.2437, emoji: '🎬', airportCode: 'LAX'),
    TravelLocation(id: 'san_francisco', name: 'San Francisco', country: 'United States', region: 'North America', latitude: 37.7749, longitude: -122.4194, emoji: '🌁', airportCode: 'SFO'),
    TravelLocation(id: 'las_vegas', name: 'Las Vegas', country: 'United States', region: 'North America', latitude: 36.1699, longitude: -115.1398, emoji: '🎰', airportCode: 'LAS'),
    TravelLocation(id: 'chicago', name: 'Chicago', country: 'United States', region: 'North America', latitude: 41.8781, longitude: -87.6298, emoji: '🏙️', airportCode: 'ORD'),
    TravelLocation(id: 'miami', name: 'Miami', country: 'United States', region: 'North America', latitude: 25.7617, longitude: -80.1918, emoji: '🌴', airportCode: 'MIA'),
    TravelLocation(id: 'seattle', name: 'Seattle', country: 'United States', region: 'North America', latitude: 47.6062, longitude: -122.3321, emoji: '🌲', airportCode: 'SEA'),
    TravelLocation(id: 'toronto', name: 'Toronto', country: 'Canada', region: 'North America', latitude: 43.6532, longitude: -79.3832, emoji: '🇨🇦', airportCode: 'YYZ'),
    TravelLocation(id: 'vancouver', name: 'Vancouver', country: 'Canada', region: 'North America', latitude: 49.2827, longitude: -123.1207, emoji: '🍁', airportCode: 'YVR'),
    TravelLocation(id: 'montreal', name: 'Montreal', country: 'Canada', region: 'North America', latitude: 45.5017, longitude: -73.5673, emoji: '⚜️', airportCode: 'YUL'),
    TravelLocation(id: 'mexico_city', name: 'Mexico City', country: 'Mexico', region: 'North America', latitude: 19.4326, longitude: -99.1332, emoji: '🇲🇽', airportCode: 'MEX'),
    TravelLocation(id: 'cancun', name: 'Cancún', country: 'Mexico', region: 'North America', latitude: 21.1619, longitude: -86.8515, emoji: '🏖️', airportCode: 'CUN'),

    // Oceania & South America
    TravelLocation(id: 'sydney', name: 'Sydney', country: 'Australia', region: 'Oceania', latitude: -33.8688, longitude: 151.2093, emoji: '🦘', airportCode: 'SYD'),
    TravelLocation(id: 'melbourne', name: 'Melbourne', country: 'Australia', region: 'Oceania', latitude: -37.8136, longitude: 144.9631, emoji: '🇦🇺', airportCode: 'MEL'),
    TravelLocation(id: 'auckland', name: 'Auckland', country: 'New Zealand', region: 'Oceania', latitude: -36.8485, longitude: 174.7633, emoji: '🇳🇿', airportCode: 'AKL'),
    TravelLocation(id: 'queenstown', name: 'Queenstown', country: 'New Zealand', region: 'Oceania', latitude: -45.0312, longitude: 168.6626, emoji: '🏔️', airportCode: 'ZQN'),
    TravelLocation(id: 'rio', name: 'Rio de Janeiro', country: 'Brazil', region: 'South America', latitude: -22.9068, longitude: -43.1729, emoji: '🇧🇷', airportCode: 'GIG'),
    TravelLocation(id: 'buenos_aires', name: 'Buenos Aires', country: 'Argentina', region: 'South America', latitude: -34.6037, longitude: -58.3816, emoji: '🇦🇷', airportCode: 'EZE'),
    TravelLocation(id: 'lima', name: 'Lima', country: 'Peru', region: 'South America', latitude: -12.0464, longitude: -77.0428, emoji: '🇵🇪', airportCode: 'LIM'),
    TravelLocation(id: 'santiago', name: 'Santiago', country: 'Chile', region: 'South America', latitude: -33.4489, longitude: -70.6693, emoji: '🇨🇱', airportCode: 'SCL'),
  ];

  /// Find matching locations or fallback to dynamically creating a valid TravelLocation for ANY query
  static List<TravelLocation> searchLocations(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return popularLocations;

    final matches = popularLocations.where((loc) {
      return loc.name.toLowerCase().contains(clean) ||
          loc.country.toLowerCase().contains(clean) ||
          loc.region.toLowerCase().contains(clean) ||
          (loc.airportCode != null && loc.airportCode!.toLowerCase().contains(clean));
    }).toList();

    return matches;
  }

  static TravelLocation? findExact(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return null;
    for (final loc in popularLocations) {
      if (loc.name.toLowerCase() == clean ||
          loc.id.toLowerCase() == clean ||
          loc.displayName.toLowerCase() == clean ||
          loc.airportCode?.toLowerCase() == clean) {
        return loc;
      }
    }
    return null;
  }

  /// Resolves any string query into a TravelLocation object.
  /// If not found in the pre-configured catalog, creates a display-only placeholder.
  /// Route calculations must use [resolveRouteLocation] for real geocoded coordinates.
  static TravelLocation resolveAnyLocation(String query, {String? defaultRegion}) {
    final clean = query.trim();
    if (clean.isEmpty) {
      return popularLocations.first;
    }

    final lower = clean.toLowerCase();
    for (final loc in popularLocations) {
      if (loc.name.toLowerCase() == lower || loc.id.toLowerCase() == lower) {
        return loc;
      }
      if (loc.displayName.toLowerCase().contains(lower)) {
        return loc;
      }
    }

    // Try prefix or substring matches
    for (final loc in popularLocations) {
      if (loc.name.toLowerCase().contains(lower) || loc.country.toLowerCase().contains(lower)) {
        return loc;
      }
    }

    return TravelLocation(
      id: 'custom_${clean.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}',
      name: clean,
      country: defaultRegion ?? 'Global Destination',
      region: defaultRegion ?? 'World',
      latitude: 0,
      longitude: 0,
      emoji: '📍',
      airportCode: clean.length >= 3 ? clean.substring(0, 3).toUpperCase() : 'LOC',
    );
  }
}
