import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class MyPickupsScreen extends StatelessWidget {
  const MyPickupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(automaticallyImplyLeading: false, 
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: const Text('My Pickups', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        children: [
          const SizedBox(height: 4),
          // Filter tabs
          Row(children: [
            _FilterChip('Active (2)', active: true),
            const SizedBox(width: 8),
            _FilterChip('Completed (14)'),
            const SizedBox(width: 8),
            _FilterChip('Cancelled'),
          ]),
          const SizedBox(height: 16),
          // Pickup cards
          _PickupCard(
            id: '#PKP-0042',
            status: 'ON THE WAY',
            statusColor: AppColors.buyerBlue,
            initials: 'JD',
            name: 'Juan Dela Cruz',
            items: 'Plastic 12 pcs (S), Cardboard 3 pcs (M) · Tricycle',
            meta: 'ETA 5 min',
            stars: '\u2605 4.8',
            actions: [
              ('Track', AppColors.sellerGreen, Colors.white),
              ('Chat', AppColors.inputGrey, AppColors.textPrimary),
            ],
          ),
          _PickupCard(
            id: '#PKP-0041',
            status: 'CONFIRMED',
            statusColor: AppColors.buyerBlue,
            initials: 'MS',
            name: 'Maria Santos',
            items: 'Metal 5 pcs (L), Appliance 1 pc (H) · Multicab',
            meta: 'Tomorrow 9-12PM',
            stars: '\u2605 4.9',
            actions: [
              ('Chat', AppColors.inputGrey, AppColors.textPrimary),
              ('Reschedule', AppColors.inputGrey, AppColors.textPrimary),
            ],
          ),
          _PickupCard(
            id: '#PKP-0040',
            status: 'COMPLETED',
            statusColor: AppColors.success,
            initials: 'PR',
            name: 'Pedro Reyes',
            items: 'Plastic Bottles (S) 5.2 kg',
            meta: 'June 28, 2026',
            stars: '\u2605 4.5',
            actions: [
              ('Rate Collector', AppColors.sellerGreen, Colors.white),
              ('Report', AppColors.error.withOpacity(0.05), AppColors.error),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: AppColors.sellerGreen,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor: AppColors.canvas,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/household');
          if (i == 1) Navigator.pushNamed(context, '/sell');
          if (i == 3) Navigator.pushNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Sell'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Pickups'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  const _FilterChip(this.label, {this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.sellerGreen : AppColors.inputGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.textSecondary),
      ),
    );
  }
}

class _PickupCard extends StatelessWidget {
  final String id, status, initials, name, items, meta, stars;
  final Color statusColor;
  final List<(String, Color, Color)> actions;

  const _PickupCard({
    required this.id,
    required this.status,
    required this.statusColor,
    required this.initials,
    required this.name,
    required this.items,
    required this.meta,
    required this.stars,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Body
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: AppColors.buyerBlue, shape: BoxShape.circle),
                child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                    Text(items, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(meta, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              Text(stars, style: const TextStyle(color: AppColors.star, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 4),
          // Actions
          Row(
            children: actions.map((a) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: a.$2,
                    foregroundColor: a.$3,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {},
                  child: Text(a.$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
