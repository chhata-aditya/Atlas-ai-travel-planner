import 'package:flutter/material.dart';
import '../services/travel_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_plan_banner.dart';
import '../widgets/category_chip.dart';
import '../widgets/destination_card.dart';
import 'destination_detail_screen.dart';
import 'planner_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  final TravelService travelService;
  final VoidCallback onOpenPlanner;

  const HomeScreen({
    super.key,
    required this.travelService,
    required this.onOpenPlanner,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final service = widget.travelService;
    final featured = service.destinations.where((d) => d.isFeatured).toList();
    final filtered = service.filteredDestinations;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Greeting
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Hello, Explorer',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.userProfile.avatarUrl,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Where to next? ✈️',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search, color: AppColors.textPrimary),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchScreen(travelService: service),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Search Trigger Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchScreen(travelService: service),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: AppColors.textMuted, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Explore Tokyo, Paris, Amalfi, Swiss Alps...',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // AI Plan Hero Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AiPlanBanner(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlannerScreen(travelService: service),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 26),

              // Category Filter Bar
              CategoryChipBar(
                categories: const [
                  'All',
                  'Trending 🔥',
                  'Tropical 🌴',
                  'Cultural ⛩️',
                  'Mountain 🏔️',
                  'Romantic 💖',
                  'Adventure 🧗',
                ],
                selectedCategory: service.selectedCategory,
                onSelected: (cat) => service.setCategory(cat),
              ),

              const SizedBox(height: 24),

              // Section: Featured Destinations
              if (service.selectedCategory == 'All') ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Featured Journeys',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '${featured.length} curated',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: featured.length,
                    itemBuilder: (context, index) {
                      final dest = featured[index];
                      return FeaturedDestinationCard(
                        destination: dest,
                        isFavorite: service.isFavorite(dest.id),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DestinationDetailScreen(
                                destination: dest,
                                travelService: service,
                              ),
                            ),
                          );
                        },
                        onFavoriteToggle: () => service.toggleFavorite(dest.id),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 26),
              ],

              // Section: Explore / All Destinations
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service.selectedCategory == 'All'
                          ? 'Popular Destinations'
                          : service.selectedCategory,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '${filtered.length} places',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Destination Cards Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final dest = filtered[index];
                    return DestinationGridCard(
                      destination: dest,
                      isFavorite: service.isFavorite(dest.id),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DestinationDetailScreen(
                              destination: dest,
                              travelService: service,
                            ),
                          ),
                        );
                      },
                      onFavoriteToggle: () => service.toggleFavorite(dest.id),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Travel Inspiration / Daily Wisdom Quote Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 TRAVEL WISDOM',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '"The world is a book and those who do not travel read only one page."',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '— Saint Augustine',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
