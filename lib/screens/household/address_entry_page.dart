import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/google_maps_service.dart';

class AddressEntryPage extends StatefulWidget {
  final String initialAddress;
  const AddressEntryPage({super.key, required this.initialAddress});

  @override
  State<AddressEntryPage> createState() => _AddressEntryPageState();
}

class _AddressEntryPageState extends State<AddressEntryPage> {
  // Davao City center — fallback pin position if GPS is unavailable/denied.
  static const _davaoCityCenter = LatLng(7.0731, 125.6128);

  late final _addrCtrl = TextEditingController(text: widget.initialAddress);
  LatLng _pin = _davaoCityCenter;
  bool _loadingLocation = true;
  bool _geocoding = false;
  bool _saving = false;
  Timer? _geocodeDebounce;

  @override
  void initState() {
    super.initState();
    _initPin();
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    _addrCtrl.dispose();
    super.dispose();
  }

  Future<void> _initPin() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          !await Geolocator.isLocationServiceEnabled()) {
        if (mounted) setState(() => _loadingLocation = false);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      if (!mounted) return;
      setState(() => _loadingLocation = false);
      final pos = LatLng(position.latitude, position.longitude);
      // Only auto-fill from GPS on first use (empty address) — a returning
      // user's already-saved, trusted address shouldn't get silently
      // overwritten just because their GPS reading drifted slightly.
      if (_addrCtrl.text.trim().isEmpty) {
        _updatePin(pos);
      } else {
        setState(() => _pin = pos);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  // Moves the pin immediately for responsive dragging/tapping, but debounces
  // the actual reverse-geocode call — otherwise a user exploring the map
  // with several taps before settling burns one Geocoding API call per tap.
  void _updatePin(LatLng position) {
    setState(() {
      _pin = position;
      _geocoding = true;
    });
    _geocodeDebounce?.cancel();
    _geocodeDebounce =
        Timer(const Duration(milliseconds: 600), () => _geocodeNow(position));
  }

  Future<void> _geocodeNow(LatLng position) async {
    final address =
        await GoogleMapsService.reverseGeocode(position.latitude, position.longitude);
    if (!mounted) return;
    setState(() {
      _geocoding = false;
      if (address != null && address.isNotEmpty) {
        _addrCtrl.text = address;
      }
    });
  }

  Future<void> _save() async {
    final address = _addrCtrl.text.trim();
    if (address.isEmpty) return;
    setState(() => _saving = true);
    try {
      await AuthService.instance.updateSellerProfile(address: address);
      if (!mounted) return;
      Navigator.pop(context, address);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not save address: $e'),
        backgroundColor: Colors.red,
      ));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pickup Address',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
              'Drag the pin to your exact location, or type the address manually below.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              child: _loadingLocation
                  ? Container(
                      color: const Color(0xFFF5F5F5),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : GoogleMap(
                      initialCameraPosition:
                          CameraPosition(target: _pin, zoom: 16),
                      onTap: _updatePin,
                      markers: {
                        Marker(
                          markerId: const MarkerId('pin'),
                          position: _pin,
                          draggable: true,
                          onDragEnd: _updatePin,
                        ),
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          if (_geocoding)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Looking up address...',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _addrCtrl,
            maxLines: 3,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Block/Lot/Street, Barangay, City',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text('SAVE ADDRESS',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
