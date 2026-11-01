import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/auth_api_service.dart';
import '../services/travel_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import 'planner_screen.dart';

class JourneyScreen extends StatefulWidget {
  final TravelService travelService;

  const JourneyScreen({super.key, required this.travelService});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  int _selectedTripIndex = 0;
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final service = widget.travelService;
    final profile = service.userProfile;
    final trips = service.trips;

    if (_selectedTripIndex >= trips.length && trips.isNotEmpty) {
      _selectedTripIndex = 0;
    }

    final Trip? currentTrip = trips.isNotEmpty ? trips[_selectedTripIndex] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AtlasAppDrawer(
        travelService: service,
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (scaffoldContext) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF006D77), size: 26),
              onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
            );
          },
        ),
        title: const Text(
          'My Bookings & Itineraries',
          style: TextStyle(
            color: Color(0xFF08495A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF006D77), size: 26),
            tooltip: 'Book New Trip',
            onPressed: () => _showAddBookingDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: trips.isEmpty
          ? _buildEmptyBookingsState(profile)
          : RefreshIndicator(
              onRefresh: () async {
                await service.fetchTripsFromBackend();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. User Info Header
                    _buildUserHeader(profile, trips.length),

                    const SizedBox(height: 18),

                    // 2. Multi-Booking Switcher / Carousel
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Active Bookings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF08495A),
                          ),
                        ),
                        Text(
                          '${trips.length} Total',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00798C),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Horizontal Cards for Multiple Bookings
                    _buildBookingsCarousel(trips),

                    const SizedBox(height: 24),

                    // 3. Active Trip Details & Day Selector
                    if (currentTrip != null) ...[
                      _buildActiveTripHeader(currentTrip),

                      const SizedBox(height: 16),

                      // Day Selector Pills
                      if (currentTrip.days.isNotEmpty)
                        _buildDaysSelector(currentTrip),

                      const SizedBox(height: 20),

                      // Day-by-Day Timeline
                      _buildDynamicTimeline(currentTrip),
                    ],
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBookingDialog(context),
        backgroundColor: const Color(0xFF006D77),
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text(
          'New Booking',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // Header showing real-time user profile info
  Widget _buildUserHeader(dynamic profile, int tripsCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF006D77),
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
              style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF08495A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF006D77).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.luggage_rounded, color: Color(0xFF006D77), size: 16),
                const SizedBox(width: 4),
                Text(
                  '$tripsCount ${tripsCount == 1 ? 'Trip' : 'Trips'}',
                  style: const TextStyle(
                    color: Color(0xFF006D77),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Multi-Booking Horizontal Carousel
  Widget _buildBookingsCarousel(List<Trip> trips) {
    return SizedBox(
      height: 165,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: trips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final trip = trips[index];
          final isSelected = index == _selectedTripIndex;

          final startMonth = trip.startDate.month;
          final startDay = trip.startDate.day;
          final endMonth = trip.endDate.month;
          final endDay = trip.endDate.day;
          final dateStr = '$startMonth/$startDay - $endMonth/$endDay';

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTripIndex = index;
                _selectedDayIndex = 0;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 250,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF006D77) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF006D77) : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF006D77).withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : const Color(0xFF006D77).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trip.status.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF006D77),
                          ),
                        ),
                      ),
                      // Delete Trip Button
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: isSelected ? Colors.white70 : Colors.red.shade400,
                        ),
                        tooltip: 'Cancel Booking',
                        onPressed: () => _confirmDeleteTrip(trip),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF08495A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${trip.destinationName} • ${trip.destinationCountry}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white70 : const Color(0xFF7A8B94),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: isSelected ? Colors.white70 : const Color(0xFF00798C),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF00798C),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${trip.durationInDays}d',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF08495A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Active Trip Header
  Widget _buildActiveTripHeader(Trip trip) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF006D77),
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${trip.destinationName} • ${trip.startDate.month}/${trip.startDate.day} - ${trip.endDate.month}/${trip.endDate.day}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF7A8B94),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlannerScreen(travelService: widget.travelService),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006D77),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.edit_calendar_rounded, size: 16),
          label: const Text('Planner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Days Selector Pills
  Widget _buildDaysSelector(Trip trip) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: trip.days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDayIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF006D77) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF006D77) : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  'Day ${trip.days[index].dayNumber}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF08495A),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Dynamic Day-by-Day Timeline
  Widget _buildDynamicTimeline(Trip trip) {
    if (trip.days.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text('No activities scheduled for this trip yet.'),
        ),
      );
    }

    final currentDay = _selectedDayIndex < trip.days.length
        ? trip.days[_selectedDayIndex]
        : trip.days.first;

    final activities = currentDay.activities;

    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.explore_outlined, color: Color(0xFF006D77), size: 36),
              const SizedBox(height: 8),
              Text(
                'Day ${currentDay.dayNumber}: ${currentDay.title}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                'No activities added yet. Tap "Planner" to customize.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Day ${currentDay.dayNumber}: ${currentDay.title}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF08495A),
          ),
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (context, _) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final act = activities[i];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006D77).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.place_rounded, color: Color(0xFF006D77), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              act.time,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00798C),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                act.duration,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          act.title,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2D35),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          act.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (act.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            act.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7C85),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Empty State
  Widget _buildEmptyBookingsState(dynamic profile) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF006D77).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flight_takeoff_rounded, color: Color(0xFF006D77), size: 48),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Bookings Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF08495A)),
            ),
            const SizedBox(height: 8),
            Text(
              'Hello ${profile.name}! You have no active trip bookings scheduled. Plan a trip now to explore the world.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF7A8B94), fontSize: 13.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddBookingDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006D77),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Book Your First Trip', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Delete Trip Confirmation Modal
  void _confirmDeleteTrip(Trip trip) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 28),
              const SizedBox(width: 8),
              const Text('Cancel Booking?'),
            ],
          ),
          content: Text(
            'Are you sure you want to cancel and delete your booking for "${trip.title}" (${trip.destinationName})?\n\nThis will remove the trip from your database.',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Trip', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await widget.travelService.deleteTrip(trip.id);
                if (mounted) {
                  setState(() {
                    _selectedTripIndex = 0;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Booking for "${trip.title}" deleted.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Delete Trip'),
            ),
          ],
        );
      },
    );
  }

  // Interactive Add Booking Dialog with Real-Time Date Clash Detection
  void _showAddBookingDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: 'Paris Holiday');
    final destCtrl = TextEditingController(text: 'Paris, France');
    DateTime startDate = DateTime.now().add(const Duration(days: 7));
    DateTime endDate = DateTime.now().add(const Duration(days: 12));
    String? clashErrorMessage;
    bool isSaving = false;

    // Validate clashes initially
    Trip? initialClash = widget.travelService.checkDateClash(startDate, endDate);
    if (initialClash != null) {
      clashErrorMessage =
          "Date Clash: Overlaps with '${initialClash.title}' (${initialClash.startDate.month}/${initialClash.startDate.day} - ${initialClash.endDate.month}/${initialClash.endDate.day}).";
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void validateDates() {
              final clash = widget.travelService.checkDateClash(startDate, endDate);
              setModalState(() {
                if (clash != null) {
                  clashErrorMessage =
                      "Date Clash: Overlaps with '${clash.title}' (${clash.startDate.month}/${clash.startDate.day} - ${clash.endDate.month}/${clash.endDate.day}). Please pick other dates.";
                } else {
                  clashErrorMessage = null;
                }
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bookmark_add_rounded, color: Color(0xFF006D77)),
                            SizedBox(width: 8),
                            Text(
                              'Book a New Trip',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF08495A),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Title
                    const Text('Trip Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. Summer Vacation',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Destination
                    const Text('Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: destCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. Rome, Italy',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Date Range Picker Row
                    const Text('Travel Dates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 730)),
                          initialDateRange: DateTimeRange(start: startDate, end: endDate),
                        );
                        if (picked != null) {
                          setModalState(() {
                            startDate = picked.start;
                            endDate = picked.end;
                          });
                          validateDates();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: clashErrorMessage != null ? Colors.red.shade400 : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.date_range_rounded, color: Color(0xFF006D77), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${startDate.month}/${startDate.day}/${startDate.year}  →  ${endDate.month}/${endDate.day}/${endDate.year}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                            const Text('Change', style: TextStyle(color: Color(0xFF006D77), fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),

                    // Date Clash Alert Banner
                    if (clashErrorMessage != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECE8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                clashErrorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Dates are available! No overlapping bookings.',
                            style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Confirm Booking Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (clashErrorMessage != null || isSaving)
                            ? null
                            : () async {
                                setModalState(() => isSaving = true);
                                try {
                                  await widget.travelService.createBooking(
                                    title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : 'Holiday',
                                    destinationName: destCtrl.text.trim().isNotEmpty ? destCtrl.text.trim() : 'Destination',
                                    startDate: startDate,
                                    endDate: endDate,
                                  );

                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                    setState(() {
                                      _selectedTripIndex = 0;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Booking confirmed & saved successfully!'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } on ApiException catch (e) {
                                  setModalState(() {
                                    isSaving = false;
                                    clashErrorMessage = e.message;
                                  });
                                } catch (_) {
                                  setModalState(() => isSaving = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006D77),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Confirm Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
