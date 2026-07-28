import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ─── Collector Route Navigation ───

class MyRouteScreen extends StatelessWidget {
  const MyRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Full-screen map
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE8F0E3),
              child: CustomPaint(
                painter: _GoogleMapPainter(),
                size: Size.infinite,
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x20000000),
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ],
                ),
                child: const Icon(Icons.arrow_back,
                    color: Color(0xFF333333), size: 22),
              ),
            ),
          ),

          // Bottom ETA card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 20,
                      offset: Offset(0, -4))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ETA + Distance + Time row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Metric(
                          icon: Icons.timer_outlined,
                          value: '6.2',
                          unit: 'min',
                          label: 'ETA'),
                      Container(
                          width: 1,
                          height: 40,
                          color: const Color(0xFFEEEEEE)),
                      _Metric(
                          icon: Icons.route_outlined,
                          value: '2.1',
                          unit: 'km',
                          label: 'Distance'),
                      Container(
                          width: 1,
                          height: 40,
                          color: const Color(0xFFEEEEEE)),
                      _Metric(
                          icon: Icons.schedule_outlined,
                          value: '10:45',
                          unit: '',
                          label: 'Arrival'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Pickup summary
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.sellerGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('MS',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Maria Santos',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827))),
                              SizedBox(height: 2),
                              Text('Marfori Heights, Maa · 15 kg scrap',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        // Start button
                        SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.navigation_outlined,
                                size: 18),
                            label: const Text('Start',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buyerBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Navigation started!'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Metric Widget ───

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value, unit, label;
  const _Metric({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.buyerBlue, size: 22),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827))),
            if (unit.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(unit,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280))),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─── Google Maps-style Painter ───

class _GoogleMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base map color (light green-tinted like Google Maps)
    final bgPaint = Paint()..color = const Color(0xFFF0F5EB);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Park/water areas
    final parkPaint = Paint()..color = const Color(0xFFDCE8D0);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.1, size.width * 0.3, size.height * 0.25), parkPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.7, size.height * 0.5, size.width * 0.3, size.height * 0.3), parkPaint);

    // Water area
    final waterPaint = Paint()..color = const Color(0xFFB8D4E3);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.08), waterPaint);

    // Roads (gray)
    final roadPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Horizontal roads
    final roads = [
      [0.0, 0.25], [0.0, 0.42], [0.0, 0.58], [0.0, 0.72], [0.0, 0.88],
    ];
    for (var r in roads) {
      canvas.drawLine(
        Offset(0, size.height * r[1]),
        Offset(size.width, size.height * r[1]),
        roadPaint,
      );
    }

    // Vertical roads
    final vroads = [0.12, 0.28, 0.45, 0.62, 0.78, 0.92];
    for (var r in vroads) {
      canvas.drawLine(
        Offset(size.width * r, 0),
        Offset(size.width * r, size.height),
        roadPaint,
      );
    }

    // Road labels
    final labelPaint = Paint()..color = const Color(0xFF999999);
    // Simplified — no text rendering in CustomPaint without text painter

    // Blue route path (thick)
    final routePaint = Paint()
      ..color = const Color(0xFF4285F4)  // Google Maps blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final routeShadow = Paint()
      ..color = const Color(0xFF4285F4).withOpacity(0.2)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Route from collector (bottom-right) to household (upper-left)
    final path = Path()
      ..moveTo(size.width * 0.75, size.height * 0.85)
      ..lineTo(size.width * 0.70, size.height * 0.78)
      ..lineTo(size.width * 0.72, size.height * 0.70)
      ..lineTo(size.width * 0.60, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.48, size.width * 0.38, size.height * 0.50)
      ..lineTo(size.width * 0.35, size.height * 0.42)
      ..quadraticBezierTo(size.width * 0.30, size.height * 0.35, size.width * 0.28, size.height * 0.28);

    canvas.drawPath(path, routeShadow);
    canvas.drawPath(path, routePaint);

    // Blue dots along route
    final dotPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    
    for (double t = 0; t < 1.0; t += 0.06) {
      final tangent = path.computeMetrics().first;
      final pos = tangent.getTangentForOffset(tangent.length * t.clamp(0.0, 1.0));
      if (pos != null) {
        canvas.drawCircle(pos.position, 2.5, dotPaint);
      }
    }

    // Collector marker (blue pin) — bottom right
    _drawPin(canvas, Offset(size.width * 0.75, size.height * 0.85),
        AppColors.buyerBlue, 'C', 16);

    // Household marker (green pin) — upper left
    _drawPin(canvas, Offset(size.width * 0.28, size.height * 0.28),
        AppColors.sellerGreen, 'H', 16);

    // Street name labels (white boxes)
    _drawLabel(canvas, 'Quimpo Blvd', Offset(size.width * 0.55, size.height * 0.70));
    _drawLabel(canvas, 'Ecoland Dr', Offset(size.width * 0.35, size.height * 0.50));
    _drawLabel(canvas, 'Maa Rd', Offset(size.width * 0.30, size.height * 0.35));
  }

  void _drawPin(Canvas canvas, Offset pos, Color color, String label, double size) {
    // Shadow
    final shadowPaint = Paint()..color = color.withOpacity(0.3);
    canvas.drawCircle(pos + const Offset(2, 3), size * 0.8, shadowPaint);

    // Pin body
    final pinPaint = Paint()..color = color;
    canvas.drawCircle(pos, size * 0.7, pinPaint);

    // White border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(pos, size * 0.7, borderPaint);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.55,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      pos - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset pos) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF555555),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // White background box
    final bgPaint = Paint()..color = Colors.white;
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        pos.dx - textPainter.width / 2 - 4,
        pos.dy - textPainter.height / 2 - 2,
        textPainter.width + 8,
        textPainter.height + 4,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(bgRect, bgPaint);

    textPainter.paint(
      canvas,
      pos - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
