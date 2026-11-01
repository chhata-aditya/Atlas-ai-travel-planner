import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_api_service.dart';
import '../services/travel_service.dart';
import '../theme/app_theme.dart';
import '../widgets/atlas_passport_book.dart';
import 'auth_screen.dart';
import 'destination_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final TravelService travelService;

  const ProfileScreen({super.key, required this.travelService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0; // 0: Passport, 1: Wishlist, 2: Preferences

  @override
  Widget build(BuildContext context) {
    final service = widget.travelService;
    final profile = service.userProfile;
    final wishlist = service.favoriteDestinations;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Atlas Traveler Passport', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.primaryTeal),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing your Atlas Digital Passport License...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Interactive 3D/Flip Atlas Passport Booklet
            AtlasPassportBook(travelService: service),

            const SizedBox(height: 24),

            // Tabs Selector
            Row(
              children: [
                _tabPill(0, 'Passport'),
                const SizedBox(width: 8),
                _tabPill(1, 'Wishlist (${wishlist.length})'),
                const SizedBox(width: 8),
                _tabPill(2, 'Preferences'),
              ],
            ),

            const SizedBox(height: 16),

            // Tab Content
            if (_selectedTab == 0) ...[
              _buildPassportDetailsView(profile),
            ] else if (_selectedTab == 1) ...[
              _buildWishlistView(wishlist, service),
            ] else ...[
              _buildPreferencesView(profile),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _tabPill(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryTeal : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primaryTeal : AppColors.border,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPassportDetailsView(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: AppColors.primaryTeal, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Traveler Credentials',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.softTealBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),
          _detailRow('Full Name', profile.name),
          _detailRow('Passport License No.', profile.licenseNumber),
          _detailRow('Date of Birth', profile.dateOfBirth),
          _detailRow('Place of Issue', profile.placeOfIssue),
          _detailRow('Issue Date', profile.dateOfIssue),
          _detailRow('Total Countries Stamped', '${profile.countriesVisited} Countries'),
          _detailRow('Flight Distance', '${(profile.milesTraveled / 1000).toStringAsFixed(1)}k Miles'),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistView(List<dynamic> wishlist, TravelService service) {
    if (wishlist.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.bookmark_border_rounded, size: 42, color: AppColors.primaryTeal),
              SizedBox(height: 12),
              Text(
                'Your wishlist is empty',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Explore destinations and tap the heart icon to save your favorite spots.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: wishlist.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final dest = wishlist[idx];
        return GestureDetector(
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
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.softTealBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(dest.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dest.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        dest.country,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${dest.pricePerNight.toInt()}/night',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: AppColors.alertCoral),
                  onPressed: () => service.toggleFavorite(dest.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreferencesView(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Travel Preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (profile.travelPreferences as List<String>).map((pref) {
              return Chip(
                label: Text(pref),
                backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.08),
                labelStyle: const TextStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 10),
          _prefTile(Icons.currency_exchange, 'Default Currency', 'USD (\$)'),
          _prefTile(Icons.notifications_outlined, 'Trip Reminders', 'Enabled'),
          _prefTile(Icons.wifi_off_outlined, 'Offline Itinerary Sync', 'Auto-download'),
          _prefTile(Icons.auto_awesome, 'AI Intelligence Model', 'Gemini Ultra'),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await AuthApiService().logout();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('is_logged_in', false);
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen(initialIsLogin: true)),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.alertCoral,
                side: const BorderSide(color: Color(0xFFFFD4D4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.alertCoral),
              label: const Text(
                'Switch Account / Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.alertCoral),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prefTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryTeal),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
