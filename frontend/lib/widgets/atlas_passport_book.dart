import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/travel_service.dart';
import '../theme/app_theme.dart';
import 'passport_stamp_page.dart';
import 'travel_license_card.dart';

class AtlasPassportBook extends StatefulWidget {
  final TravelService travelService;

  const AtlasPassportBook({super.key, required this.travelService});

  @override
  State<AtlasPassportBook> createState() => _AtlasPassportBookState();
}

class _AtlasPassportBookState extends State<AtlasPassportBook> {
  final PageController _pageController = PageController(initialPage: 1); // Start on ID Card page
  int _currentPage = 1;

  final List<String> _presetPhotos = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showChangePhotoDialog() {
    final urlController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.camera_alt_rounded, color: AppColors.primaryTeal),
                      SizedBox(width: 8),
                      Text(
                        'Change Passport Photo',
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
              const SizedBox(height: 14),
              const Text(
                'Choose a traveler portrait or paste image link:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              // Preset portraits
              SizedBox(
                height: 75,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presetPhotos.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    final photo = _presetPhotos[idx];
                    return GestureDetector(
                      onTap: () {
                        widget.travelService.updateUserProfile(
                          widget.travelService.userProfile.copyWith(photoUrl: photo),
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Passport photo updated successfully.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        width: 65,
                        height: 75,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.travelService.userProfile.photoUrl == photo
                                ? AppColors.primaryTeal
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            photo,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  hintText: 'Paste custom Image URL...',
                  prefixIcon: const Icon(Icons.link_rounded, color: AppColors.primaryTeal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (urlController.text.trim().isNotEmpty) {
                      widget.travelService.updateUserProfile(
                        widget.travelService.userProfile.copyWith(
                          photoUrl: urlController.text.trim(),
                        ),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Custom passport photo applied.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Apply Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCustomizeCardSheet() {
    final profile = widget.travelService.userProfile;
    final nameCtrl = TextEditingController(text: profile.name);
    final dobCtrl = TextEditingController(text: profile.dateOfBirth);
    final locCtrl = TextEditingController(text: profile.placeOfIssue);
    final sigCtrl = TextEditingController(text: profile.signature);
    String selectedColor = profile.cardColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                            Icon(Icons.badge_rounded, color: AppColors.primaryTeal),
                            SizedBox(width: 8),
                            Text(
                              'Customize Travel License',
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

                    // Card Color selection (Matching user image right-hand side panel!)
                    const Text(
                      'CARD COLOR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _colorPickerItem('yellow', 'YELLOW', const Color(0xFFF7EAB7), selectedColor, () {
                          setSheetState(() => selectedColor = 'yellow');
                        }),
                        const SizedBox(width: 10),
                        _colorPickerItem('blue', 'BLUE', const Color(0xFFC7E5F6), selectedColor, () {
                          setSheetState(() => selectedColor = 'blue');
                        }),
                        const SizedBox(width: 10),
                        _colorPickerItem('mint', 'MINT', const Color(0xFFC5EFE3), selectedColor, () {
                          setSheetState(() => selectedColor = 'mint');
                        }),
                        const SizedBox(width: 10),
                        _colorPickerItem('pink', 'PINK', const Color(0xFFFFD9E2), selectedColor, () {
                          setSheetState(() => selectedColor = 'pink');
                        }),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Name
                    _sheetTextField('NAME', nameCtrl),
                    const SizedBox(height: 10),

                    // Date of birth
                    _sheetTextField('DATE OF BIRTH', dobCtrl),
                    const SizedBox(height: 10),

                    // Location
                    _sheetTextField('LOCATION / PLACE OF ISSUE', locCtrl),
                    const SizedBox(height: 10),

                    // Signature
                    _sheetTextField('HANDWRITTEN SIGNATURE', sigCtrl),

                    const SizedBox(height: 18),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.travelService.updateUserProfile(
                            profile.copyWith(
                              name: nameCtrl.text.trim(),
                              dateOfBirth: dobCtrl.text.trim(),
                              placeOfIssue: locCtrl.text.trim(),
                              signature: sigCtrl.text.trim(),
                              cardColor: selectedColor,
                            ),
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Travel License Card updated.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006D77),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Save Travel License',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _sheetTextField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _colorPickerItem(
    String key,
    String label,
    Color color,
    String selectedKey,
    VoidCallback onTap,
  ) {
    final isSelected = key == selectedKey;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF006D77) : Colors.transparent,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? const Color(0xFF006D77) : const Color(0xFF4A3E39),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddStampDialog() {
    final countryCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final airportCtrl = TextEditingController(text: 'NRT');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.add_location_alt_rounded, color: AppColors.primaryTeal),
                      SizedBox(width: 8),
                      Text(
                        'Stamp Visited Country',
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
              TextField(
                controller: countryCtrl,
                decoration: InputDecoration(
                  labelText: 'Country (e.g. Thailand, Italy, Spain)',
                  prefixIcon: const Icon(Icons.flag_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cityCtrl,
                decoration: InputDecoration(
                  labelText: 'City / Region (e.g. Bangkok, Rome)',
                  prefixIcon: const Icon(Icons.location_city_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: airportCtrl,
                decoration: InputDecoration(
                  labelText: 'Airport / Border Code (e.g. BKK, FCO, CDG)',
                  prefixIcon: const Icon(Icons.local_airport_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (countryCtrl.text.trim().isNotEmpty) {
                      widget.travelService.addPassportStamp(
                        PassportStamp(
                          id: 'stamp_${DateTime.now().millisecondsSinceEpoch}',
                          destination: cityCtrl.text.trim().isNotEmpty
                              ? cityCtrl.text.trim()
                              : countryCtrl.text.trim(),
                          country: countryCtrl.text.trim(),
                          emoji: '🌍',
                          dateVisited: 'Summer 2026',
                          stampColorHex: '#BA135D',
                          airportCode: airportCtrl.text.trim().toUpperCase(),
                        ),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Stamp added for ${countryCtrl.text}.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.approval_rounded, color: Colors.white),
                  label: const Text('Add Stamp to Passport', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final profile = widget.travelService.userProfile;
    final stamps = profile.stamps;

    // Split stamps across pages
    final page1Stamps = stamps.take(4).toList();
    final page2Stamps = stamps.skip(4).toList();

    return Column(
      children: [
        // Book Page Segment Tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _pageTab(0, 'Cover'),
              _pageTab(1, 'ID Card'),
              _pageTab(2, 'Visas 1'),
              _pageTab(3, 'Visas 2'),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Flip-Book Container (Swipeable PageView)
        SizedBox(
          height: 250,
          child: PageView(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            children: [
              // Page 0: Passport Cover
              _buildPassportCover(),

              // Page 1: Travel License Card (Exact matching reference image!)
              TravelLicenseCard(
                profile: profile,
                onEdit: _showCustomizeCardSheet,
                onChangePhoto: _showChangePhotoDialog,
              ),

              // Page 2: Visas Page 1 (Asia & Europe)
              PassportStampPage(
                pageNumber: 2,
                stamps: page1Stamps,
                onAddStamp: _showAddStampDialog,
              ),

              // Page 3: Visas Page 2 (Americas, Islands & Custom)
              PassportStampPage(
                pageNumber: 3,
                stamps: page2Stamps,
                onAddStamp: _showAddStampDialog,
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Bottom Page Indicator & Swipe Hint
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: List.generate(
                4,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF006D77)
                        : const Color(0xFFCAD6DC),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const Text(
              'Swipe to flip passport pages ➔',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pageTab(int index, String label) {
    final isSelected = _currentPage == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF006D77) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPassportCover() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0C2B38),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFC9A24D), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gold foil border
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFC9A24D).withValues(alpha: 0.4),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.public_rounded, size: 48, color: Color(0xFFD4AF37)),
                    const SizedBox(height: 10),
                    const Text(
                      'ATLAS',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFFD4AF37),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'PASSPORT & TRAVEL LICENSE',
                      style: TextStyle(
                        color: Color(0xFFC9A24D),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_rounded, color: Color(0xFFD4AF37), size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Swipe or Tap to Open',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
