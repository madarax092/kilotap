import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/theme/app_colors.dart';

class FindScrapScreen extends StatefulWidget {
  const FindScrapScreen({super.key});
  @override State<FindScrapScreen> createState() => _FindScrapScreenState();
}

class _FindScrapScreenState extends State<FindScrapScreen> {
  final Set<Marker> _markers = {};
  bool _accepted = false;

  static const _davaoCenter = LatLng(7.0712, 125.6089);

  @override void initState() {
    super.initState();
    _markers.addAll({
      Marker(markerId: MarkerId('you'), position: _davaoCenter, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), infoWindow: InfoWindow(title: 'You are here')),
      Marker(markerId: MarkerId('p1'), position: LatLng(7.0735, 125.6110), infoWindow: InfoWindow(title: '25 kg · Scrap Iron'), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
      Marker(markerId: MarkerId('p2'), position: LatLng(7.0715, 125.6140), infoWindow: InfoWindow(title: '3.2 kg · Plastic'), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)),
      Marker(markerId: MarkerId('p3'), position: LatLng(7.0695, 125.6105), infoWindow: InfoWindow(title: '12 kg · Mixed'), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)),
    });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(automaticallyImplyLeading: false, backgroundColor: AppColors.canvas, elevation: 0, title: const Text('Find Scrap', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
      body: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [_Filt('All', true), _Filt('<1 km', false), _Filt('<3 km', false), _Filt('Heavy', false), _Filt('ASAP', false), _Filt('Metal', false)]))),
        const SizedBox(height: 12),
        // Google Maps
        Container(height: 260, margin: const EdgeInsets.symmetric(horizontal: 28), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)), clipBehavior: Clip.antiAlias, child: GoogleMap(
   initialCameraPosition: const CameraPosition(target: _davaoCenter, zoom: 14.5),
   markers: _markers,
          myLocationEnabled: false,
          zoomControlsEnabled: false,
        )),
        const SizedBox(height: 12),
        if (!_accepted) Container(margin: const EdgeInsets.symmetric(horizontal: 28), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.buyerBlue.withOpacity(0.3), width: 1.5)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Maria Santos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)), const Text('Maa · 0.3 km', style: TextStyle(fontSize: 10, color: AppColors.textSecondary))]),
          const SizedBox(height: 8),
          Row(children: [const _Det('3.2 kg', 'Load'), const _Det('0.35', 'Volume'), const _Det('ASAP', '')].map((d) => Padding(padding: const EdgeInsets.only(right: 16), child: d)).toList()),
          const SizedBox(height: 10),
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(8)), child: const Text('"Gate code #1234, ring bell"', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.buyerBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => setState(() => _accepted = true), child: const Text('ACCEPT'))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.inputGrey, foregroundColor: AppColors.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request declined'))), child: const Text('DECLINE'))),
          ]),
        ])),
        if (_accepted) Container(margin: const EdgeInsets.symmetric(horizontal: 28), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.success.withOpacity(0.3))), child: const Row(children: [Icon(Icons.check_circle, color: AppColors.success, size: 20), SizedBox(width: 8), Expanded(child: Text('Pickup accepted! Juan Dela Cruz is on the way. ETA: 5 min', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12)))])),
      ]),
      bottomNavigationBar: BottomNavigationBar(currentIndex: 1, selectedItemColor: AppColors.buyerBlue, unselectedItemColor: AppColors.textMuted, backgroundColor: AppColors.canvas, type: BottomNavigationBarType.fixed, onTap: (i) { if (i == 0) Navigator.pushReplacementNamed(context, '/collector'); if (i == 2) Navigator.pushNamed(context, '/idcard'); if (i == 3) Navigator.pushNamed(context, '/earnings'); if (i == 4) Navigator.pushNamed(context, '/collector_profile'); }, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'), BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'ID Card'), BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Earn'), BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')]),
    );
  }
}

class _Filt extends StatelessWidget { final String label; final bool active; const _Filt(this.label, this.active); @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: active ? AppColors.buyerBlue : AppColors.inputGrey, borderRadius: BorderRadius.circular(16)), child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.textSecondary))); }
class _Det extends StatelessWidget { final String val, label; const _Det(this.val, this.label); @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), if (label.isNotEmpty) Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary))]); }
