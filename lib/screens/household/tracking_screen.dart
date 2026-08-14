import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TrackingScreen extends StatelessWidget {
  final String collectorName;
  final String bookingId;

  const TrackingScreen(
      {super.key, required this.collectorName, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Track $bookingId',
              style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.5),
            child: Container(color: const Color(0xFFE5E7EB), height: 1.5),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                  width: double.infinity,
                  color: const Color(0xFFE5E7EB),
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: Opacity(
                        opacity: 0.5,
                        child: Image.asset(
                          'assets/images/davao_nav_map.png',
                          fit: BoxFit.cover,
                          cacheWidth: 800,
                        ),
                      )),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on,
                                color: AppColors.error, size: 40),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12, blurRadius: 4)
                                  ]),
                              child: const Text('Your Location',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: Color(0xFF111827))),
                            ),
                            const SizedBox(height: 40),
                            const Icon(Icons.local_shipping,
                                color: AppColors.sellerGreen, size: 40),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: AppColors.sellerGreen,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12, blurRadius: 4)
                                  ]),
                              child: Text(collectorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
            ),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 10,
                      offset: Offset(0, -4))
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Arriving in',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600)),
                        Text('5 min',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.sellerGreen)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF3F4F6), height: 1),
                    const SizedBox(height: 16),
                    Row(children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                            color: Colors.blueAccent, shape: BoxShape.circle),
                        child: Center(
                            child: Text(
                                collectorName.substring(0, 2).toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(collectorName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Color(0xFF111827))),
                            const SizedBox(height: 4),
                            const Text('Tricycle \u00b7 ABC-1234',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.phone,
                            color: AppColors.sellerGreen, size: 20),
                      ),
                    ])
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
