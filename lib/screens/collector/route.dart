import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ─── Collector Navigation (Grab/Uber-style) ───

class MyRouteScreen extends StatelessWidget {
  const MyRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Map Placeholder — replace with Google Maps widget
            Container(
              color: const Color(0xFFE8F0E3),
              child: CustomPaint(
                painter: _NavMapPainter(),
                size: Size.infinite,
              ),
            ),

            // 2. Top Turn-by-Turn Banner
            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.turn_right,
                        color: Colors.white, size: 32),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('200 m',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                          Text('Turn right onto Ma-a Road',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Bottom Info Sheet
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // ETA Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('9 min',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.sellerGreen)),
                            const SizedBox(height: 2),
                            Text('2.3 km • 10:45 AM',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600])),
                          ],
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.phone),
                          color: AppColors.buyerBlue,
                          iconSize: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Seller Info Card
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.sellerGreen,
                        radius: 22,
                        child: const Text('MS',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15)),
                      ),
                      title: const Text('Maria Santos',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: const Text('Pickup: 15 kg Mixed Scrap',
                          style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(height: 12),

                    // Green Status Bar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pickup accepted! Starting navigation...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
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
      ),
    );
  }
}

// ─── Navigation Map Painter ───

class _NavMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base map
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFEBF0E6));

    // Parks
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.05, size.width * 0.35, size.height * 0.2),
        Paint()..color = const Color(0xFFD8E4CE));
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.6, size.height * 0.55, size.width * 0.4, size.height * 0.35),
        Paint()..color = const Color(0xFFD8E4CE));

    // Water
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.06),
        Paint()..color = const Color(0xFFB8D4E3));

    // Roads
    final road = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (var y in [0.22, 0.38, 0.55, 0.70, 0.85]) {
      canvas.drawLine(
          Offset(0, size.height * y),
          Offset(size.width, size.height * y),
          road);
    }
    for (var x in [0.10, 0.25, 0.42, 0.58, 0.75, 0.90]) {
      canvas.drawLine(
          Offset(size.width * x, 0),
          Offset(size.width * x, size.height),
          road);
    }

    // Blue route path
    final route = Paint()
      ..color = const Color(0xFF2979FF)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final routeShadow = Paint()
      ..color = const Color(0xFF2979FF).withOpacity(0.15)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.72, size.height * 0.82)
      ..lineTo(size.width * 0.68, size.height * 0.73)
      ..lineTo(size.width * 0.58, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.42,
          size.width * 0.35, size.height * 0.38)
      ..lineTo(size.width * 0.30, size.height * 0.25);

    canvas.drawPath(path, routeShadow);
    canvas.drawPath(path, route);

    // White dots along route
    final dot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final metrics = path.computeMetrics().first;
    for (double t = 0; t <= 1.0; t += 0.07) {
      final pos = metrics.getTangentForOffset(metrics.length * t);
      if (pos != null) {
        canvas.drawCircle(pos.position, 2.5, dot);
      }
    }

    // Destination pin (green — household)
    _drawPin(canvas, Offset(size.width * 0.30, size.height * 0.23),
        AppColors.sellerGreen, 'MS');

    // Origin marker (blue — collector)
    _drawPin(canvas, Offset(size.width * 0.72, size.height * 0.82),
        AppColors.buyerBlue, 'C');

    // Floating ETA callout near destination
    _drawCallout(canvas, '9 min • 2.3 km',
        Offset(size.width * 0.32, size.height * 0.16));

    // Road labels
    _drawLabel(canvas, 'Quimpo Blvd', Offset(size.width * 0.55, size.height * 0.54));
    _drawLabel(canvas, 'Ecoland Dr', Offset(size.width * 0.36, size.height * 0.37));
    _drawLabel(canvas, 'Ma-a Road', Offset(size.width * 0.31, size.height * 0.26));
  }

  void _drawPin(Canvas canvas, Offset p, Color color, String label) {
    // Shadow
    canvas.drawCircle(
        p + const Offset(2, 3), 14,
        Paint()..color = Colors.black12);
    // Body
    canvas.drawCircle(p, 14, Paint()..color = color);
    // Ring
    canvas.drawCircle(p, 14,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    // Label
    final tp = TextPainter(
      text: TextSpan(
          text: label,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawCallout(Canvas canvas, String text, Offset p) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: const TextStyle(
              color: Color(0xFF333333),
              fontWeight: FontWeight.w700,
              fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();

    final box = RRect.fromRectAndRadius(
      Rect.fromLTWH(p.dx - tp.width / 2 - 8, p.dy - tp.height / 2 - 6,
          tp.width + 16, tp.height + 12),
      const Radius.circular(6),
    );
    canvas.drawRRect(box, Paint()..color = Colors.white);
    canvas.drawRRect(box,
        Paint()
          ..color = const Color(0xFFDDDDDD)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawLabel(Canvas canvas, String text, Offset p) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: const TextStyle(
              color: Color(0xFF666666),
              fontWeight: FontWeight.w600,
              fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(p.dx - tp.width / 2 - 3, p.dy - tp.height / 2 - 2,
            tp.width + 6, tp.height + 4),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white,
    );
    tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
