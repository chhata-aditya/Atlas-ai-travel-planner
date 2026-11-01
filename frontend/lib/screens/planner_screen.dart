import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/travel_service.dart';
import '../theme/app_theme.dart';
import 'itinerary_detail_screen.dart';

class PlannerScreen extends StatefulWidget {
  final TravelService travelService;
  final Destination? preSelectedDestination;

  const PlannerScreen({
    super.key,
    required this.travelService,
    this.preSelectedDestination,
  });

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late Destination _selectedDestination;
  DateTime _startDate = DateTime.now().add(const Duration(days: 10));
  int _daysCount = 5;
  int _travelersCount = 2;
  double _budget = 2000;
  String _selectedStyle = 'Cultural Explorer';
  final Set<String> _selectedVibes = {'Culture ⛩️', 'Foodie 🍜', 'Scenic 📸'};
  bool _isGenerating = false;

  final List<String> _travelStyles = [
    'Cultural Explorer',
    'Relaxation & Spa',
    'Adventure & Nature',
    'Foodie & Dining',
    'Budget Backpacking',
    'Luxury Getaway',
  ];

  final List<String> _allVibes = [
    'Culture',
    'Foodie',
    'Scenic',
    'Beach',
    'Nightlife',
    'Hiking',
    'Shopping',
    'Wellness',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDestination = widget.preSelectedDestination ??
        widget.travelService.destinations.first;
  }

  Future<void> _handleGenerate() async {
    setState(() => _isGenerating = true);

    // Simulate AI inference & synthesis
    await Future.delayed(const Duration(milliseconds: 1600));

    if (!mounted) return;

    final newTrip = widget.travelService.generateAITrip(
      destination: _selectedDestination,
      startDate: _startDate,
      daysCount: _daysCount,
      travelStyle: _selectedStyle,
      budget: _budget,
      travelersCount: _travelersCount,
      vibeTags: _selectedVibes.toList(),
    );

    setState(() => _isGenerating = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ItineraryDetailScreen(
          trip: newTrip,
          travelService: widget.travelService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Trip Planner', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: widget.preSelectedDestination != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Prompt Header Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Atlas Intelligent Co-Pilot',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Crafting your custom itinerary with optimal routes, budget and activities.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Step 1: Destination
            const Text(
              '1. Where would you like to go?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Destination>(
                  value: _selectedDestination,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: widget.travelService.destinations.map((dest) {
                    return DropdownMenuItem<Destination>(
                      value: dest,
                      child: Row(
                        children: [
                          Text(dest.emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Text(
                            '${dest.name}, ${dest.country}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (dest) {
                    if (dest != null) {
                      setState(() => _selectedDestination = dest);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Step 2: Dates & Duration
            const Text(
              '2. Duration & Start Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Trip Duration',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (_daysCount > 1) {
                                  setState(() => _daysCount--);
                                }
                              },
                            ),
                            Text(
                              '$_daysCount Days',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                if (_daysCount < 14) {
                                  setState(() => _daysCount++);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _startDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Departure Date',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Step 3: Budget Slider & Travelers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '3. Total Trip Budget',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_budget.toInt()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Slider(
              value: _budget,
              min: 500,
              max: 8000,
              divisions: 15,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _budget = val),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.group_outlined, size: 20, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Travelers Count',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        onPressed: () {
                          if (_travelersCount > 1) {
                            setState(() => _travelersCount--);
                          }
                        },
                      ),
                      Text(
                        '$_travelersCount ${_travelersCount > 1 ? "people" : "person"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        onPressed: () {
                          if (_travelersCount < 8) {
                            setState(() => _travelersCount++);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Step 4: Travel Style
            const Text(
              '4. Travel Style',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _travelStyles.map((style) {
                final isSelected = _selectedStyle == style;
                return ChoiceChip(
                  label: Text(style),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedStyle = style);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Step 5: Vibes & Interests
            const Text(
              '5. Experiences & Vibes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allVibes.map((vibe) {
                final isSelected = _selectedVibes.contains(vibe);
                return FilterChip(
                  label: Text(vibe),
                  selected: isSelected,
                  selectedColor: AppColors.accent.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedVibes.add(vibe);
                      } else {
                        _selectedVibes.remove(vibe);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _handleGenerate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Synthesizing AI Itinerary...',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Generate AI Itinerary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
