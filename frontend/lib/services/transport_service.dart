import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../models/transport_mode.dart';

class TransportService {
  /// Computes all feasible transport options between [origin] and [destination],
  /// sorts them, and assigns the BEST MODE recommendation based on distance and feasibility.
  static List<TransportOption> calculateTransportOptions({
    required TravelLocation origin,
    required TravelLocation destination,
  }) {
    final double distanceKm = origin.distanceTo(destination);
    final List<TransportOption> options = [];

    final bool sameCountry = origin.countryCode != null &&
        destination.countryCode != null &&
        origin.countryCode == destination.countryCode;
    final bool knownDifferentCountries = origin.countryCode != null &&
        destination.countryCode != null &&
        origin.countryCode != destination.countryCode;
    final bool differentCountriesNearby = knownDifferentCountries && distanceKm <= 500;
    final bool separatedByWater = origin.isIsland == true || destination.isIsland == true ||
        (knownDifferentCountries && distanceKm > 500);
    final bool isLikelyOceanic = separatedByWater && distanceKm > 300;

    // 1. CAR / ROAD TRIP OPTION (Feasible up to 1,200 km overland)
    if (!separatedByWater && distanceKm < 1200 && !differentCountriesNearby) {
      final double carSpeedKmH = distanceKm < 100 ? 55.0 : 85.0;
      final int driveMinutes = ((distanceKm / carSpeedKmH) * 60).round() + 20; // +20m traffic/breaks
      final double fuelCost = (distanceKm * 0.12).clamp(15.0, 350.0);
      final double co2 = (distanceKm * 0.17).roundToDouble();

      final bool isRecommended = distanceKm < 160;
      options.add(
        TransportOption(
          type: TransportType.car,
          title: 'Road Trip / Rental Car',
          subtitle: 'Highway & scenic expressway',
          durationText: _formatDuration(driveMinutes),
          durationMinutes: driveMinutes,
          estimatedCostUSD: fuelCost,
          costRangeText: '\$${(fuelCost * 0.85).round()} - \$${(fuelCost * 1.3).round()}',
          co2Kg: co2,
          isRecommended: isRecommended,
          recommendationReason: isRecommended
              ? 'Fastest door-to-door option for short distances with flexible departure.'
              : 'Scenic and flexible for self-paced travel & group luggage.',
          badge: isRecommended ? 'RECOMMENDED' : 'MOST FLEXIBLE',
          icon: Icons.directions_car_rounded,
          themeColor: const Color(0xFF0077B6),
        ),
      );
    }

    // 2. HIGH-SPEED TRAIN / RAIL (Feasible up to 1,600 km overland)
    if (!separatedByWater && distanceKm < 1600 && distanceKm >= 50 && !differentCountriesNearby) {
      final double trainSpeedKmH = distanceKm < 300 ? 120.0 : 200.0;
      final int trainMinutes = ((distanceKm / trainSpeedKmH) * 60).round() + 30; // +30m boarding/station
      final double trainCost = (35.0 + distanceKm * 0.10).clamp(25.0, 240.0);
      final double co2 = (distanceKm * 0.04).roundToDouble(); // Extremely low carbon

      // Train is best between 160 km and 750 km (beats airports without flight hassle)
      final bool isRecommended = distanceKm >= 160 && distanceKm <= 750;
      options.add(
        TransportOption(
          type: TransportType.train,
          title: 'High-Speed Express Rail',
          subtitle: 'Direct city center to city center',
          durationText: _formatDuration(trainMinutes),
          durationMinutes: trainMinutes,
          estimatedCostUSD: trainCost,
          costRangeText: '\$${(trainCost * 0.8).round()} - \$${(trainCost * 1.25).round()}',
          co2Kg: co2,
          isRecommended: isRecommended,
          recommendationReason: isRecommended
              ? 'Best balance of speed and comfort. No airport check-in hassle, arrives directly downtown.'
              : 'Eco-friendly and scenic transit with onboard Wi-Fi and spacious seating.',
          badge: isRecommended ? 'RECOMMENDED' : 'ECO CHOICE',
          icon: Icons.train_rounded,
          themeColor: const Color(0xFF2A9D8F),
        ),
      );
    }

    // 3. EXPRESS COACH / BUS (Feasible up to 700 km overland - Budget option)
    if (!separatedByWater && distanceKm < 700 && distanceKm >= 40 && !differentCountriesNearby) {
      final double busSpeedKmH = 65.0;
      final int busMinutes = ((distanceKm / busSpeedKmH) * 60).round() + 45;
      final double busCost = (18.0 + distanceKm * 0.06).clamp(12.0, 95.0);
      final double co2 = (distanceKm * 0.07).roundToDouble();

      options.add(
        TransportOption(
          type: TransportType.bus,
          title: 'Intercity Express Bus',
          subtitle: 'Air-conditioned luxury coach',
          durationText: _formatDuration(busMinutes),
          durationMinutes: busMinutes,
          estimatedCostUSD: busCost,
          costRangeText: '\$${(busCost * 0.85).round()} - \$${(busCost * 1.2).round()}',
          co2Kg: co2,
          isRecommended: false,
          recommendationReason: 'Most economical choice for budget-conscious travelers.',
          badge: 'BEST VALUE',
          icon: Icons.directions_bus_rounded,
          themeColor: const Color(0xFFE76F51),
        ),
      );
    }

    // 4. FLIGHT (Feasible for medium/long haul, always available for distance > 250km or intercontinental)
    if (distanceKm >= 250 || isLikelyOceanic) {
      final double flightSpeedKmH = 800.0;
      final int airMinutes = ((distanceKm / flightSpeedKmH) * 60).round();
      // Add 2 hours for check-in, TSA security, taxiing, and luggage retrieval
      final int totalFlightMinutes = airMinutes + 120;

      double baseFlightCost;
      if (distanceKm < 800) {
        baseFlightCost = 110.0;
      } else if (distanceKm < 2500) {
        baseFlightCost = 180.0 + (distanceKm * 0.06);
      } else {
        baseFlightCost = 450.0 + (distanceKm * 0.075);
      }
      final double co2 = (distanceKm * 0.25).roundToDouble();

      final bool isRecommended = distanceKm > 750 || isLikelyOceanic;
      final bool isLongHaul = distanceKm > 2000;

      options.add(
        TransportOption(
          type: TransportType.flight,
          title: isLongHaul ? 'International Jetliner' : 'Direct Domestic Flight',
          subtitle: origin.airportCode != null && destination.airportCode != null
              ? '${origin.airportCode} ➔ ${destination.airportCode}'
              : 'Fast commercial flight route',
          durationText: _formatDuration(totalFlightMinutes),
          durationMinutes: totalFlightMinutes,
          estimatedCostUSD: baseFlightCost,
          costRangeText: '\$${(baseFlightCost * 0.85).round()} - \$${(baseFlightCost * 1.35).round()}',
          co2Kg: co2,
          isRecommended: isRecommended,
          recommendationReason: isRecommended
              ? 'Fastest way to cover this distance by far. Essential for intercontinental routes.'
              : 'Quick flight for tight schedules when time is your top priority.',
          badge: isRecommended ? 'RECOMMENDED' : 'FASTEST',
          icon: Icons.flight_takeoff_rounded,
          themeColor: const Color(0xFF006D77),
        ),
      );
    }

    // 5. FERRY / SEACROSSING (Island or coastal pairings, e.g. Bali, Maldives, Greece, Singapore)
    if (separatedByWater && distanceKm < 450) {
      final int ferryMinutes = ((distanceKm / 40.0) * 60).round() + 40;
      final double ferryCost = 45.0 + distanceKm * 0.15;
      final double co2 = (distanceKm * 0.12).roundToDouble();

      options.add(
        TransportOption(
          type: TransportType.ferry,
          title: 'High-Speed Ferry / Cruise',
          subtitle: 'Scenic coastal marine route',
          durationText: _formatDuration(ferryMinutes),
          durationMinutes: ferryMinutes,
          estimatedCostUSD: ferryCost,
          costRangeText: '\$${(ferryCost * 0.85).round()} - \$${(ferryCost * 1.3).round()}',
          co2Kg: co2,
          isRecommended: distanceKm < 180,
          recommendationReason: 'Enjoy panoramic ocean horizons and island-hopping convenience.',
          badge: distanceKm < 180 ? 'RECOMMENDED' : 'SCENIC CRUISE',
          icon: Icons.directions_boat_rounded,
          themeColor: const Color(0xFF023E8A),
        ),
      );
    }

    // Fallback: If no overland options produced (extremely short or unusual), ensure at least 1 car option
    if (options.isEmpty) {
      options.add(
        const TransportOption(
          type: TransportType.car,
          title: 'Local Shuttle / Private Cab',
          subtitle: 'Direct local transport',
          durationText: '45 mins',
          durationMinutes: 45,
          estimatedCostUSD: 25.0,
          costRangeText: '\$20 - \$35',
          co2Kg: 5.0,
          isRecommended: true,
          recommendationReason: 'Ideal for short neighborhood and intra-city travel.',
          badge: 'RECOMMENDED',
          icon: Icons.directions_car_rounded,
          themeColor: Color(0xFF0077B6),
        ),
      );
    }

    // Keep one clear primary recommendation while retaining alternative badges.
    int preferredIndex;
    if (distanceKm < 160) {
      preferredIndex = options.indexWhere((option) => option.type == TransportType.car);
    } else if (distanceKm <= 750 && !separatedByWater) {
      preferredIndex = options.indexWhere((option) => option.type == TransportType.train);
    } else {
      preferredIndex = options.indexWhere((option) => option.type == TransportType.flight);
    }
    if (preferredIndex < 0) preferredIndex = options.indexWhere((option) => option.type == TransportType.flight);
    if (preferredIndex < 0) preferredIndex = 0;
    for (var i = 0; i < options.length; i++) {
      final option = options[i];
      final recommended = i == preferredIndex;
      options[i] = TransportOption(
        type: option.type,
        title: option.title,
        subtitle: option.subtitle,
        durationText: option.durationText,
        durationMinutes: option.durationMinutes,
        estimatedCostUSD: option.estimatedCostUSD,
        costRangeText: option.costRangeText,
        co2Kg: option.co2Kg,
        isRecommended: recommended,
        recommendationReason: recommended
            ? _recommendationReason(option.type, distanceKm, separatedByWater)
            : option.recommendationReason,
        badge: recommended ? 'RECOMMENDED' : option.badge,
        icon: option.icon,
        themeColor: option.themeColor,
      );
    }

    // Sort options so that the RECOMMENDED option is at index 0, followed by Fastest / Cheaper
    options.sort((a, b) {
      if (a.isRecommended && !b.isRecommended) return -1;
      if (!a.isRecommended && b.isRecommended) return 1;
      return a.durationMinutes.compareTo(b.durationMinutes);
    });

    return options;
  }

  static String _recommendationReason(TransportType type, double distanceKm, bool separatedByWater) {
    switch (type) {
      case TransportType.car:
        return 'Best for a short route with flexible, door-to-door travel.';
      case TransportType.train:
        return 'Best balance of comfort, travel time, and lower emissions for this overland distance.';
      case TransportType.bus:
        return 'Most practical option available for this route.';
      case TransportType.flight:
        return separatedByWater
            ? 'Best practical choice for crossing this distance or water barrier.'
            : 'Best choice for covering this long distance quickly.';
      case TransportType.ferry:
        return 'Best direct option for this nearby water crossing.';
    }
  }

  static String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes mins';
    final int hours = minutes ~/ 60;
    final int remainingMins = minutes % 60;
    if (remainingMins == 0) return '$hours hrs';
    return '${hours}h ${remainingMins}m';
  }
}
