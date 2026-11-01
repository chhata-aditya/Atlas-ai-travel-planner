import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class TravelLicenseCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;
  final VoidCallback onChangePhoto;

  const TravelLicenseCard({
    super.key,
    required this.profile,
    required this.onEdit,
    required this.onChangePhoto,
  });

  Color _getCardBgColor(String colorKey) {
    switch (colorKey.toLowerCase()) {
      case 'blue':
        return const Color(0xFFC7E5F6);
      case 'mint':
        return const Color(0xFFC5EFE3);
      case 'pink':
        return const Color(0xFFFFD9E2);
      case 'yellow':
      default:
        return const Color(0xFFF7EAB7);
    }
  }

  Color _getCardBorderColor(String colorKey) {
    switch (colorKey.toLowerCase()) {
      case 'blue':
        return const Color(0xFF90C2DE);
      case 'mint':
        return const Color(0xFF8FD6C4);
      case 'pink':
        return const Color(0xFFF2AEC0);
      case 'yellow':
      default:
        return const Color(0xFFE5CE85);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getCardBgColor(profile.cardColor);
    final borderColor = _getCardBorderColor(profile.cardColor);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          children: [
            // Aged paper texture overlay
            Positioned.fill(
              child: CustomPaint(
                painter: _AgedPaperPainter(),
              ),
            ),

            // Watermark stamp across card: "CALL ME IF YOU GET LOST" / "ATLAS TRAVELER"
            Positioned(
              right: 16,
              bottom: 45,
              child: Transform.rotate(
                angle: -0.15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00798C).withValues(alpha: 0.35),
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'CALL ME IF YOU GET LOST',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF00798C).withValues(alpha: 0.4),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Star border perimeter and Card Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF3B2F2F).withValues(alpha: 0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    // Top row of black stars
                    _buildStarRow(count: 15),

                    const SizedBox(height: 6),

                    // Middle content with Left Photo and Right License Data
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Photograph of Authorized Traveler
                        _buildPhotoSection(),

                        const SizedBox(width: 12),

                        // Right: License information & signature
                        Expanded(
                          child: _buildDetailsSection(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Bottom row of black stars
                    _buildStarRow(count: 15),
                  ],
                ),
              ),
            ),

            // Top right edit button
            Positioned(
              top: 14,
              right: 14,
              child: GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: Color(0xFF2C221E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onChangePhoto,
          child: Stack(
            children: [
              Container(
                width: 110,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    profile.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF006D77),
                      child: Center(
                        child: Text(
                          profile.avatarUrl,
                          style: const TextStyle(fontSize: 44),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Camera icon badge
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006D77),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Photograph of Authorized traveler',
          style: TextStyle(
            fontSize: 6.5,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A3E39),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title: PERMANENT LICENSE OF TRAVEL
        const Center(
          child: Text(
            'PERMANENT LICENSE OF TRAVEL',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: Color(0xFF2C221E),
            ),
          ),
        ),

        // License Number
        Center(
          child: Text(
            'NO. ${profile.licenseNumber}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: Color(0xFF1E1714),
            ),
          ),
        ),

        const SizedBox(height: 4),

        // Dotted Fields
        _buildDottedLine('Issued to', profile.name),
        _buildDottedLine('Date of birth', profile.dateOfBirth),
        _buildDottedLine('Place of issue', profile.placeOfIssue),
        _buildDottedLine('Date of issue', profile.dateOfIssue),

        const SizedBox(height: 4),

        // LICENSE OF TRAVEL statement
        const Center(
          child: Text(
            'LICENSE OF TRAVEL',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: Color(0xFF2C221E),
            ),
          ),
        ),

        const SizedBox(height: 1),

        const Text(
          'This is to Certify that the person named and described above is permitted to travel and explore freely unless detained by law.',
          style: TextStyle(
            fontSize: 6.5,
            height: 1.15,
            color: Color(0xFF4A3E39),
          ),
        ),

        const SizedBox(height: 3),

        // Signature Line
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IMPORTANT',
                  style: TextStyle(
                    fontSize: 6.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2C221E),
                  ),
                ),
                Text(
                  'Atlas Official Passport',
                  style: TextStyle(fontSize: 6, color: Color(0xFF6B5850)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  profile.effectiveSignature,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  width: 90,
                  height: 1,
                  color: const Color(0xFF3B2F2F),
                ),
                const Text(
                  'Signature of Authorized traveler',
                  style: TextStyle(
                    fontSize: 5.5,
                    color: Color(0xFF4A3E39),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDottedLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A3E39),
            ),
          ),
          Expanded(
            child: Text(
              '.........................................................................',
              overflow: TextOverflow.clip,
              maxLines: 1,
              style: TextStyle(
                fontSize: 8,
                color: const Color(0xFF7A6B65).withValues(alpha: 0.6),
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E1714),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRow({required int count}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        count,
        (index) => const Text(
          '★',
          style: TextStyle(
            fontSize: 9,
            color: Color(0xFF2C221E),
          ),
        ),
      ),
    );
  }
}

class _AgedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B6B38).withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    // Subtle grunge marks
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 30, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 45, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.85), 25, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
