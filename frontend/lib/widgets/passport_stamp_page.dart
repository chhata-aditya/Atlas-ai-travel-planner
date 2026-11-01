import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class PassportStampPage extends StatelessWidget {
  final int pageNumber;
  final List<PassportStamp> stamps;
  final VoidCallback onAddStamp;

  const PassportStampPage({
    super.key,
    required this.pageNumber,
    required this.stamps,
    required this.onAddStamp,
  });

  void _showStampDetail(BuildContext context, PassportStamp stamp) {
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
                  Row(
                    children: [
                      Text(stamp.emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stamp.destination,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            stamp.country,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.softTealBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stampMeta('Visited', stamp.dateVisited),
                    _stampMeta('Immigration', 'Approved'),
                    _stampMeta('Port', stamp.airportCode),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Digital Passport Stamp Verified',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'This stamp is authenticated by Atlas Global Journey Companion and permanently etched into your traveler passport.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.3),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _stampMeta(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTeal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7EE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCD4C0), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Guilloché security pattern lines
            Positioned.fill(
              child: CustomPaint(
                painter: _PassportSecurityPatternPainter(),
              ),
            ),

            // Top Header: VISAS & PAGE NUMBER
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'VISAS',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Color(0xFF5A4D41),
                        ),
                      ),
                      Text(
                        'PAGE 0$pageNumber',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0xFF8C7E72),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFD4C8B5), thickness: 1),
                ],
              ),
            ),

            // Stamps Grid Layout
            Positioned.fill(
              top: 50,
              bottom: 45,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: stamps.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.flight_takeoff_rounded, size: 40, color: Color(0xFF6B5850)),
                            const SizedBox(height: 10),
                            const Text(
                              'No stamps on this page yet',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B5850),
                              ),
                            ),
                            const SizedBox(height: 6),
                            ElevatedButton.icon(
                              onPressed: onAddStamp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryTeal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.add_location_alt_rounded, size: 16),
                              label: const Text('Add Country Stamp', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.15,
                        ),
                        itemCount: stamps.length,
                        itemBuilder: (ctx, index) {
                          final stamp = stamps[index];
                          return _buildRealisticStamp(context, stamp, index);
                        },
                      ),
              ),
            ),

            // Bottom Add Stamp Quick Pill
            Positioned(
              bottom: 10,
              left: 18,
              right: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '★ ATLAS OFFICIAL VISAS ★',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Color(0xFF9E9185),
                    ),
                  ),
                  GestureDetector(
                    onTap: onAddStamp,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006D77).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF006D77).withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 12, color: Color(0xFF006D77)),
                          SizedBox(width: 2),
                          Text(
                            'Stamp',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006D77),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealisticStamp(BuildContext context, PassportStamp stamp, int index) {
    final angles = [-0.08, 0.06, -0.04, 0.09];
    final angle = angles[index % angles.length];
    final color = _parseColor(stamp.stampColorHex);

    return GestureDetector(
      onTap: () => _showStampDetail(context, stamp),
      child: Transform.rotate(
        angle: angle,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: color.withValues(alpha: 0.75),
              width: 2,
              strokeAlign: BorderSide.strokeAlignCenter,
            ),
            borderRadius: BorderRadius.circular(index.isEven ? 14 : 24),
            color: Colors.white.withValues(alpha: 0.25),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'IMMIGRATION',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 6.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: color,
                    ),
                  ),
                  Text(
                    stamp.airportCode,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(stamp.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      stamp.country.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '★ ${stamp.dateVisited.toUpperCase()} ★',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'ENTRY PERMITTED • 90 DAYS',
                style: TextStyle(
                  fontSize: 5.5,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFFBA135D);
    }
  }
}

class _PassportSecurityPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = const Color(0xFF8B7355).withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Guilloché wavy background lines
    for (double i = 20; i < size.height; i += 24) {
      final path = Path()..moveTo(0, i);
      for (double x = 0; x < size.width; x += 30) {
        path.quadraticBezierTo(
          x + 15,
          i + 8 * math.sin(x / 20),
          x + 30,
          i,
        );
      }
      canvas.drawPath(path, wavePaint);
    }

    // Faint Atlas globe watermark in the center
    final watermarkPaint = Paint()
      ..color = const Color(0xFF8B7355).withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 65, watermarkPaint);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: 130, height: 50),
      watermarkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
