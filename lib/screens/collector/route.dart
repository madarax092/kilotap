import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../core/theme/app_colors.dart';

// ─── Collector Route Navigation ───

class MyRouteScreen extends StatelessWidget {
  const MyRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: const Text('Route Navigation',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 8),

          // Google Maps placeholder with route
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  // Map background
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RoutePainter(),
                    ),
                  ),
                  // Route info overlay
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x10000000),
                              blurRadius: 8,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _RouteInfo(Icons.route_outlined, '2.1 km', 'Distance'),
                          _RouteInfo(Icons.timer_outlined, '6.2 min', 'ETA'),
                          _RouteInfo(Icons.speed_outlined, '~30 km/h', 'Avg Speed'),
                        ],
                      ),
                    ),
                  ),
                  // Pickup label
                  Positioned(
                    top: 90,
                    left: 130,
                    child: _MapMarker('P', AppColors.sellerGreen, 'Pickup'),
                  ),
                  Positioned(
                    top: 140,
                    left: 180,
                    child: _MapMarker('C', AppColors.buyerBlue, 'You'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ETA Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Row(
                  children: const [
                    _Sum('2.1 km', 'Distance'),
                    _Sum('6.2 min', 'ETA'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    _Sum('~15 kg', 'Scrap Weight', accent: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Turn-by-turn directions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Directions',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _DirectionStep('1', 'Head north on Quimpo Blvd', '350 m', true),
                _DirectionStep('2', 'Turn right onto Ecoland Dr', '1.2 km', false),
                _DirectionStep('3', 'Turn left onto Maa Rd', '600 m', false),
                _DirectionStep('4', 'Arrive at Marfori Heights', '—', false),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.navigation_outlined, size: 18),
                  label: const Text('Start Navigation',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buyerBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Navigation started — follow the route'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.call_outlined, size: 18),
                  label: const Text('Call Seller',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sellerGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Calling seller...'),
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ─── Route Map Painter ───

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background grid
    final gridPaint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Streets (simplified)
    final roadPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 6;
    canvas.drawLine(const Offset(140, 100), Offset(200, 160), roadPaint);
    canvas.drawLine(Offset(200, 160), Offset(170, 200), roadPaint);
    canvas.drawLine(Offset(170, 200), Offset(190, 250), roadPaint);

    // Route path (blue)
    final routePaint = Paint()
      ..color = AppColors.buyerBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(185, 165)
      ..quadraticBezierTo(190, 185, 178, 200)
      ..quadraticBezierTo(170, 215, 182, 235);
    canvas.drawPath(path, routePaint);

    // Dashed route effect
    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (double t = 0; t < 1; t += 0.08) {
      final p = _evalQuad(Offset(185, 165), Offset(190, 185), Offset(178, 200), t);
      final p2 = _evalQuad(Offset(178, 200), Offset(170, 215), Offset(182, 235), t);
      canvas.drawCircle(p, 2, dashPaint);
      canvas.drawCircle(p2, 2, dashPaint);
    }
  }

  Offset _evalQuad(Offset p0, Offset p1, Offset p2, double t) {
    final x = (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx;
    final y = (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy;
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Widgets ───

class _Sum extends StatelessWidget {
  final String val, label;
  final bool accent;
  const _Sum(this.val, this.label, {this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(val,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: accent
                        ? AppColors.buyerBlue
                        : AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 9, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _RouteInfo extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _RouteInfo(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.buyerBlue, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary)),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  final String label;
  final Color color;
  final String subtitle;
  const _MapMarker(this.label, this.color, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Center(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12)),
          ),
        ),
        const SizedBox(height: 2),
        Text(subtitle,
            style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _DirectionStep extends StatelessWidget {
  final String num, instruction, distance;
  final bool isFirst;
  const _DirectionStep(this.num, this.instruction, this.distance, this.isFirst);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isFirst ? AppColors.buyerBlue : const Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(num,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color:
                                isFirst ? Colors.white : const Color(0xFF6B7280))),
                  ),
                ),
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 20,
                    color: const Color(0xFFE5E7EB),
                    margin: const EdgeInsets.only(top: 4),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(instruction,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isFirst
                            ? AppColors.textPrimary
                            : const Color(0xFF4B5563))),
                const SizedBox(height: 2),
                Text(distance,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
