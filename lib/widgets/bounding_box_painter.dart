import 'package:flutter/material.dart';

/// ─── Bounding Box Painter ───

class BoundingBoxPainter extends CustomPainter {
  final List<DetectionBox> boxes;

  const BoundingBoxPainter({required this.boxes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final box in boxes) {
      final color = _colorFor(box.confidence);

      final rect = Rect.fromLTWH(
        box.x * size.width,
        box.y * size.height,
        box.w * size.width,
        box.h * size.height,
      );

      final borderPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRect(rect, borderPaint);

      final cornerPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      final c = 14.0;
      canvas.drawLine(rect.topLeft, rect.topLeft + Offset(c, 0), cornerPaint);
      canvas.drawLine(rect.topLeft, rect.topLeft + Offset(0, c), cornerPaint);
      canvas.drawLine(rect.topRight, rect.topRight + Offset(-c, 0), cornerPaint);
      canvas.drawLine(rect.topRight, rect.topRight + Offset(0, c), cornerPaint);
      canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(c, 0), cornerPaint);
      canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(0, -c), cornerPaint);
      canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(-c, 0), cornerPaint);
      canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(0, -c), cornerPaint);

      final label = '${box.className} ${(box.confidence * 100).round()}%';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelBg = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          rect.left,
          rect.top - tp.height - 8,
          tp.width + 12,
          tp.height + 6,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(labelBg, Paint()..color = color);

      tp.paint(
        canvas,
        Offset(rect.left + 6, rect.top - tp.height - 5),
      );
    }
  }

  Color _colorFor(double confidence) {
    if (confidence > 0.8) return const Color(0xFF4CAF50);
    if (confidence >= 0.5) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) =>
      oldDelegate.boxes != boxes;
}

class DetectionBox {
  final String className;
  final double confidence;
  final double x, y, w, h;
  const DetectionBox({
    required this.className,
    required this.confidence,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });
}
