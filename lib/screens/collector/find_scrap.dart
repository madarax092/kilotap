import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/pickup_request_card.dart';
import '../../widgets/collector_bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )ttom_nav.dart';

class FindScrapScreen extends StatefulWidget {
  const FindScrapScreen({super.key});
  @override
  State<FindScrapScreen> createState() => _FindScrapScreenState();
}

class _FindScrapScreenState extends State<FindScrapScreen> {
  bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )ol _accepted = false;
  bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )ol _isOnline = true;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )dy: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding:
                EdgeInsets.only(top: top + 16, left: 24, right: 24, bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )ttom: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )rder: Border(
                  bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )ttom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Find Scrap',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827))),
                    Row(
                      children: [
                        Text(
                          _isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _isOnline ? AppColors.buyerBlue : const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: _isOnline,
                          activeColor: AppColors.buyerBlue,
                          onChanged: (val) {
                            setState(() {
                              _isOnline = val;
                            });
                          },
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Discover and accept pickup requests near you',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              ],
            ),
          ),

          Expanded(
            child: ListView(
                padding: const EdgeInsets.only(top: 20, bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )ttom: 40),
                children: [
                  // Filter Chips
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: const [
                          _FilterChip('All', true),
                          _FilterChip('<1 km', false),
                          _FilterChip('<3 km', false),
                          _FilterChip('Small', false),
                          _FilterChip('Medium', false),
                          _FilterChip('Large', false),
                          _FilterChip('Heavy', false)
                        ])),
                  ),
                  const SizedBox(height: 20),

                  // Map Prototype Image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )rderRadius: BorderRadius.circular(16),
                          bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )rder: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/davao_map.png'),
                            fit: BoxFit.cover,
                          ),
                          bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )xShadow: const [
                            BoxShadow(
                                color: Color(0x06000000),
                                blurRadius: 10,
                                offset: Offset(0, 4))
                          ]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Request Card
                  if (!_accepted)
                    PickupRequestCard(
                      name: 'Maria Santos',
                      initials: 'MS',
                      location: 'Maa',
                      distance: '0.3 km',
                      quantity: '12 pcs',
                      material: 'Plastic',
                      volume: 'Medium',
                      weight: '15 kg',
                      note: 'Gate code #1234, ring bell',
                      onAccept: () {
                        setState(() => _accepted = true);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Pickup accepted! Starting navigation...'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ));
                        Navigator.pushNamed(context, '/route');
                      },
                      onDecline: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Pickup declined.'),
                          behavior: SnackBarBehavior.floating,
                        ));
                      },
                    ),
                ]),
          ),
        ],
      ),
      bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )ttomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )xShadow: [
            BoxShadow(
                color: Color(0x06000000), blurRadius: 8, offset: Offset(0, -2))
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: BottomNavigationBar(
              currentIndex: 1,
              onTap: (i) {
                if (i == 0)
                  Navigator.pushReplacementNamed(context, '/collector');
                if (i == 1) Navigator.pushReplacementNamed(context, '/find');
                if (i == 2)
                  Navigator.pushReplacementNamed(context, '/chat_collector');
                if (i == 3)
                  Navigator.pushReplacementNamed(context, '/earnings');
                if (i == 4)
                  Navigator.pushReplacementNamed(context, '/collector_profile');
              },
              selectedItemColor: AppColors.buyerBlue,
              unselectedItemColor: const Color(0xFFBBBBBB),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search_rounded), label: 'Find'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline_rounded),
                    label: 'Messages'),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.scale_rounded), label: 'Collections'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )ol active;

  const _FilterChip(this.label, this.active);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.buyerBlue : Colors.white,
          bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )rderRadius: BorderRadius.circular(20),
          bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )rder: active ? null : Border.all(color: const Color(0xFFE5E7EB)),
          bottomNavigationBar: CollectorBottomNav(
        currentIndex: 1,
        onTap: (i) => findNav(context, i),
      )xShadow: active
              ? [
                  BoxShadow(
                      color: AppColors.buyerBlue.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : const Color(0xFF6B7280))));
  }
}

class _Det extends StatelessWidget {
  final String val, label;
  const _Det(this.val, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(val,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827))),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280)))
    ]);
  }
}
