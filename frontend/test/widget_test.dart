import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/main.dart';
import 'package:test_app/screens/auth_screen.dart';
import 'package:test_app/screens/explore_screen.dart';
import 'package:test_app/screens/journey_screen.dart';
import 'package:test_app/screens/profile_screen.dart';
import 'package:test_app/screens/wishlist_screen.dart';
import 'package:test_app/services/travel_service.dart';

final Uint8List _kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets('AtlasTravelApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'seen_onboarding': true, 'is_logged_in': true});
    await tester.pumpWidget(const AtlasTravelApp());
    expect(find.text('ATLAS'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2500));
  });

  testWidgets('AuthScreen renders and toggles between Sign In and Create Account', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthScreen(initialIsLogin: true),
      ),
    );

    // Verify Sign In state
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Welcome\nBack!'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);

    // Tap 'Create Account' tab
    await tester.tap(find.text('Create Account').first);
    await tester.pumpAndSettle();

    // Verify Create Account state
    expect(find.text('Start Your\nJourney.'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
  });

  testWidgets('Hamburger menu displays dynamic logged-in user info', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'user_name': 'Samantha Reed',
      'user_email': 'samantha.reed@example.com',
    });
    final service = TravelService();
    await service.init();

    await tester.pumpWidget(
      MaterialApp(
        home: ExploreScreen(travelService: service),
      ),
    );

    // Verify menu button exists on home page
    final menuButton = find.byIcon(Icons.menu_rounded);
    expect(menuButton, findsOneWidget);

    // Tap hamburger menu
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    // Verify dynamic user contents from SharedPreferences
    expect(find.text('Samantha Reed'), findsOneWidget);
    expect(find.text('samantha.reed@example.com'), findsOneWidget);
    expect(find.text('Explore & Discover'), findsOneWidget);
    expect(find.text('My Bookings & Itineraries'), findsOneWidget);
  });

  testWidgets('AtlasPassportBook renders dynamic user name and flips to Visas', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'user_name': 'Samantha Reed',
      'user_email': 'samantha.reed@example.com',
    });
    final service = TravelService();
    await service.init();

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(travelService: service),
      ),
    );

    // Verify Travel License ID Card rendered with dynamic name
    expect(find.text('PERMANENT LICENSE OF TRAVEL'), findsOneWidget);
    expect(find.text('CALL ME IF YOU GET LOST'), findsOneWidget);
    expect(find.text('Photograph of Authorized traveler'), findsOneWidget);
    expect(find.text('Samantha Reed'), findsWidgets);

    // Flip to Visas Page 1
    await tester.tap(find.text('Visas 1'));
    await tester.pumpAndSettle();

    // Verify Visas page with authentic stamps
    expect(find.text('VISAS'), findsOneWidget);
    expect(find.text('PAGE 02'), findsOneWidget);
    expect(find.text('JAPAN'), findsOneWidget);
    expect(find.text('SWITZERLAND'), findsOneWidget);
  });

  testWidgets('WishlistScreen renders saved destinations and interactive controls', (WidgetTester tester) async {
    final service = TravelService();
    await service.init();

    await tester.pumpWidget(
      MaterialApp(
        home: WishlistScreen(travelService: service),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Wishlist Title and Header
    expect(find.text('Wishlist & Saved'), findsOneWidget);
    expect(find.text('Your Dream\nGetaways'), findsOneWidget);
    expect(find.text('Saved Places'), findsOneWidget);

    // Verify initial saved destinations appear (e.g. Bali, Kyoto, Paris)
    expect(find.text('Bali'), findsOneWidget);
    expect(find.text('Plan Trip'), findsWidgets);
  });

  testWidgets('JourneyScreen Bookings tab renders user info and multiple bookings', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'user_name': 'Alex Rivera',
      'user_email': 'alex.rivera@atlas.travel',
    });
    final service = TravelService();
    await service.init();

    await tester.pumpWidget(
      MaterialApp(
        home: JourneyScreen(travelService: service),
      ),
    );
    await tester.pumpAndSettle();

    // Verify user header
    expect(find.text('Alex Rivera'), findsOneWidget);
    expect(find.text('alex.rivera@atlas.travel'), findsOneWidget);
    expect(find.text('Active Bookings'), findsOneWidget);

    // Verify multi-booking switcher contains initial trips
    expect(find.text('Kyoto Zen & Cherry Blossom Discovery'), findsWidgets);
    expect(find.text('Bali Tropical Wellness Retreat'), findsWidgets);

    // Verify date clash check functionality
    final existingTrip = service.trips.first;
    final clash = service.checkDateClash(existingTrip.startDate, existingTrip.endDate);
    expect(clash, isNotNull);
    expect(clash!.id, equals(existingTrip.id));

    // Verify non-clashing dates return null
    final noClash = service.checkDateClash(
      DateTime(2035, 1, 1),
      DateTime(2035, 1, 5),
    );
    expect(noClash, isNull);
  });
}
