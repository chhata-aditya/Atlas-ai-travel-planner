import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/data/world_locations_data.dart';
import 'package:test_app/models/transport_mode.dart';
import 'package:test_app/screens/search_screen.dart';
import 'package:test_app/services/transport_service.dart';
import 'package:test_app/services/travel_service.dart';

void main() {
  group('TravelDistance & Location Resolver Tests', () {
    test('Calculates accurate Haversine distance between cities', () {
      final delhi = WorldLocationsData.popularLocations.firstWhere((l) => l.id == 'delhi');
      final mumbai = WorldLocationsData.popularLocations.firstWhere((l) => l.id == 'mumbai');

      final distance = delhi.distanceTo(mumbai);
      // Delhi to Mumbai is approx 1,140 - 1,170 km
      expect(distance, greaterThan(1100));
      expect(distance, lessThan(1250));
    });

    test('Calculates short distance accurately (Mumbai to Pune)', () {
      final mumbai = WorldLocationsData.popularLocations.firstWhere((l) => l.id == 'mumbai');
      final pune = WorldLocationsData.popularLocations.firstWhere((l) => l.id == 'pune');

      final distance = mumbai.distanceTo(pune);
      // Mumbai to Pune is approx 120 km
      expect(distance, greaterThan(100));
      expect(distance, lessThan(150));
    });

    test('Resolves custom location anywhere in the world', () {
      final custom = WorldLocationsData.resolveAnyLocation('Reykjavik, Iceland');
      expect(custom.name, contains('Reykjavik'));
      expect(custom.latitude, isNotNull);
      expect(custom.longitude, isNotNull);

      final anywhere = WorldLocationsData.resolveAnyLocation('My Remote Hometown');
      expect(anywhere.name, equals('My Remote Hometown'));
      expect(anywhere.id, startsWith('custom_'));
    });
  });

  group('TransportService Multi-Modal Rules', () {
    test('Short overland route (< 160 km) recommends Road Trip / Car', () {
      final mumbai = WorldLocationsData.popularLocations.firstWhere((l) => l.id == 'mumbai');
      final pune = WorldLocationsData.popularLocations.firstWhere((l) => l.id == 'pune');

      final options = TransportService.calculateTransportOptions(
        origin: mumbai,
        destination: pune,
      );

      expect(options, isNotEmpty);
      final recommended = options.firstWhere((o) => o.isRecommended);
      expect(recommended.type, equals(TransportType.car));
      expect(recommended.badge, equals('RECOMMENDED'));
    });

    test('Medium overland route (160 - 750 km) recommends High-Speed Train', () {
      final paris = WorldLocationsData.popularLocations.firstWhere((l) => l.id == 'paris');
      final amsterdam = WorldLocationsData.popularLocations.firstWhere((l) => l.id == 'amsterdam');

      final options = TransportService.calculateTransportOptions(
        origin: paris,
        destination: amsterdam,
      );

      final recommended = options.firstWhere((o) => o.isRecommended);
      expect(recommended.type, equals(TransportType.train));
      expect(recommended.title, contains('Rail'));
    });

    test('Long-haul intercontinental route recommends Flight', () {
      final tokyo = WorldLocationsData.popularLocations.firstWhere((l) => l.id == 'tokyo');
      final newYork = WorldLocationsData.popularLocations.firstWhere((l) => l.id == 'new_york');

      final options = TransportService.calculateTransportOptions(
        origin: tokyo,
        destination: newYork,
      );

      final recommended = options.firstWhere((o) => o.isRecommended);
      expect(recommended.type, equals(TransportType.flight));
      expect(recommended.title, anyOf([contains('Flight'), contains('Jetliner')]));
    });
  });


  group('SearchScreen Route UI Widget Tests', () {
    testWidgets('Renders Route & Transport tab and calculates options', (tester) async {
      final service = TravelService();
      await tester.pumpWidget(
        MaterialApp(
          home: SearchScreen(
            travelService: service,
            initialOrigin: 'New Delhi',
            initialDestination: 'Mumbai',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify tab titles
      expect(find.text('Route & Transport'), findsOneWidget);
      expect(find.text('Browse Destinations'), findsOneWidget);

      // Verify Origin & Destination fields
      expect(find.text('New Delhi'), findsWidgets);
      expect(find.text('Mumbai'), findsWidgets);

      // Verify Distance Banner
      expect(find.textContaining('Distance:'), findsOneWidget);

      // Verify Transport options rendered
      expect(find.text('Available Transport Modes'), findsOneWidget);
      expect(find.text('BEST MODE FOR THIS DISTANCE'), findsOneWidget);
    });
  });
}
