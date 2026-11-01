import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import '../models/trip.dart';
import '../services/travel_service.dart';
import '../theme/app_theme.dart';

Color _parseHexColor(String hexString) {
  try {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (_) {
    return AppColors.primary;
  }
}

class ItineraryDetailScreen extends StatefulWidget {
  final Trip trip;
  final TravelService travelService;

  const ItineraryDetailScreen({
    super.key,
    required this.trip,
    required this.travelService,
  });

  @override
  State<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends State<ItineraryDetailScreen> {
  int _selectedDayIndex = 0;
  int _activeTab = 0; // 0 = Itinerary, 1 = Packing List, 2 = Budget Tracker

  final TextEditingController _packingItemController = TextEditingController();
  String _newPackingCategory = 'Essentials';

  @override
  void dispose() {
    _packingItemController.dispose();
    super.dispose();
  }

  void _showAddPackingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Packing Item',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _packingItemController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. Universal power adapter',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: ['Essentials', 'Clothing', 'Tech', 'Gear', 'Meds'].map((cat) {
                  final isSel = _newPackingCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSel,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _newPackingCategory = cat);
                        Navigator.pop(ctx);
                        _showAddPackingDialog();
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_packingItemController.text.trim().isNotEmpty) {
                      widget.travelService.addPackingItem(
                        widget.trip.id,
                        _packingItemController.text.trim(),
                        _newPackingCategory,
                      );
                      _packingItemController.clear();
                      Navigator.pop(ctx);
                      setState(() {});
                    }
                  },
                  child: const Text('Add to List'),
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
    final trip = widget.trip;
    final c1 = trip.gradientColorsHex.isNotEmpty
        ? _parseHexColor(trip.gradientColorsHex[0])
        : AppColors.primary;
    final c2 = trip.gradientColorsHex.length > 1
        ? _parseHexColor(trip.gradientColorsHex[1])
        : AppColors.accent;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          trip.destinationName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Itinerary link for ${trip.title} copied!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c1, c2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: c1.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      trip.destinationEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${trip.durationInDays} Days Trip',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  trip.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${trip.destinationCountry} • ${trip.travelStyle}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          // Main Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _tabPill(0, 'Itinerary', Icons.map_outlined),
                const SizedBox(width: 8),
                _tabPill(1, 'Packing (${trip.packingList.length})', Icons.backpack_outlined),
                const SizedBox(width: 8),
                _tabPill(2, 'Budget', Icons.account_balance_wallet_outlined),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: _buildActiveTabContent(trip),
          ),
        ],
      ),
    );
  }

  Widget _tabPill(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(Trip trip) {
    if (_activeTab == 0) {
      return _buildItineraryView(trip);
    } else if (_activeTab == 1) {
      return _buildPackingView(trip);
    } else {
      return _buildBudgetView(trip);
    }
  }

  Widget _buildItineraryView(Trip trip) {
    if (trip.days.isEmpty) {
      return const Center(child: Text('No itinerary days generated yet.'));
    }

    final currentDayIndex =
        _selectedDayIndex.clamp(0, trip.days.length - 1);
    final currentDay = trip.days[currentDayIndex];

    return Column(
      children: [
        // Day selector horizontal list
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: trip.days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final isDaySelected = idx == _selectedDayIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = idx),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDaySelected ? AppColors.primaryDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDaySelected ? AppColors.primaryDark : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Day ${idx + 1}',
                      style: TextStyle(
                        color: isDaySelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isDaySelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Day Title & Theme Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  currentDay.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${currentDay.activities.where((a) => a.isCompleted).length}/${currentDay.activities.length} done',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Timeline of Activities
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: currentDay.activities.length,
            itemBuilder: (context, actIdx) {
              final act = currentDay.activities[actIdx];
              return _buildActivityCard(trip, currentDay, act);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(Trip trip, ItineraryDay day, ActivityItem act) {
    IconData getCategoryIcon(ActivityCategory cat) {
      switch (cat) {
        case ActivityCategory.sightseeing:
          return Icons.photo_camera_outlined;
        case ActivityCategory.food:
          return Icons.restaurant_outlined;
        case ActivityCategory.adventure:
          return Icons.directions_run_outlined;
        case ActivityCategory.relaxation:
          return Icons.spa_outlined;
        case ActivityCategory.culture:
          return Icons.account_balance_outlined;
        case ActivityCategory.transport:
          return Icons.flight_takeoff_outlined;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: act.isCompleted ? AppColors.accentMint.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: () {
            setState(() {
              widget.travelService.toggleActivityComplete(
                trip.id,
                day.dayNumber,
                act.id,
              );
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: act.isCompleted ? AppColors.accentMint : AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: act.isCompleted ? AppColors.accentMint : AppColors.border,
                width: 1.5,
              ),
            ),
            child: act.isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Icon(
                    getCategoryIcon(act.category),
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                act.time,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                act.title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: act.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                  decoration: act.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                act.description,
                style: TextStyle(
                  fontSize: 13,
                  color: act.isCompleted ? AppColors.textMuted : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    act.location,
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const Spacer(),
                  const Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    act.duration,
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackingView(Trip trip) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${trip.packingList.where((p) => p.isPacked).length} of ${trip.packingList.length} packed',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddPackingDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: trip.packingList.length,
            itemBuilder: (context, idx) {
              final item = trip.packingList[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: CheckboxListTile(
                  value: item.isPacked,
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: item.isPacked ? TextDecoration.lineThrough : null,
                      color: item.isPacked ? AppColors.textMuted : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    item.category,
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      widget.travelService.togglePackingItem(trip.id, item.id);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetView(Trip trip) {
    final remaining = (trip.totalBudget - trip.spentAmount).clamp(0, trip.totalBudget);
    final spentRatio = trip.totalBudget > 0 ? (trip.spentAmount / trip.totalBudget).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Budget', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text('\$${trip.totalBudget.toInt()}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Remaining', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text('\$${remaining.toInt()}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accentMint)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: spentRatio,
                    minHeight: 10,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${trip.spentAmount.toInt()} spent (${(spentRatio * 100).toInt()}%)',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Estimated Expense Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _expenseRow('🏨 Accommodation', (trip.totalBudget * 0.45).toInt()),
          _expenseRow('🍽️ Food & Dining', (trip.totalBudget * 0.25).toInt()),
          _expenseRow('🎟️ Activities & Tours', (trip.totalBudget * 0.18).toInt()),
          _expenseRow('🚕 Local Transport', (trip.totalBudget * 0.12).toInt()),
        ],
      ),
    );
  }

  Widget _expenseRow(String label, int amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          Text('\$$amount', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }
}
