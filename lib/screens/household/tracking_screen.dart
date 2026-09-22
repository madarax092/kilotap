import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../services/google_maps_service.dart';
import '../../widgets/live_route_map.dart';

class TrackingScreen extends StatefulWidget {
  final String collectorId;
  final String collectorName;
  final String bookingId;
  final String vehicleType;
  final double destLat;
  final double destLon;

  const TrackingScreen({
    super.key,
    required this.collectorId,
    required this.collectorName,
    required this.bookingId,
    required this.destLat,
    required this.destLon,
    this.vehicleType = '',
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  double? _collectorLat;
  double? _collectorLon;
  RouteInfo? _route;

  @override
  void initState() {
    super.initState();
    // Loads once on open — deliberately not polling, to avoid repeated
    // Firestore reads and Google Routes API calls while this screen is open.
    _refreshCollectorLocation();
  }

  Future<void> _refreshCollectorLocation() async {
    final profile =
        await FirestoreService().collectorProfile(widget.collectorId);
    if (profile == null || !mounted) return;
    final lat = (profile['Current_Latitude'] as num?)?.toDouble() ?? 0;
    final lon = (profile['Current_Longitude'] as num?)?.toDouble() ?? 0;
    if (lat == 0 && lon == 0) return;
    setState(() {
      _collectorLat = lat;
      _collectorLon = lon;
    });
  }

  @override
  Widget build(BuildContext context) {
    final etaLabel =
        _route != null ? GoogleMapsService.formatEta(_route!.etaMinutes) : '—';
    final distanceLabel = _route != null
        ? GoogleMapsService.formatDistance(_route!.distanceKm)
        : (_collectorLat == null
            ? 'Waiting for collector location...'
            : 'Calculating...');

    return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Track ${widget.bookingId}',
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
              child: LiveRouteMap(
                destLat: widget.destLat,
                destLon: widget.destLon,
                originLat: _collectorLat,
                originLon: _collectorLon,
                height: double.infinity,
                borderRadius: BorderRadius.zero,
                onRouteLoaded: (route) {
                  if (!mounted) return;
                  setState(() => _route = route);
                },
              ),
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
                      children: [
                        const Text('Live ETA',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600)),
                        Text(etaLabel,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.sellerGreen)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(distanceLabel,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9CA3AF))),
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
                                widget.collectorName.isEmpty
                                    ? '?'
                                    : widget.collectorName
                                        .substring(
                                            0,
                                            widget.collectorName.length >= 2
                                                ? 2
                                                : 1)
                                        .toUpperCase(),
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
                            Text(widget.collectorName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Color(0xFF111827))),
                            const SizedBox(height: 4),
                            Text(
                                widget.vehicleType.isEmpty
                                    ? 'Collector'
                                    : widget.vehicleType,
                                style: const TextStyle(
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
