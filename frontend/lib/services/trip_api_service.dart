import 'package:dio/dio.dart';
import '../models/itinerary.dart';
import '../models/trip.dart';
import 'api_client.dart';
import 'auth_api_service.dart';

class TripApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<Trip>> getTrips() async {
    try {
      final response = await _dio.get('/trips');
      if (response.data is List) {
        final List<dynamic> list = response.data as List<dynamic>;
        return list.map((item) => _mapBackendTrip(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Trip> createTrip({
    required String title,
    required String destinationName,
    required DateTime startDate,
    required DateTime endDate,
    String? coverImageUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/trips',
        data: {
          'title': title,
          'destinationName': destinationName,
          'startDate': startDate.toIso8601String().substring(0, 10),
          'endDate': endDate.toIso8601String().substring(0, 10),
          'coverImageUrl': coverImageUrl,
          'status': 'upcoming',
        },
      );
      return _mapBackendTrip(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _dio.delete('/trips/$tripId');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Trip _mapBackendTrip(Map<String, dynamic> json) {
    final start = json['startDate'] != null
        ? DateTime.parse(json['startDate'] as String)
        : DateTime.now();
    final end = json['endDate'] != null
        ? DateTime.parse(json['endDate'] as String)
        : start.add(const Duration(days: 3));

    final statusStr = json['status'] as String? ?? 'upcoming';
    TripStatus status = TripStatus.upcoming;
    if (statusStr.toLowerCase() == 'planning') {
      status = TripStatus.planning;
    } else if (statusStr.toLowerCase() == 'completed') {
      status = TripStatus.completed;
    }

    // Generate dummy itinerary days matching the trip duration if days not provided
    final int daysCount = end.difference(start).inDays + 1;
    final List<ItineraryDay> generatedDays = List.generate(
      daysCount > 0 ? daysCount : 1,
      (i) => ItineraryDay(
        dayNumber: i + 1,
        date: start.add(Duration(days: i)).toIso8601String().substring(0, 10),
        title: i == 0
            ? 'Arrival & Exploration'
            : (i == daysCount - 1 ? 'Departure & Reflection' : 'City Discovery'),
        activities: [
          ActivityItem(
            id: 'act_${json['id']}_$i',
            time: i == 0 ? '14:00' : '10:00',
            title: i == 0 ? 'Hotel Check-in & Orientation' : 'Local Cultural Tour',
            description: 'Enjoy the vibrant ambiance and local flavors.',
            location: json['destinationName'] as String? ?? 'City Center',
            duration: '2 hours',
            category: i == 0 ? ActivityCategory.transport : ActivityCategory.sightseeing,
          ),
        ],
      ),
    );

    return Trip(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Getaway',
      destinationId: json['destinationId'] as String? ?? json['id'] as String,
      destinationName: json['destinationName'] as String? ?? 'Destination',
      destinationCountry: json['destinationCountry'] as String? ?? 'World',
      destinationEmoji: '✈️',
      startDate: start,
      endDate: end,
      travelStyle: 'Boutique Explorer',
      totalBudget: 2400.0,
      spentAmount: 650.0,
      status: status,
      days: generatedDays,
      packingList: [
        PackingItem(id: 'pack_1', title: 'Passport & Travel ID', category: 'Essentials', isPacked: true),
        PackingItem(id: 'pack_2', title: 'Universal Adapter', category: 'Tech', isPacked: true),
        PackingItem(id: 'pack_3', title: 'Walking Shoes', category: 'Clothing', isPacked: false),
      ],
      gradientColorsHex: ['#006D77', '#83C5BE'],
    );
  }

  ApiException _mapError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      String? backendMsg;

      if (data is Map) {
        if (data['message'] != null && data['message'].toString().trim().isNotEmpty) {
          backendMsg = data['message'].toString().trim();
        } else if (data['error'] != null && data['error'].toString().trim().isNotEmpty) {
          backendMsg = data['error'].toString().trim();
        }
      } else if (data is String && data.trim().isNotEmpty) {
        backendMsg = data.trim();
      }

      if (statusCode == 409) {
        return ApiException(
          backendMsg ?? 'Date clash detected: You already have a booking overlapping these dates.',
          statusCode: statusCode,
        );
      }

      return ApiException(backendMsg ?? 'Trip operation failed.', statusCode: statusCode);
    }
    return ApiException('Could not connect to trip service. Please check your network.');
  }
}
