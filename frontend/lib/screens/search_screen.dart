import 'package:flutter/material.dart';
import '../data/world_locations_data.dart';
import '../models/location_model.dart';
import '../models/transport_mode.dart';
import '../services/transport_service.dart';
import '../services/location_geocoding_service.dart';
import '../services/travel_service.dart';
import '../theme/app_theme.dart';
import '../widgets/destination_card.dart';
import 'destination_detail_screen.dart';
import 'planner_screen.dart';

class SearchScreen extends StatefulWidget {
  final TravelService travelService;
  final String? initialOrigin;
  final String? initialDestination;

  const SearchScreen({
    super.key,
    required this.travelService,
    this.initialOrigin,
    this.initialDestination,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}
class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Route Planner State
  late TextEditingController _originController;
  late TextEditingController _destinationController;
  late TravelLocation _originLocation;
  late TravelLocation _destinationLocation;
  List<TransportOption> _transportOptions = [];
  final LocationGeocodingService _geocodingService = LocationGeocodingService();
  bool _isResolvingRoute = false;
  String? _routeError;

  // Destination Search State
  final TextEditingController _destinationSearchController = TextEditingController();
  String _selectedRegion = 'All';

  final List<String> _regions = [
    'All',
    'Southeast Asia',
    'Europe',
    'East Asia',
    'Mediterranean',
    'Africa',
    'North America',
    'Nordic',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final defaultOriginName = widget.initialOrigin ?? 'New Delhi';
    final defaultDestName = widget.initialDestination ?? 'Mumbai';

    _originController = TextEditingController(text: defaultOriginName);
    _destinationController = TextEditingController(text: defaultDestName);

    _originLocation = WorldLocationsData.resolveAnyLocation(defaultOriginName);
    _destinationLocation = WorldLocationsData.resolveAnyLocation(defaultDestName);

    _recalculateRoute();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _destinationSearchController.dispose();
    _geocodingService.dispose();
    super.dispose();
  }

  Future<void> _recalculateRoute() async {
    if (_originController.text.trim().isEmpty || _destinationController.text.trim().isEmpty) return;
    setState(() {
      _isResolvingRoute = true;
      _routeError = null;
    });
    try {
      final locations = await Future.wait([
        resolveRouteLocation(_originController.text),
        resolveRouteLocation(_destinationController.text),
      ]);
      if (!mounted) return;
      setState(() {
        _originLocation = locations[0];
        _destinationLocation = locations[1];
        _transportOptions = TransportService.calculateTransportOptions(
          origin: _originLocation,
          destination: _destinationLocation,
        );
        _isResolvingRoute = false;
      });
    } on LocationSearchException catch (e) {
      if (!mounted) return;
      setState(() {
        _isResolvingRoute = false;
        _routeError = e.message;
        _transportOptions = [];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isResolvingRoute = false;
        _routeError = 'Could not look up these places. Check your connection and try again.';
        _transportOptions = [];
      });
    }
  }

  void _swapLocations() {
    final tempText = _originController.text;
    _originController.text = _destinationController.text;
    _destinationController.text = tempText;
    _recalculateRoute();
  }

  Future<void> _openLocationPicker({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required Function(TravelLocation) onSelected,
  }) async {
    final searchCtrl = TextEditingController(text: controller.text);
    List<TravelLocation> filtered = WorldLocationsData.searchLocations(searchCtrl.text);
    bool isSearchingRemote = false;
    String? remoteSearchError;
    int searchGeneration = 0;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Search box
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7F8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: searchCtrl,
                      autofocus: true,
                      onChanged: (val) {
                        final generation = ++searchGeneration;
                        setSheetState(() {
                          filtered = WorldLocationsData.searchLocations(val);
                          isSearchingRemote = val.trim().length >= 2;
                          remoteSearchError = null;
                        });
                        if (val.trim().length >= 2) {
                          _geocodingService.search(val).then((results) {
                            if (!context.mounted) return;
                            if (generation != searchGeneration) return;
                            setSheetState(() {
                              filtered = [
                                ...WorldLocationsData.searchLocations(val),
                                ...results.where((result) => !WorldLocationsData.popularLocations
                                    .any((known) => known.displayName == result.displayName)),
                              ];
                              isSearchingRemote = false;
                            });
                          }).catchError((_) {
                            if (!context.mounted) return;
                            if (generation != searchGeneration) return;
                            setSheetState(() {
                              isSearchingRemote = false;
                              remoteSearchError = 'Place search is unavailable. Try again.';
                            });
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter any city, country, or code...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF006D77)),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  searchCtrl.clear();
                                  setSheetState(() {
                                    filtered = WorldLocationsData.popularLocations;
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'SEARCH WORLDWIDE PLACES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isSearchingRemote)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (remoteSearchError != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(remoteSearchError!, style: const TextStyle(color: Colors.red)),
                    ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final loc = filtered[idx];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F6F8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(loc.emoji, style: const TextStyle(fontSize: 18)),
                          ),
                          title: Text(
                            loc.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                          ),
                          subtitle: Text(
                            '${loc.country} • ${loc.region}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          trailing: loc.airportCode != null
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    loc.airportCode!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Color(0xFF006D77),
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            controller.text = loc.name;
                            onSelected(loc);
                            Navigator.pop(ctx);
                            _recalculateRoute();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Travel Anywhere', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF006D77),
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: const Color(0xFF006D77),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          tabs: const [
            Tab(icon: Icon(Icons.alt_route_rounded, size: 20), text: 'Route & Transport'),
            Tab(icon: Icon(Icons.explore_rounded, size: 20), text: 'Browse Destinations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoutePlannerTab(),
          _buildBrowseDestinationsTab(),
        ],
      ),
    );
  }

  // TAB 1: ANYWHERE TO ANYWHERE + MULTI-MODAL COMPARISON
  Widget _buildRoutePlannerTab() {
    final double distanceKm = _originLocation.distanceTo(_destinationLocation);
    final double distanceMiles = distanceKm * 0.621371;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Origin & Destination Card with Swap
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Column(
                  children: [
                    // Origin field
                    InkWell(
                      onTap: () => _openLocationPicker(
                        context: context,
                        title: 'Select Departure Point (Anywhere)',
                        controller: _originController,
                        onSelected: (loc) => _originLocation = loc,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FBFB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2EFF1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF006D77),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'FROM (ORIGIN)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.6,
                                      color: Color(0xFF006D77),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _originController.text,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 36), // spacing for swap button
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Destination field
                    InkWell(
                      onTap: () => _openLocationPicker(
                        context: context,
                        title: 'Select Destination (Anywhere)',
                        controller: _destinationController,
                        onSelected: (loc) => _destinationLocation = loc,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FBFB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2EFF1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE29578),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TO (DESTINATION)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.6,
                                      color: Color(0xFFE29578),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _destinationController.text,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 36),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Swap Button
                Positioned(
                  right: 8,
                  child: InkWell(
                    onTap: _swapLocations,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.swap_vert_rounded,
                        color: Color(0xFF006D77),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Distance and Route Overview Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF006D77), Color(0xFF83C5BE)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.linear_scale_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Distance: ${distanceKm.toStringAsFixed(0)} km',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      ' (${distanceMiles.toStringAsFixed(0)} mi)',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _isResolvingRoute ? 'Finding modes' : '${_transportOptions.length} Modes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Header for Transport Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Possible Transport Modes',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Estimated • recommended first',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_isResolvingRoute)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_routeError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(14)),
              child: Text(_routeError!, style: const TextStyle(color: Color(0xFF8A4B08))),
            )
          else
            ..._transportOptions.map((opt) => _buildTransportOptionCard(opt)),

          const SizedBox(height: 20),

          // Plan Full Itinerary with this Route Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006D77),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
              ),
              icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              label: Text(
                'Plan Full Itinerary for ${_destinationController.text}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onPressed: () {
                final matchedDest = widget.travelService.destinations.firstWhere(
                  (d) => d.name.toLowerCase() == _destinationController.text.trim().toLowerCase(),
                  orElse: () => widget.travelService.destinations.first,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlannerScreen(
                      travelService: widget.travelService,
                      preSelectedDestination: matchedDest,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildTransportOptionCard(TransportOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: option.isRecommended ? option.themeColor : AppColors.border,
          width: option.isRecommended ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: option.isRecommended
                ? option.themeColor.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner for Best Mode Recommendation
          if (option.isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: option.themeColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'BEST MODE FOR THIS DISTANCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: option.themeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Icon(option.icon, color: option.themeColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                option.title,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (option.badge != null && !option.isRecommended)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: option.themeColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    option.badge!,
                                    style: TextStyle(
                                      color: option.themeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            option.subtitle,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Metrics row: Duration, Cost, Carbon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricCol(
                        icon: Icons.access_time_rounded,
                        label: 'Duration',
                        value: option.durationText,
                        color: const Color(0xFF006D77),
                      ),
                      Container(width: 1, height: 26, color: Colors.grey.shade300),
                      _metricCol(
                        icon: Icons.payments_outlined,
                        label: 'Est. Fare',
                        value: option.costRangeText,
                        color: const Color(0xFFE29578),
                      ),
                      Container(width: 1, height: 26, color: Colors.grey.shade300),
                      _metricCol(
                        icon: Icons.eco_outlined,
                        label: 'Carbon',
                        value: '${option.co2Kg.round()} kg CO₂',
                        color: const Color(0xFF2A9D8F),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Recommendation rationale
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      option.isRecommended ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                      size: 15,
                      color: option.isRecommended ? option.themeColor : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        option.recommendationReason,
                        style: TextStyle(
                          fontSize: 12,
                          color: option.isRecommended ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: option.isRecommended ? FontWeight.w600 : FontWeight.normal,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCol({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // TAB 2: EXISTING BROWSE DESTINATIONS GRID
  Widget _buildBrowseDestinationsTab() {
    final query = _destinationSearchController.text.trim().toLowerCase();
    final results = widget.travelService.destinations.where((d) {
      final matchesRegion = _selectedRegion == 'All' || d.region == _selectedRegion;
      final matchesQuery = query.isEmpty ||
          d.name.toLowerCase().contains(query) ||
          d.country.toLowerCase().contains(query) ||
          d.tags.any((t) => t.toLowerCase().contains(query));
      return matchesRegion && matchesQuery;
    }).toList();

    return Column(
      children: [
        // Search Input Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _destinationSearchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search city, country, or tag (e.g. Kyoto, Beach)...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _destinationSearchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _destinationSearchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),
        ),

        // Region Chips
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _regions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final region = _regions[idx];
              final isSelected = _selectedRegion == region;
              return ChoiceChip(
                label: Text(region),
                selected: isSelected,
                selectedColor: const Color(0xFF006D77),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedRegion = region);
                  }
                },
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Found ${results.length} destinations',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Grid Results
        Expanded(
          child: results.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🔍', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text(
                        'No destinations found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Try searching for another keyword or region',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, idx) {
                    final dest = results[idx];
                    return DestinationGridCard(
                      destination: dest,
                      isFavorite: widget.travelService.isFavorite(dest.id),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DestinationDetailScreen(
                              destination: dest,
                              travelService: widget.travelService,
                            ),
                          ),
                        );
                      },
                      onFavoriteToggle: () {
                        setState(() {
                          widget.travelService.toggleFavorite(dest.id);
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

