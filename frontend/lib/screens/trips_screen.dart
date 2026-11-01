import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/travel_service.dart';
import '../theme/app_theme.dart';
import '../widgets/trip_card.dart';
import 'itinerary_detail_screen.dart';
import 'planner_screen.dart';

class TripsScreen extends StatefulWidget {
  final TravelService travelService;

  const TripsScreen({super.key, required this.travelService});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  int _selectedTab = 0; // 0 = Upcoming, 1 = Planning, 2 = Completed

  @override
  Widget build(BuildContext context) {
    final service = widget.travelService;
    final upcoming = service.upcomingTrips;
    final planning = service.planningTrips;
    final completed = service.completedTrips;

    List<Trip> currentList;
    if (_selectedTab == 0) {
      currentList = upcoming;
    } else if (_selectedTab == 1) {
      currentList = planning;
    } else {
      currentList = completed;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Trips', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlannerScreen(travelService: service),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _segmentButton(0, 'Upcoming (${upcoming.length})'),
                  _segmentButton(1, 'Planning (${planning.length})'),
                  _segmentButton(2, 'Past (${completed.length})'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Trips List View
          Expanded(
            child: currentList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: currentList.length,
                    itemBuilder: (context, index) {
                      final trip = currentList[index];
                      return TripCard(
                        trip: trip,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItineraryDetailScreen(
                                trip: trip,
                                travelService: service,
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Trip'),
                              content: Text('Are you sure you want to remove ${trip.title}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    service.deleteTrip(trip.id);
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _segmentButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.luggage_outlined, size: 54, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'No trips found in this tab',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ready for your next journey? Let our AI planner synthesize your custom itinerary in seconds.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlannerScreen(travelService: widget.travelService),
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Plan a New Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
