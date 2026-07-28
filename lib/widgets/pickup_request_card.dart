import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ─── Pickup Request Card (Uber/Grab-style) ───

class PickupRequestCard extends StatelessWidget {
  final String name;
  final String initials;
  final String location;
  final String distance;
  final String quantity;
  final String material;
  final String volume;
  final String weight;
  final String? note;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const PickupRequestCard({
    super.key,
    required this.name,
    required this.initials,
    required this.location,
    required this.distance,
    required this.quantity,
    required this.material,
    required this.volume,
    required this.weight,
    this.note,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header Row ──
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[400],
                  radius: 20,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$location · $distance away',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ASAP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Scrap Photo ──
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomPaint(
                  painter: _ScrapPhotoPainter(),
                  size: const Size(double.infinity, 160),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Order Details ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DetailColumn(quantity, material),
                _DetailColumn(volume, 'Volume'),
                _DetailColumn(weight, 'Est. Weight'),
              ],
            ),

            // ── Note ──
            if (note != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '"$note"',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ── Action Buttons ──
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text(
                      'Accept',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buyerBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onAccept,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text(
                      'Decline',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280),
                      side: const BorderSide(
                          color: Color(0xFFE5E7EB), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onDecline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Detail Column ───

class _DetailColumn extends StatelessWidget {
  final String value, label;
  const _DetailColumn(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Scrap Photo Painter (placeholder with recyclables) ───

class _ScrapPhotoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background (floor/ground)
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFE8E0D8));

    // Cardboard box (center)
    final boxPaint = Paint()..color = const Color(0xFFC4A882);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.25, size.height * 0.25,
              size.width * 0.3, size.height * 0.5),
          const Radius.circular(4),
        ),
        boxPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.25, size.height * 0.25,
              size.width * 0.3, size.height * 0.5),
          const Radius.circular(4),
        ),
        Paint()
          ..color = const Color(0xFFB8956E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    // Plastic bottle (left)
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.08, size.height * 0.35,
              size.width * 0.1, size.height * 0.35),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFF90CAF9));
    canvas.drawCircle(
        Offset(size.width * 0.13, size.height * 0.32),
        size.width * 0.04,
        Paint()..color = const Color(0xFF64B5F6));

    // Aluminum can (right)
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.65, size.height * 0.30,
              size.width * 0.08, size.height * 0.4),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFFBDBDBD));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.65, size.height * 0.28,
              size.width * 0.08, size.height * 0.06),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF9E9E9E));

    // Scrap metal piece (bottom right)
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.75, size.height * 0.5,
            size.width * 0.15, size.height * 0.15),
        Paint()..color = const Color(0xFF8D6E63));
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.78, size.height * 0.65,
            size.width * 0.08, size.height * 0.2),
        Paint()..color = const Color(0xFF795548));

    // Wires (bottom left)
    final wirePaint = Paint()
      ..color = const Color(0xFFFF7043)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(size.width * 0.05, size.height * 0.75),
        Offset(size.width * 0.2, size.height * 0.8),
        wirePaint);
    canvas.drawLine(
        Offset(size.width * 0.05, size.height * 0.78),
        Offset(size.width * 0.25, size.height * 0.72),
        Paint()
          ..color = const Color(0xFFF4511E)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke);

    // Newspaper/paper
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.55,
            size.width * 0.15, size.height * 0.25),
        Paint()..color = const Color(0xFFFFF8E1));
    for (double y = size.height * 0.58;
        y < size.height * 0.78;
        y += size.height * 0.04) {
      canvas.drawLine(
          Offset(size.width * 0.56, y),
          Offset(size.width * 0.68, y),
          Paint()
            ..color = const Color(0xFFE0E0E0)
            ..strokeWidth = 0.5);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
