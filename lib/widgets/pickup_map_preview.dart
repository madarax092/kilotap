import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/theme/app_colors.dart';

// The pickup-pin card on Sell Scrap: a small non-interactive map showing the
// confirmed pin, or a prompt when none is set. Tapping opens PinLocationPage.
class PickupMapPreview extends StatelessWidget {
  final LatLng? pin;
  // Highlights the empty state in red after a submit attempt without a pin.
  final bool showError;
  final VoidCallback onTap;

  const PickupMapPreview({
    super.key,
    required this.pin,
    required this.showError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pin = this.pin;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: showError && pin == null
                ? AppColors.error
                : const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: pin == null ? _empty() : _map(pin),
      ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.add_location_alt_outlined,
              size: 28,
              color: showError ? AppColors.error : AppColors.sellerGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pickup pin',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Tap to set your pickup pin on the map',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            showError ? AppColors.error : AppColors.textPrimary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 20),
        ],
      ),
    );
  }

  Widget _map(LatLng pin) {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          // Lite mode (a static map image) on Android keeps it light and lets
          // taps reach the card instead of the map.
          IgnorePointer(
            child: GoogleMap(
              key: ValueKey('${pin.latitude},${pin.longitude}'),
              initialCameraPosition: CameraPosition(target: pin, zoom: 16),
              liteModeEnabled: !kIsWeb && Platform.isAndroid,
              markers: {
                Marker(markerId: const MarkerId('pickup'), position: pin),
              },
              zoomControlsEnabled: false,
              zoomGesturesEnabled: false,
              scrollGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 4)
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_location_alt_outlined,
                      size: 14, color: AppColors.sellerGreen),
                  SizedBox(width: 4),
                  Text('Tap to change',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
