import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_state.dart';

class CollectorDashboard extends StatelessWidget {
  const CollectorDashboard({super.key});

  static const _davaoCenter = LatLng(7.0712, 125.6089);

  @override Widget build(BuildContext context) {
    final markers = {
      Marker(markerId: MarkerId('you'), position: _davaoCenter, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), infoWindow: InfoWindow(title: 'You')),
      Marker(markerId: MarkerId('p1'), position: LatLng(7.0735, 125.6110), infoWindow: InfoWindow(title: 'Plastic 12 pcs (Small)'), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)),
      Marker(markerId: MarkerId('p2'), position: LatLng(7.0695, 125.6105), infoWindow: InfoWindow(title: 'Metal 5 pcs (Large)'), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
    };
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(automaticallyImplyLeading: false, 
        backgroundColor: AppColors.canvas, elevation: 0,
        title: const Text('Kumusta, Juan', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: const Text('✓ VERIFIED', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 28), children: [
        const Text('Tricycle Operator · ★ 4.8 (42 ratings)', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),
        // Stat cards
        Row(children: [
          _StatCard(label: 'Today', value: '3', color: AppColors.textPrimary),
          const SizedBox(width: 10),
          _StatCard(label: 'Pending', value: '7', color: AppColors.textPrimary),
          const SizedBox(width: 10),
          _StatCard(label: 'Earnings', value: '₱450', color: AppColors.buyerBlue),
        ]),
        const SizedBox(height: 12),
        // Verification banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.warning.withOpacity(0.3))),
          child: Row(children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
            const SizedBox(width: 10),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Account Pending Verification', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.warning)),
              SizedBox(height: 2),
              Text('Submit documents in your Profile to start receiving pickup notifications.', style: TextStyle(fontSize: 11, color: AppColors.warning)),
            ])),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/collector_profile'),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(8)), child: const Text('Verify', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        // Map area
        Container(
          height: 200,
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
          clipBehavior: Clip.antiAlias,
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(target: _davaoCenter, zoom: 14.5),
            markers: markers,
            zoomControlsEnabled: false,
          ),
        ),
        const SizedBox(height: 20),
        // Nearby requests
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Nearby Requests', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          TextButton(onPressed: () {}, child: const Text('See all →', style: TextStyle(color: AppColors.buyerBlue, fontWeight: FontWeight.w600))),
        ]),
        _RequestCard(name: 'Maria Santos', area: 'Maa · 0.3 km', items: 'Plastic 12 pcs (Small), Cardboard 3 pcs (Medium)', type: 'ASAP', urgent: true),
        _RequestCard(name: 'Jose Ramirez', area: 'Matina · 1.1 km', items: 'Metal 5 pcs (Large) ~25 kg', type: 'Tomorrow 9AM', urgent: false),
        const SizedBox(height: 40),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.buyerBlue,
        onPressed: () => Navigator.pushNamed(context, '/idcard'),
        child: const Icon(Icons.credit_card, color: Colors.white),
      ),
      bottomNavigationBar: _BottomNav(current: 0),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value; final Color color;
  const _StatCard({required this.label, required this.value, required this.color});
  @override Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 0.5)),
        ]),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String name, area, items, type; final bool urgent;
  const _RequestCard({required this.name, required this.area, required this.items, required this.type, required this.urgent});
  @override Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
          Text(area, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 4),
        Text(items, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: urgent ? AppColors.error.withOpacity(0.1) : AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: urgent ? AppColors.error : AppColors.warning))),
          const Spacer(),
          if (AuthState.instance.hasPermission('accept_pickup')) ...[
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.buyerBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('ACCEPT', style: TextStyle(fontSize: 11))),
            const SizedBox(width: 8),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.inputGrey, foregroundColor: AppColors.textPrimary, padding: const EdgeInsets.symmetric(horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('DECLINE', style: TextStyle(fontSize: 11))),
          ] else
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.inputGrey, foregroundColor: AppColors.warning, padding: const EdgeInsets.symmetric(horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pushNamed(context, '/collector_profile'),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.lock, size: 14), SizedBox(width: 4), Text('Verify to accept', style: TextStyle(fontSize: 11))]),
            ),
        ]),
      ]),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current;
  const _BottomNav({required this.current});
  @override Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: current, selectedItemColor: AppColors.buyerBlue, unselectedItemColor: AppColors.textMuted,
      backgroundColor: AppColors.canvas, type: BottomNavigationBarType.fixed,
      onTap: (i) {
        if (i == 1) Navigator.pushNamed(context, '/find');
        if (i == 2) Navigator.pushNamed(context, '/idcard');
        if (i == 3) Navigator.pushNamed(context, '/earnings');
        if (i == 4) Navigator.pushNamed(context, '/collector_profile');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'),
        BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'ID Card'),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Earn'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
