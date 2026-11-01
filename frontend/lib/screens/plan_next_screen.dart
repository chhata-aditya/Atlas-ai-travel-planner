import 'package:flutter/material.dart';
import '../services/travel_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/category_buttons_bar.dart';
import '../widgets/destination_card.dart';
import '../widgets/summer_getaway_banner.dart';
import 'destination_detail_screen.dart';
import 'planner_screen.dart';
import 'search_screen.dart';

class PlanNextScreen extends StatelessWidget {
  final TravelService travelService;
  final Function(int)? onNavigateTab;

  const PlanNextScreen({
    super.key,
    required this.travelService,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final maldives = travelService.destinations.firstWhere(
      (d) => d.id == 'dest_maldives',
      orElse: () => travelService.destinations.first,
    );

    final switzerland = travelService.destinations.firstWhere(
      (d) => d.id == 'dest_switzerland',
      orElse: () => travelService.destinations.last,
    );

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
            // Top Section with Soft Cyan/Sky Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFD4EFF2),
                    Color(0xFFE8F6F8),
                    AppColors.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Bar with Menu and Bell
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(
                            builder: (scaffoldContext) {
                              return IconButton(
                                onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
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
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_rounded,
                              color: Color(0xFF006D77),
                              size: 26,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Header Text
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              'Explore the\nworld',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF08495A),
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Discover. Travel.\nRemember.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00798C),
                                height: 1.25,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Unforgettable journeys, crafted just for\nyou.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF6B7C85),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Search Bar with Sparkles Icon
                      GestureDetector(
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
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF006D77),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Where do you want to go?',
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
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 4 Category Quick Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CategoryButtonsBar(
                onCategoryTap: (cat) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlannerScreen(travelService: travelService),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Section: AI Top Picks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEA580C),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'AI TOP PICKS',
                        style: TextStyle(
                          color: Color(0xFFEA580C),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Curated for your next\nadventure',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2D35),
                          height: 1.2,
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
                              'See\nall',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12,
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
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Vertical Cards for AI Top Picks (Maldives & Switzerland)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  AiTopPickCard(
                    destination: maldives,
                    customSubtitle: 'Paradise Found',
                    isFavorite: travelService.isFavorite(maldives.id),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DestinationDetailScreen(
                            destination: maldives,
                            travelService: travelService,
                          ),
                        ),
                      );
                    },
                    onFavoriteToggle: () => travelService.toggleFavorite(maldives.id),
                  ),
                  AiTopPickCard(
                    destination: switzerland,
                    customSubtitle: 'Alpine Beauty',
                    isFavorite: travelService.isFavorite(switzerland.id),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DestinationDetailScreen(
                            destination: switzerland,
                            travelService: travelService,
                          ),
                        ),
                      );
                    },
                    onFavoriteToggle: () => travelService.toggleFavorite(switzerland.id),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

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
