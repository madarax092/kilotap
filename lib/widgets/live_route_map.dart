import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/google_maps_service.dart';
import '../services/polyline_decoder.dart';

/// Real Google Map showing a destination pin, and — when [originLat]/[originLon]
/// are supplied — the live route + polyline between origin and destination.
/// Replaces the static `davao_nav_map.png` placeholder used across the app.
class LiveRouteMap extends StatefulWidget {
  final double destLat;
  final double destLon;
  final double? originLat;
  final double? originLon;
  final double height;
  final BorderRadius borderRadius;
  final void Function(RouteInfo?)? onRouteLoaded;

  const LiveRouteMap({
    super.key,
    required this.destLat,
    required this.destLon,
    this.originLat,
    this.originLon,
    this.height = 220,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.onRouteLoaded,
  });

  @override
  State<LiveRouteMap> createState() => _LiveRouteMapState();
}

class _LiveRouteMapState extends State<LiveRouteMap> {
  RouteInfo? _route;
  bool _loading = true;
  GoogleMapController? _controller;

  bool get _hasOrigin => widget.originLat != null && widget.originLon != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_hasOrigin) {
      final route = await GoogleMapsService.getRoute(
        originLat: widget.originLat!,
        originLon: widget.originLon!,
        destLat: widget.destLat,
        destLon: widget.destLon,
      );
      if (!mounted) return;
      setState(() {
        _route = route;
        _loading = false;
      });
      widget.onRouteLoaded?.call(route);
      if (route != null && route.polyline.isNotEmpty) {
        _fitBounds();
      }
    } else {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _fitBounds() {
    if (_controller == null) return;
    final origin = LatLng(widget.originLat!, widget.originLon!);
    final dest = LatLng(widget.destLat, widget.destLon);
    final bounds = LatLngBounds(
      southwest: LatLng(
        origin.latitude < dest.latitude ? origin.latitude : dest.latitude,
        origin.longitude < dest.longitude ? origin.longitude : dest.longitude,
      ),
      northeast: LatLng(
        origin.latitude > dest.latitude ? origin.latitude : dest.latitude,
        origin.longitude > dest.longitude ? origin.longitude : dest.longitude,
      ),
    );
    _controller!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return ClipRRect(
        borderRadius: widget.borderRadius,
        child: Container(
          height: widget.height,
          color: const Color(0xFFE5E7EB),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final destLatLng = LatLng(widget.destLat, widget.destLon);
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('destination'),
        position: destLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
    if (_hasOrigin) {
      markers.add(Marker(
        markerId: const MarkerId('origin'),
        position: LatLng(widget.originLat!, widget.originLon!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }

    final polylines = <Polyline>{};
    if (_route != null && _route!.polyline.isNotEmpty) {
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: PolylineDecoder.decode(_route!.polyline),
        color: const Color(0xFF1A85C8),
        width: 4,
      ));
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        height: widget.height,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: destLatLng, zoom: 14),
          markers: markers,
          polylines: polylines,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          onMapCreated: (controller) {
            _controller = controller;
            if (_hasOrigin && _route != null && _route!.polyline.isNotEmpty) {
              _fitBounds();
            }
          },
        ),
      ),
    );
  }
}
