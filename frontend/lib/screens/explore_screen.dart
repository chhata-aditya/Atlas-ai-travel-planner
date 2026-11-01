import 'package:flutter/material.dart';
import '../services/travel_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/category_buttons_bar.dart';
import '../widgets/destination_card.dart';
import '../widgets/summer_getaway_banner.dart';
import 'destination_detail_screen.dart';
import 'search_screen.dart';

class ExploreScreen extends StatelessWidget {
  final TravelService travelService;
  final Function(int)? onNavigateTab;

  const ExploreScreen({
    super.key,
    required this.travelService,
    this.onNavigateTab,
  });

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notifications_active_rounded, color: AppColors.primaryTeal, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
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
              const SizedBox(height: 12),
              _notificationTile(
                icon: Icons.flight_takeoff_rounded,
                iconBg: AppColors.softTealBg,
                iconColor: AppColors.primaryTeal,
                title: 'Flight Check-in Open',
                subtitle: 'Flight SQ-942 to Bali is open for online seat selection.',
                time: '10m ago',
              ),
              const SizedBox(height: 10),
              _notificationTile(
                icon: Icons.wb_sunny_rounded,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                title: 'Kyoto Weather Update',
                subtitle: 'Sunny skies expected at Kiyomizu-dera (22°C). Ideal for walking.',
                time: '2h ago',
              ),
              const SizedBox(height: 10),
              _notificationTile(
                icon: Icons.shield_rounded,
                iconBg: AppColors.alertLightBg,
                iconColor: AppColors.alertCoral,
                title: 'Atlas Live Sync Active',
                subtitle: 'Safety companion is connected and tracking itinerary in real-time.',
                time: '5h ago',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _notificationTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
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
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final destinations = travelService.destinations;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AtlasAppDrawer(
        travelService: travelService,
        onNavigateTab: onNavigateTab,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Top Section with Background Image
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Background image container
                SizedBox(
                  height: 340,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.heroGradient,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.85),
                              Colors.white.withValues(alpha: 0.6),
                              Colors.white.withValues(alpha: 0.95),
                              AppColors.background,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.4, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Top App Bar & Titles
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar with Hamburger Menu & Notification Bell
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Builder(
                              builder: (scaffoldContext) {
                                return IconButton(
                                  onPressed: () {
                                    Scaffold.of(scaffoldContext).openDrawer();
                                  },
                                  icon: const Icon(
                                    Icons.menu_rounded,
                                    color: Color(0xFF006D77),
                                    size: 26,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                );
                              },
                            ),
                            Stack(
                              children: [
                                IconButton(
                                  onPressed: () => _showNotificationsSheet(context),
                                  icon: const Icon(
                                    Icons.notifications_rounded,
                                    color: Color(0xFF006D77),
                                    size: 26,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.alertCoral,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Subtitle Tag
                        const Text(
                          'Explore the world',
                          style: TextStyle(
                            color: Color(0xFF00798C),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Big Bold Title
                        const Text(
                          'Discover.\nTravel.\nRemember.',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF08495A),
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'Unforgettable journeys, crafted\njust for you.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.textSecondary.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating Search Bar positioned overlapping header bottom
                Positioned(
                  bottom: -24,
                  left: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchScreen(travelService: travelService),
                        ),
                      );
                    },
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Color(0xFF7A8B94),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Search destinations, tours...',
                              style: TextStyle(
                                color: Color(0xFF9EACB4),
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFF006D77),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // 4 Category Quick Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CategoryButtonsBar(
                onCategoryTap: (cat) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchScreen(travelService: travelService),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // Section: Popular Destinations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Destinations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2D35),
                      letterSpacing: -0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchScreen(travelService: travelService),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF006D77),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Color(0xFF006D77),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Horizontal Carousel of Popular Destinations
            SizedBox(
              height: 245,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final dest = destinations[index];
                  return PopularDestinationCard(
                    destination: dest,
                    isFavorite: travelService.isFavorite(dest.id),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DestinationDetailScreen(
                            destination: dest,
                            travelService: travelService,
                          ),
                        ),
                      );
                    },
                    onFavoriteToggle: () => travelService.toggleFavorite(dest.id),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Summer Getaway Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SummerGetawayBanner(
                onBookNow: () => onNavigateTab?.call(1),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
