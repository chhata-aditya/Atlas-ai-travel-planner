import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_api_service.dart';
import '../services/travel_service.dart';
import '../theme/app_theme.dart';
import '../screens/auth_screen.dart';
import '../screens/planner_screen.dart';
import '../screens/safety_screen.dart';

class AtlasAppDrawer extends StatelessWidget {
  final TravelService travelService;
  final Function(int)? onNavigateTab;

  const AtlasAppDrawer({
    super.key,
    required this.travelService,
    this.onNavigateTab,
  });

  void _showCurrencySelector(BuildContext context) {
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
              const Text(
                'Select Display Currency',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _currencyTile(ctx, 'USD - US Dollar', '\$', true),
              _currencyTile(ctx, 'EUR - Euro', '€', false),
              _currencyTile(ctx, 'GBP - British Pound', '£', false),
              _currencyTile(ctx, 'JPY - Japanese Yen', '¥', false),
            ],
          ),
        );
      },
    );
  }

  Widget _currencyTile(BuildContext ctx, String label, String symbol, bool isSelected) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected ? AppColors.softTealBg : AppColors.background,
        child: Text(
          symbol,
          style: TextStyle(
            color: isSelected ? AppColors.primaryTeal : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.primaryTeal : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryTeal)
          : null,
      onTap: () {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('Currency updated to $label'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _showEmergencySheet(BuildContext context) {
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.alertLightBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sos_rounded, color: AppColors.alertCoral, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '24/7 Travel Concierge & SOS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Atlas live safety monitoring is connected. Our global 24/7 rapid assistance team and local embassy hotline are ready.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connecting to Atlas Global Emergency Dispatch...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alertCoral,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.white),
                  label: const Text(
                    'Call Emergency Hotline',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = travelService.userProfile;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Drawer Header with Profile & Gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF08495A),
                  Color(0xFF006D77),
                  Color(0xFF83C5BE),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar & Close Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          profile.avatarUrl,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Text(
                  profile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  profile.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12.5,
                  ),
                ),

                const SizedBox(height: 14),

                // Quick 3-Stat Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _headerStat('${profile.countriesVisited}', 'Countries'),
                      _statDivider(),
                      _headerStat('${profile.totalTrips}', 'Trips'),
                      _statDivider(),
                      _headerStat('${(profile.milesTraveled / 1000).toStringAsFixed(1)}k', 'Miles'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Drawer Navigation List Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              children: [
                _drawerItem(
                  icon: Icons.explore_rounded,
                  label: 'Explore & Discover',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigateTab?.call(0);
                  },
                ),
                _drawerItem(
                  icon: Icons.work_rounded,
                  label: 'My Bookings & Itineraries',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigateTab?.call(1);
                  },
                ),
                _drawerItem(
                  icon: Icons.favorite_rounded,
                  label: 'Saved Places & Wishlist',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigateTab?.call(2);
                  },
                ),
                _drawerItem(
                  icon: Icons.security_rounded,
                  label: 'Safety & Live Companion',
                  badge: 'LIVE',
                  badgeColor: AppColors.alertCoral,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SafetyScreen(travelService: travelService),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.local_offer_rounded,
                  label: 'AI Top Picks & Deals',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigateTab?.call(3);
                  },
                ),
                _drawerItem(
                  icon: Icons.person_rounded,
                  label: 'Travel Passport & Profile',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigateTab?.call(4);
                  },
                ),
                _drawerItem(
                  icon: Icons.auto_awesome,
                  label: 'AI Trip Builder',
                  iconColor: const Color(0xFF00798C),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlannerScreen(travelService: travelService),
                      ),
                    );
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Divider(color: AppColors.divider),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'PREFERENCES & TOOLS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                _drawerItem(
                  icon: Icons.currency_exchange_rounded,
                  label: 'Currency (USD \$)',
                  onTap: () => _showCurrencySelector(context),
                ),
                _drawerItem(
                  icon: Icons.sos_rounded,
                  label: '24/7 AI Concierge & SOS',
                  iconColor: AppColors.alertCoral,
                  onTap: () => _showEmergencySheet(context),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Divider(color: AppColors.divider),
                ),

                _drawerItem(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out / Switch Account',
                  iconColor: AppColors.alertCoral,
                  onTap: () async {
                    Navigator.pop(context);
                    await AuthApiService().logout();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('is_logged_in', false);
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthScreen(initialIsLogin: true)),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Drawer Footer with App Version
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.explore_rounded, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  'Atlas AI Travel v1.2.0',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 20,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    String? badge,
    Color? badgeColor,
  }) {
    return ListTile(
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Icon(
        icon,
        color: iconColor ?? const Color(0xFF006D77),
        size: 22,
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.primaryTeal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
