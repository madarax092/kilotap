import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'dart:async';

class CameraPrototypeScreen extends StatefulWidget {
  const CameraPrototypeScreen({super.key});

  @override
  State<CameraPrototypeScreen> createState() => _CameraPrototypeScreenState();
}

class _CameraPrototypeScreenState extends State<CameraPrototypeScreen> {
  bool _isAnalyzing = false;
  bool _showBoundingBoxes = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = true;
        });
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            setState(() {
              _isAnalyzing = false;
              _showBoundingBoxes = true;
            });
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                Navigator.pop(context, [
                  'refrigerator_standard',
                  'plastic_bottle_1L',
                  'plastic_bottle_1L',
                  'plastic_bottle_1L',
                  'metal_pipe_1m',
                ]);
              }
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFF1F2937),
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
          ),

          if (_showBoundingBoxes) ...[
            _BoundingBox(
                left: 40,
                top: 120,
                width: 150,
                height: 250,
                label: 'Refrigerator',
                color: AppColors.sellerGreen),
            _BoundingBox(
                left: 220,
                top: 300,
                width: 40,
                height: 80,
                label: 'Plastic',
                color: Colors.blue),
            _BoundingBox(
                left: 270,
                top: 310,
                width: 40,
                height: 80,
                label: 'Plastic',
                color: Colors.blue),
            _BoundingBox(
                left: 100,
                top: 400,
                width: 180,
                height: 40,
                label: 'Metal Pipe',
                color: Colors.orange),
          ],

          if (_isAnalyzing)
            Positioned.fill(
              child: Container(
                color: AppColors.sellerGreen.withOpacity(0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(color: AppColors.sellerGreen),
                  ],
                ),
              ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Text('LIVE',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _BoundingBox extends StatelessWidget {
  final double left, top, width, height;
  final String label;
  final Color color;

  const _BoundingBox(
      {required this.left,
      required this.top,
      required this.width,
      required this.height,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          color: color.withOpacity(0.1),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            color: color,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += size.width / 3) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += size.height / 3) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
