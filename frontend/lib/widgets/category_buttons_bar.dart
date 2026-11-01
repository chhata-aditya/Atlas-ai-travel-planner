import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryButtonsBar extends StatelessWidget {
  final Function(String)? onCategoryTap;

  const CategoryButtonsBar({super.key, this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _categoryItem(
            icon: Icons.flight_rounded,
            label: 'Flights',
            bgColor: AppColors.flightCircleBg,
            iconColor: AppColors.flightIcon,
          ),
          _categoryItem(
            icon: Icons.hotel_rounded,
            label: 'Hotels',
            bgColor: AppColors.hotelCircleBg,
            iconColor: AppColors.hotelIcon,
          ),
          _categoryItem(
            icon: Icons.temple_buddhist_rounded,
            label: 'Tours',
            bgColor: AppColors.tourCircleBg,
            iconColor: AppColors.tourIcon,
          ),
          _categoryItem(
            icon: Icons.local_activity_rounded,
            label: 'Activities',
            bgColor: AppColors.activityCircleBg,
            iconColor: AppColors.activityIcon,
          ),
        ],
      ),
    );
  }

  Widget _categoryItem({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () => onCategoryTap?.call(label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
