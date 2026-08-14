import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bounding_box_painter.dart';
import '../../widgets/scrap_item_table.dart';

/// ─── Detection Results Screen ───

class DetectionResultsScreen extends StatelessWidget {
  const DetectionResultsScreen({super.key});

  static const _mockBoxes = [
    DetectionBox(
        className: 'Copper Wire',
        confidence: 0.92,
        x: 0.08,
        y: 0.15,
        w: 0.40,
        h: 0.35),
    DetectionBox(
        className: 'Plastic Bottle',
        confidence: 0.88,
        x: 0.55,
        y: 0.20,
        w: 0.35,
        h: 0.40),
    DetectionBox(
        className: 'Cardboard Box',
        confidence: 0.74,
        x: 0.15,
        y: 0.60,
        w: 0.45,
        h: 0.30),
    DetectionBox(
        className: 'Iron Bar',
        confidence: 0.65,
        x: 0.65,
        y: 0.65,
        w: 0.28,
        h: 0.25),
  ];

  static const _mockItems = [
    ScrapItem(name: 'Copper Wire', quantity: 3),
    ScrapItem(name: 'Plastic Bottle', quantity: 6),
    ScrapItem(name: 'Cardboard Box', quantity: 2),
    ScrapItem(name: 'Iron Bar', quantity: 1),
  ];

  @override
  Widget build(BuildContext context) {
    final totalItems =
        _mockItems.fold<int>(0, (sum, i) => sum + i.quantity);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detection Results',
            style: TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: const Color(0xFFE5E7EB), height: 1.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/sample_scrap.jpg',
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  cacheWidth: 800,
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: BoundingBoxPainter(boxes: _mockBoxes),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.buyerBlue,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: AppColors.buyerBlue.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(Icons.inventory_2_outlined, '$totalItems',
                    'items detected'),
                _SummaryItem(Icons.scale_outlined, '56', 'kg total'),
                _SummaryItem(Icons.local_shipping_outlined, 'Multicab',
                    'recommended'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const ScrapItemTable(items: _mockItems),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retake',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(
                        color: Color(0xFFE5E7EB), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Confirm Items',
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
                      content: Text('Items confirmed! Proceeding to booking.'),
                      backgroundColor: AppColors.sellerGreen,
                      behavior: SnackBarBehavior.floating,
                    ));
                    // TODO: navigate to sell_scrap with pre-filled items
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _SummaryItem(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
