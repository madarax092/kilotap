import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class HouseholdDashboard extends StatelessWidget {
  const HouseholdDashboard({super.key});

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas, elevation: 0,
        title: const Text('Kumusta, Maria', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 42, height: 42,
            decoration: const BoxDecoration(color: AppColors.sellerGreen, shape: BoxShape.circle),
            child: const Center(child: Text('MS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 28), children: [
        const Text('Barangay Maa, Davao City', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),
        // Stat cards
        Row(children: [
          _StatCard(label: 'Pending', value: '2', accent: false),
          const SizedBox(width: 12),
          _StatCard(label: 'Completed', value: '14', accent: true),
        ]),
        const SizedBox(height: 20),
        // Active pickup
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.sellerGreen.withOpacity(0.2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('● ACTIVE PICKUP', style: TextStyle(fontSize: 10, color: AppColors.sellerGreen, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 10),
            Row(children: [
              Container(width: 44, height: 44, decoration: const BoxDecoration(color: AppColors.buyerBlue, shape: BoxShape.circle), child: const Center(child: Text('JD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Juan Dela Cruz', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                Text('Tricycle · #PKP-0042', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              const Text('★ 4.8', style: TextStyle(color: AppColors.star, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              const Text('On the way', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              const Text('ETA 5 min', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.sellerGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () {}, child: const Text('Track'))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.inputGrey, foregroundColor: AppColors.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () {}, child: const Text('Chat'))),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        // Nearby collectors
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Nearby Collectors', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          TextButton(onPressed: () {}, child: const Text('See all →', style: TextStyle(color: AppColors.sellerGreen, fontWeight: FontWeight.w600))),
        ]),
        _CollectorRow(name: 'Pedro Reyes', dist: '0.8 km', vehicle: 'Multicab', rating: '4.5'),
        _CollectorRow(name: 'Maria Santos', dist: '1.2 km', vehicle: 'Tricycle', rating: '4.9'),
        const SizedBox(height: 40),
      ]),
      bottomNavigationBar: _BottomNav(current: 0, color: AppColors.sellerGreen),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value; final bool accent;
  const _StatCard({required this.label, required this.value, required this.accent});
  @override Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 0.5)),
        ]),
      ),
    );
  }
}

class _CollectorRow extends StatelessWidget {
  final String name, dist, vehicle, rating;
  const _CollectorRow({required this.name, required this.dist, required this.vehicle, required this.rating});
  @override Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: const BoxDecoration(color: AppColors.buyerBlue, shape: BoxShape.circle), child: Center(child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
          Text('$dist · $vehicle', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        Text('★ $rating', style: const TextStyle(color: AppColors.star, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current; final Color color;
  const _BottomNav({required this.current, required this.color});
  @override Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: current,
      selectedItemColor: color,
      unselectedItemColor: AppColors.textMuted,
      backgroundColor: AppColors.canvas,
      type: BottomNavigationBarType.fixed,
      onTap: (i) {
        if (i == 1) Navigator.pushNamed(context, '/sell');
        if (i == 2) Navigator.pushNamed(context, '/bookings');
        if (i == 3) Navigator.pushNamed(context, '/profile');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Sell'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Pickups'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
