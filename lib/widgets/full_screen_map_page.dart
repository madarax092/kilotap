import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/google_maps_service.dart';
import 'live_route_map.dart';

// Full-screen, pannable/zoomable version of a LiveRouteMap — opened by
// tapping a small inline map so the user can actually look around.
class FullScreenMapPage extends StatefulWidget {
  final String title;
  final double destLat;
  final double destLon;
  final double? originLat;
  final double? originLon;

  const FullScreenMapPage({
    super.key,
    required this.title,
    required this.destLat,
    required this.destLon,
    this.originLat,
    this.originLon,
  });

  @override
  State<FullScreenMapPage> createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<FullScreenMapPage> {
  RouteInfo? _route;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.title,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: LiveRouteMap(
              destLat: widget.destLat,
              destLon: widget.destLon,
              originLat: widget.originLat,
              originLon: widget.originLon,
              height: double.infinity,
              borderRadius: BorderRadius.zero,
              onRouteLoaded: (route) {
                if (mounted) setState(() => _route = route);
              },
            ),
          ),
          if (_route != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                child: Material(
                  color: Colors.white,
                  elevation: 3,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Stat(
                            GoogleMapsService.formatDistance(_route!.distanceKm),
                            'Distance'),
                        _Stat(GoogleMapsService.formatEta(_route!.etaMinutes),
                            'ETA'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
      ],
    );
  }
}
