import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_data.dart';
import '../models/destination.dart';
import '../models/itinerary.dart';
import '../models/trip.dart';
import '../models/user_profile.dart';
import 'auth_api_service.dart';
import 'token_storage.dart';
import 'trip_api_service.dart';

class TravelService extends ChangeNotifier {
  final List<Destination> _destinations = List.from(MockData.destinations);
  List<Trip> _trips = [];
  Set<String> _favoriteIds = {};
  UserProfile _userProfile = MockData.getUserProfile();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<Destination> get destinations => _destinations;
  List<Trip> get trips => _trips;
  Set<String> get favoriteIds => _favoriteIds;
  UserProfile get userProfile => _userProfile;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  void updateUserProfile(UserProfile updated) {
    _userProfile = updated;
    _saveUserProfile();
    notifyListeners();
  }

  void addPassportStamp(PassportStamp stamp) {
    final updatedStamps = List<PassportStamp>.from(_userProfile.stamps)..add(stamp);
    _userProfile = _userProfile.copyWith(
      stamps: updatedStamps,
      countriesVisited: _userProfile.countriesVisited + 1,
    );
    _saveUserProfile();
    notifyListeners();
  }

  List<Destination> get filteredDestinations {
    return _destinations.where((dest) {
      final matchesCategory = _selectedCategory == 'All' ||
          dest.category == _selectedCategory ||
          (_selectedCategory == 'Trending' && dest.isFeatured);

      final matchesQuery = _searchQuery.isEmpty ||
          dest.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dest.country.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dest.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesCategory && matchesQuery;
    }).toList();
  }

  List<Destination> get favoriteDestinations {
    return _destinations.where((d) => _favoriteIds.contains(d.id)).toList();
  }

  List<Trip> get upcomingTrips =>
      _trips.where((t) => t.status == TripStatus.upcoming).toList();

  List<Trip> get planningTrips =>
      _trips.where((t) => t.status == TripStatus.planning).toList();

  List<Trip> get completedTrips =>
      _trips.where((t) => t.status == TripStatus.completed).toList();

  Future<void> reloadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _loadUserProfileFromPrefs(prefs);
    notifyListeners();
  }

  Future<void> _saveUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userProfile.name);
    await prefs.setString('user_email', _userProfile.email);
    await prefs.setString('user_bio', _userProfile.bio);
    await prefs.setString('user_photo_url', _userProfile.photoUrl);
    await prefs.setString('user_dob', _userProfile.dateOfBirth);
    await prefs.setString('user_place_of_issue', _userProfile.placeOfIssue);
    await prefs.setString('user_date_of_issue', _userProfile.dateOfIssue);
    await prefs.setString('user_license_number', _userProfile.licenseNumber);
    await prefs.setString('user_signature', _userProfile.effectiveSignature);
    await prefs.setString('user_card_color', _userProfile.cardColor);
    await prefs.setString('user_avatar', _userProfile.avatarUrl);
  }

  void _loadUserProfileFromPrefs(SharedPreferences prefs) {
    final userName = prefs.getString('user_name');
    final userEmail = prefs.getString('user_email');
    final userBio = prefs.getString('user_bio');
    final userPhotoUrl = prefs.getString('user_photo_url');
    final userDob = prefs.getString('user_dob');
    final userPlaceOfIssue = prefs.getString('user_place_of_issue');
    final userDateOfIssue = prefs.getString('user_date_of_issue');
    final userLicenseNumber = prefs.getString('user_license_number');
    final userSignature = prefs.getString('user_signature');
    final userCardColor = prefs.getString('user_card_color');
    final userAvatar = prefs.getString('user_avatar');

    if (userName != null && userName.isNotEmpty) {
      _userProfile = _userProfile.copyWith(
        name: userName,
        email: userEmail ?? _userProfile.email,
        bio: userBio ?? _userProfile.bio,
        photoUrl: userPhotoUrl ?? _userProfile.photoUrl,
        dateOfBirth: userDob ?? _userProfile.dateOfBirth,
        placeOfIssue: userPlaceOfIssue ?? _userProfile.placeOfIssue,
        dateOfIssue: userDateOfIssue ?? _userProfile.dateOfIssue,
        licenseNumber: userLicenseNumber ?? _userProfile.licenseNumber,
        signature: (userSignature != null && userSignature.isNotEmpty) ? userSignature : userName,
        cardColor: userCardColor ?? _userProfile.cardColor,
        avatarUrl: userAvatar ?? _userProfile.avatarUrl,
      );
    } else if (userEmail != null && userEmail.isNotEmpty) {
      _userProfile = _userProfile.copyWith(
        email: userEmail,
      );
    }
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load favorites
    final favList = prefs.getStringList('favorite_destinations');
    if (favList != null) {
      _favoriteIds = favList.toSet();
    } else {
      _favoriteIds = {'dest_bali', 'dest_kyoto', 'dest_paris'};
    }

    // Load trips
    final tripsJson = prefs.getString('user_trips');
    if (tripsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(tripsJson) as List<dynamic>;
        _trips = decoded.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _trips = MockData.getInitialTrips();
      }
    } else {
      _trips = MockData.getInitialTrips();
    }

    // Load user profile from storage
    _loadUserProfileFromPrefs(prefs);

    _isInitialized = true;
    notifyListeners();

    // Fetch real-time trips from backend if user is logged in
    fetchTripsFromBackend();
  }

  final TripApiService _tripApiService = TripApiService();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<void> fetchTripsFromBackend() async {
    try {
      final hasToken = await _tokenStorage.isLoggedIn();
      if (!hasToken) return;

      final backendTrips = await _tripApiService.getTrips();
      if (backendTrips.isNotEmpty) {
        _trips = backendTrips;
        await _saveTrips();
        notifyListeners();
      }
    } catch (_) {
      // Offline fallback: keep local cached trips
    }
  }

  /// Checks if the requested date range clashes with any existing booking.
  /// Returns the conflicting [Trip] if any clash is found, or null otherwise.
  Trip? checkDateClash(DateTime start, DateTime end, {String? excludeTripId}) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);

    for (final trip in _trips) {
      if (excludeTripId != null && trip.id == excludeTripId) continue;
      final tripStart = DateTime(trip.startDate.year, trip.startDate.month, trip.startDate.day);
      final tripEnd = DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day);

      // Overlap formula: Not (end before existing start OR start after existing end)
      final bool clashing = !(endDay.isBefore(tripStart) || startDay.isAfter(tripEnd));
      if (clashing) {
        return trip;
      }
    }
    return null;
  }

  Future<Trip> createBooking({
    required String title,
    required String destinationName,
    required DateTime startDate,
    required DateTime endDate,
    String? coverImageUrl,
  }) async {
    final clash = checkDateClash(startDate, endDate);
    if (clash != null) {
      final startStr = '${clash.startDate.month}/${clash.startDate.day}';
      final endStr = '${clash.endDate.month}/${clash.endDate.day}';
      throw ApiException(
        "Date clash: You already have a booking for '${clash.title}' from $startStr to $endStr. Please choose different dates.",
      );
    }

    try {
      final newTrip = await _tripApiService.createTrip(
        title: title,
        destinationName: destinationName,
        startDate: startDate,
        endDate: endDate,
        coverImageUrl: coverImageUrl,
      );
      _trips.insert(0, newTrip);
      await _saveTrips();
      notifyListeners();
      return newTrip;
    } catch (e) {
      // Local/offline creation if backend call fails or not reachable
      final localTrip = Trip(
        id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        destinationId: 'dest_${DateTime.now().millisecondsSinceEpoch}',
        destinationName: destinationName,
        destinationCountry: 'World',
        destinationEmoji: '✈️',
        startDate: startDate,
        endDate: endDate,
        travelStyle: 'Custom Getaway',
        totalBudget: 2000.0,
        days: [
          ItineraryDay(
            dayNumber: 1,
            date: startDate.toIso8601String().substring(0, 10),
            title: 'Arrival & Welcome',
            activities: [
              ActivityItem(
                id: 'act_1',
                time: '15:00',
                title: 'Check-in & Exploration',
                description: 'Settle in and explore the surrounding neighborhood.',
                location: destinationName,
                duration: '2 hours',
                category: ActivityCategory.sightseeing,
              ),
            ],
          ),
        ],
        packingList: [],
        gradientColorsHex: ['#006D77', '#83C5BE'],
      );
      _trips.insert(0, localTrip);
      await _saveTrips();
      notifyListeners();
      return localTrip;
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_destinations', _favoriteIds.toList());
  }

  Future<void> _saveTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_trips.map((t) => t.toJson()).toList());
    await prefs.setString('user_trips', jsonStr);
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool isFavorite(String destinationId) {
    return _favoriteIds.contains(destinationId);
  }

  void toggleFavorite(String destinationId) {
    if (_favoriteIds.contains(destinationId)) {
      _favoriteIds.remove(destinationId);
    } else {
      _favoriteIds.add(destinationId);
    }
    _saveFavorites();
    notifyListeners();
  }

  void addTrip(Trip trip) {
    _trips.insert(0, trip);
    _saveTrips();
    notifyListeners();
  }

  void updateTrip(Trip updatedTrip) {
    final index = _trips.indexWhere((t) => t.id == updatedTrip.id);
    if (index != -1) {
      _trips[index] = updatedTrip;
      _saveTrips();
      notifyListeners();
    }
  }

  Future<void> deleteTrip(String tripId) async {
    _trips.removeWhere((t) => t.id == tripId);
    await _saveTrips();
    notifyListeners();

    try {
      await _tripApiService.deleteTrip(tripId);
    } catch (_) {
      // Best-effort remote deletion
    }
  }

  void toggleActivityComplete(String tripId, int dayNumber, String activityId) {
    final tripIndex = _trips.indexWhere((t) => t.id == tripId);
    if (tripIndex != -1) {
      final trip = _trips[tripIndex];
      final day = trip.days.firstWhere(
        (d) => d.dayNumber == dayNumber,
        orElse: () => trip.days.first,
      );
      final activity = day.activities.firstWhere((a) => a.id == activityId);
      activity.isCompleted = !activity.isCompleted;
      _saveTrips();
      notifyListeners();
    }
  }

  void togglePackingItem(String tripId, String itemId) {
    final tripIndex = _trips.indexWhere((t) => t.id == tripId);
    if (tripIndex != -1) {
      final item = _trips[tripIndex].packingList.firstWhere((p) => p.id == itemId);
      item.isPacked = !item.isPacked;
      _saveTrips();
      notifyListeners();
    }
  }

  void addPackingItem(String tripId, String title, String category) {
    final tripIndex = _trips.indexWhere((t) => t.id == tripId);
    if (tripIndex != -1) {
      _trips[tripIndex].packingList.add(
        PackingItem(
          id: 'p_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          category: category,
        ),
      );
      _saveTrips();
      notifyListeners();
    }
  }

  Trip generateAITrip({
    required Destination destination,
    required DateTime startDate,
    required int daysCount,
    required String travelStyle,
    required double budget,
    required int travelersCount,
    required List<String> vibeTags,
  }) {
    final endDate = startDate.add(Duration(days: daysCount - 1));
    final List<ItineraryDay> generatedDays = [];

    final sampleTemplates = [
      {
        'theme': 'Arrival, Acclimatization & Local Flavors',
        'activities': [
          {
            'time': '10:00 AM',
            'title': 'Boutique Hotel Arrival & Welcome Refreshment',
            'desc': 'Check-in, unpack and enjoy panoramic city terrace views.',
            'cat': ActivityCategory.relaxation,
            'loc': '${destination.name} Central',
            'dur': '2 hours',
          },
          {
            'time': '01:30 PM',
            'title': 'Authentic Local Culinary Tasting',
            'desc': 'Savor regional specialties and handcrafted teas.',
            'cat': ActivityCategory.food,
            'loc': 'Old Town Market',
            'dur': '1.5 hours',
          },
          {
            'time': '04:30 PM',
            'title': 'Orientation Walk & Golden Hour Photography',
            'desc': 'Discover historic landmarks in the warm evening light.',
            'cat': ActivityCategory.sightseeing,
            'loc': destination.name,
            'dur': '2.5 hours',
          },
        ],
      },
      {
        'theme': 'Iconic Highlights & Scenic Adventures',
        'activities': [
          {
            'time': '08:30 AM',
            'title': destination.attractions.isNotEmpty
                ? destination.attractions.first.name
                : 'Top Landmark Exploration',
            'desc': destination.attractions.isNotEmpty
                ? destination.attractions.first.description
                : 'Immerse in the most iconic landmark of the region.',
            'cat': ActivityCategory.culture,
            'loc': destination.name,
            'dur': '3 hours',
          },
          {
            'time': '01:00 PM',
            'title': 'Scenic Lunch with Panorama View',
            'desc': 'Enjoy farm-to-table lunch overlooking stunning landscapes.',
            'cat': ActivityCategory.food,
            'loc': 'Cliffside Bistro',
            'dur': '1.5 hours',
          },
          {
            'time': '03:30 PM',
            'title': 'Guided Nature Trail & Hidden Gems',
            'desc': 'Explore off-the-beaten-path paths curated by AI.',
            'cat': ActivityCategory.adventure,
            'loc': 'Valley Viewpoint',
            'dur': '2.5 hours',
          },
        ],
      },
      {
        'theme': 'Cultural Immersion & Sunset Serenity',
        'activities': [
          {
            'time': '09:30 AM',
            'title': 'Artisanal Workshop & Artisan Market',
            'desc': 'Handmade crafts, pottery, and vibrant local interactions.',
            'cat': ActivityCategory.culture,
            'loc': 'Craft District',
            'dur': '2 hours',
          },
          {
            'time': '02:00 PM',
            'title': 'Leisure & Wellness Spa Session',
            'desc': 'Recharge with rejuvenating herbal treatments.',
            'cat': ActivityCategory.relaxation,
            'loc': 'Wellness Spa Garden',
            'dur': '2 hours',
          },
          {
            'time': '06:00 PM',
            'title': 'Sunset Cruise & Farewell Dinner',
            'desc': 'Unforgettable golden sunset followed by dinner under the stars.',
            'cat': ActivityCategory.food,
            'loc': 'Waterfront Promenade',
            'dur': '3 hours',
          },
        ],
      },
    ];

    for (int i = 0; i < daysCount; i++) {
      final template = sampleTemplates[i % sampleTemplates.length];
      final dayNumber = i + 1;
      final dayActivities = (template['activities'] as List<Map<String, dynamic>>).map((act) {
        return ActivityItem(
          id: 'act_${dayNumber}_${DateTime.now().millisecondsSinceEpoch}_${act['title'].hashCode.abs()}',
          time: act['time'] as String,
          title: act['title'] as String,
          description: act['desc'] as String,
          category: act['cat'] as ActivityCategory,
          location: act['loc'] as String,
          duration: act['dur'] as String,
          estimatedCost: budget / (daysCount * 3),
        );
      }).toList();

      generatedDays.add(
        ItineraryDay(
          dayNumber: dayNumber,
          date: 'Day $dayNumber',
          title: template['theme'] as String,
          activities: dayActivities,
        ),
      );
    }

    final newTrip = Trip(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      title: '${destination.name} $travelStyle Adventure',
      destinationId: destination.id,
      destinationName: destination.name,
      destinationCountry: destination.country,
      destinationEmoji: destination.emoji,
      startDate: startDate,
      endDate: endDate,
      travelStyle: travelStyle,
      totalBudget: budget,
      spentAmount: 0.0,
      travelersCount: travelersCount,
      status: TripStatus.upcoming,
      gradientColorsHex: destination.gradientColorsHex,
      days: generatedDays,
      packingList: [
        PackingItem(id: 'p_1', title: 'Passport & Travel Docs', category: 'Essentials', isPacked: false),
        PackingItem(id: 'p_2', title: 'Comfortable Walking Shoes', category: 'Clothing', isPacked: false),
        PackingItem(id: 'p_3', title: 'Camera & Charger', category: 'Tech', isPacked: false),
        PackingItem(id: 'p_4', title: 'Portable Power Bank', category: 'Tech', isPacked: false),
        PackingItem(id: 'p_5', title: 'First Aid & Meds', category: 'Essentials', isPacked: false),
      ],
    );

    addTrip(newTrip);
    return newTrip;
  }
}
