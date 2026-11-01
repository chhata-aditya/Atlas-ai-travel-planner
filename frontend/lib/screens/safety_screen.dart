import 'package:flutter/material.dart';
import '../services/travel_service.dart';

class SafetyScreen extends StatefulWidget {
  final TravelService travelService;

  const SafetyScreen({super.key, required this.travelService});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isExploring = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Vector Map Canvas Background
          Positioned.fill(
            child: CustomPaint(
              painter: _TokyoMapPainter(pulseAnimation: _pulseController),
            ),
          ),

          // 2. Top Header overlay with "menu" and "notifications"
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_rounded, color: Color(0xFF006D77), size: 20),
                        SizedBox(width: 6),
                        Text(
                          'menu',
                          style: TextStyle(
                            color: Color(0xFF006D77),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'notifications',
                          style: TextStyle(
                            color: Color(0xFF006D77),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.notifications_rounded, color: Color(0xFF006D77), size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Overlay Floating Cards
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Alert Card: Route Deviation Detected
                _buildRouteDeviationCard(),

                const SizedBox(height: 12),

                // Intelligence Report Card
                _buildIntelligenceReportCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteDeviationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Coral left accent border line
              Container(
                width: 5,
                color: const Color(0xFFFF6B6B),
              ),

              // Card Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Icon, Title & ALERT Tag
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFECE8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.alt_route_rounded,
                              color: Color(0xFFFF6B6B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Route Deviation\nDetected',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A2D35),
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ALERT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Body Text
                      const Text(
                        "It looks like you've taken a detour from the planned path to the hotel. We've assessed the new area.",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6B7C85),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Two Action Buttons Side-by-Side
                      Row(
                        children: [
                          // Button 1: I'm ok, exploring!
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _isExploring = true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Atlas Safety: Exploring mode active. We will monitor your location.'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF006D77),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                _isExploring ? 'Exploring Active' : "I'm ok,\nexploring!",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Button 2: Guide me back
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Rerouting back to planned hotel itinerary...'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF006D77),
                                side: const BorderSide(color: Color(0xFF006D77), width: 1.2),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Guide me\nback',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntelligenceReportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F6F8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.radar_rounded,
              color: Color(0xFF006D77),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Intelligence\nReport',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2D35),
                height: 1.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF2F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7C85),
                  ),
                ),
                Text(
                  'Sync',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7C85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TokyoMapPainter extends CustomPainter {
  final Animation<double> pulseAnimation;

  _TokyoMapPainter({required this.pulseAnimation}) : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF1F5F8);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Draw Parks / Green areas
    final parkPaint = Paint()..color = const Color(0xFFE1EFE6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.12, 120, 80),
        const Radius.circular(30),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.22, 140, 100),
        const Radius.circular(40),
      ),
      parkPaint,
    );

    // Draw Rivers / Waterways
    final waterPaint = Paint()
      ..color = const Color(0xFFCCE8EE)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final riverPath = Path();
    riverPath.moveTo(-20, size.height * 0.15);
    riverPath.cubicTo(
      size.width * 0.4,
      size.height * 0.18,
      size.width * 0.6,
      size.height * 0.35,
      size.width + 20,
      size.height * 0.32,
    );
    canvas.drawPath(riverPath, waterPaint);

    // Draw Primary Road Grid
    final majorRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;

    final roadBorderPaint = Paint()
      ..color = const Color(0xFFD6DFE6)
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;

    final highwayPaint = Paint()
      ..color = const Color(0xFFF8D7DA)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    // Road lines
    final List<Path> roads = [];

    // Horizontal roads
    final r1 = Path()
      ..moveTo(0, size.height * 0.25)
      ..lineTo(size.width, size.height * 0.27);
    final r2 = Path()
      ..moveTo(0, size.height * 0.42)
      ..lineTo(size.width, size.height * 0.38);
    final r3 = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.56);

    // Vertical roads
    final r4 = Path()
      ..moveTo(size.width * 0.28, 0)
      ..lineTo(size.width * 0.25, size.height * 0.7);
    final r5 = Path()
      ..moveTo(size.width * 0.72, 0)
      ..lineTo(size.width * 0.75, size.height * 0.7);

    roads.addAll([r1, r2, r3, r4, r5]);

    for (final r in roads) {
      canvas.drawPath(r, roadBorderPaint);
      canvas.drawPath(r, majorRoadPaint);
    }

    // Express Highway
    final hw = Path()
      ..moveTo(0, size.height * 0.1)
      ..cubicTo(
        size.width * 0.4,
        size.height * 0.3,
        size.width * 0.6,
        size.height * 0.4,
        size.width,
        size.height * 0.5,
      );
    canvas.drawPath(hw, highwayPaint);

    // Planned Route (Dotted Blue/Teal)
    final plannedPaint = Paint()
      ..color = const Color(0xFF00798C)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final plannedPath = Path()
      ..moveTo(size.width * 0.44, size.height * 0.32)
      ..lineTo(size.width * 0.45, size.height * 0.38);
    canvas.drawPath(plannedPath, plannedPaint);

    // Route Deviation Line (Red/Coral Dotted Curve)
    final detourPaint = Paint()
      ..color = const Color(0xFFFF6B6B)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final detourPath = Path()
      ..moveTo(size.width * 0.45, size.height * 0.38)
      ..cubicTo(
        size.width * 0.48,
        size.height * 0.44,
        size.width * 0.55,
        size.height * 0.48,
        size.width * 0.52,
        size.height * 0.52,
      );
    canvas.drawPath(detourPath, detourPaint);

    // District City Labels
    _drawMapText(canvas, 'Shinjuku City\n新宿区', size.width * 0.68, size.height * 0.12);
    _drawMapText(canvas, 'Nakano City\n中野区', size.width * 0.5, size.height * 0.18);
    _drawMapText(canvas, 'Setagaya City\n世田谷区', size.width * 0.46, size.height * 0.48);
    _drawMapText(canvas, 'Shibuya\n渋谷', size.width * 0.78, size.height * 0.32);
    _drawMapText(canvas, 'Mitaka\n三鷹市', size.width * 0.12, size.height * 0.28);

    // User Location Pin "📍 You"
    final userX = size.width * 0.45;
    final userY = size.height * 0.38;

    // Pulse Ring
    final pulsePaint = Paint()
      ..color = const Color(0xFF006D77).withValues(alpha: 0.3 * (1 - pulseAnimation.value))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(userX, userY), 14 + 10 * pulseAnimation.value, pulsePaint);

    // Center Pin Circle
    final pinPaint = Paint()..color = const Color(0xFF006D77);
    canvas.drawCircle(Offset(userX, userY), 7, pinPaint);
    final pinInnerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(userX, userY), 3, pinInnerPaint);

    // "You" Badge
    final badgeRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(userX, userY - 22), width: 56, height: 22),
      const Radius.circular(10),
    );
    final badgeBg = Paint()..color = Colors.white;
    final badgeBorder = Paint()
      ..color = const Color(0xFFB5D3D6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(badgeRRect, badgeBg);
    canvas.drawRRect(badgeRRect, badgeBorder);

    // "You" text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '▲ You',
        style: TextStyle(
          color: Color(0xFF006D77),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(userX - textPainter.width / 2, userY - 30));
  }

  void _drawMapText(Canvas canvas, String text, double x, double y) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF7D8C96),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          height: 1.15,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y));
  }

  @override
  bool shouldRepaint(covariant _TokyoMapPainter oldDelegate) => true;
}
