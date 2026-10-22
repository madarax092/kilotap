import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/theme/app_colors.dart';

// Full-screen pickup pin picker. The pin is fixed at the center of the screen
// and the user moves the map underneath it; Confirm pops with the map center.
class PinLocationPage extends StatefulWidget {
  // Previously confirmed pin, if any — the map opens here instead of at GPS.
  final LatLng? initialPin;
  final String address;
  // Opens the address form and returns the new address, or null if the user
  // backed out. Null hides the edit affordance.
  final Future<String?> Function()? onEditAddress;

  const PinLocationPage({
    super.key,
    this.initialPin,
    required this.address,
    this.onEditAddress,
  });

  @override
  State<PinLocationPage> createState() => _PinLocationPageState();
}

class _PinLocationPageState extends State<PinLocationPage> {
  // Davao City center — fallback when there's no saved pin and no GPS.
  static const _davao = LatLng(7.0731, 125.6128);
  static const _pinSize = 48.0;

  GoogleMapController? _controller;
  late LatLng _center = widget.initialPin ?? _davao;
  late String _address = widget.address;
  bool _moving = false;
  bool _locating = false;
  bool _hasLocationPermission = false;
  bool _locationOff = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPin == null) {
      _locate(initial: true);
    } else {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final p = await Geolocator.checkPermission();
    if (!mounted) return;
    setState(() => _hasLocationPermission = p == LocationPermission.always ||
        p == LocationPermission.whileInUse);
  }

  // Moves the map to the device's GPS fix. [initial] suppresses the error
  // snackbar on first open (the banner explains it instead).
  Future<void> _locate({bool initial = false}) async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      setState(() {
        _hasLocationPermission = granted;
        _locationOff = !granted || !serviceOn;
      });
      if (!granted || !serviceOn) {
        if (!initial) _snack('Turn on location to jump to where you are.');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 8)));
      final target = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      _center = target;
      await _controller?.animateCamera(CameraUpdate.newLatLngZoom(target, 17));
    } catch (_) {
      if (!mounted) return;
      setState(() => _locationOff = true);
      if (!initial) _snack('Could not get your location. Move the map instead.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Rough Davao City bounds — a soft check only, never blocks.
  bool get _insideDavao =>
      _center.latitude >= 6.75 &&
      _center.latitude <= 7.65 &&
      _center.longitude >= 125.15 &&
      _center.longitude <= 125.75;

  Future<void> _confirm() async {
    if (!_insideDavao) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Outside Davao City?'),
          content: const Text(
              'This pin is outside Davao City, where KiloTap collectors operate. Use it anyway?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Move pin')),
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Use anyway')),
          ],
        ),
      );
      if (proceed != true) return;
    }
    if (!mounted) return;
    Navigator.pop(context, _center);
  }

  Future<void> _editAddress() async {
    final edit = widget.onEditAddress;
    if (edit == null) return;
    final updated = await edit();
    if (updated != null && mounted) setState(() => _address = updated);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasAddress = _address.trim().isNotEmpty;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: _center, zoom: widget.initialPin == null ? 12 : 17),
              onMapCreated: (c) => _controller = c,
              onCameraMoveStarted: () => setState(() => _moving = true),
              onCameraMove: (p) => _center = p.target,
              onCameraIdle: () => setState(() => _moving = false),
              myLocationEnabled: _hasLocationPermission,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
          ),
          // Pin: its tip sits exactly on the map center (the icon is shifted
          // up by half its height), and it lifts while the map is moving.
          IgnorePointer(
            child: Center(
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 150),
                offset: Offset(0, _moving ? -0.2 : 0),
                child: Transform.translate(
                  offset: const Offset(0, -_pinSize / 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: _moving ? 0 : 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.sellerGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Pickup here',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.location_on,
                          size: _pinSize, color: AppColors.sellerGreen),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Material(
                    color: Colors.white,
                    elevation: 3,
                    borderRadius: BorderRadius.circular(14),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: widget.onEditAddress == null
                                ? null
                                : _editAddress,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pickup address',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(
                                      hasAddress ? _address : 'Add your address',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: hasAddress
                                              ? AppColors.textPrimary
                                              : AppColors.sellerGreen)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (widget.onEditAddress != null)
                          const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.edit_outlined,
                                size: 18, color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  if (_locationOff && widget.initialPin == null) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                          'Location is off. Move the map to your home.',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Material(
              color: Colors.white,
              elevation: 3,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _locating ? null : () => _locate(),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: _locating
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location,
                          color: AppColors.textPrimary),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sellerGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _confirm,
                child: const Text('CONFIRM PIN',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
