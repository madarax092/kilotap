import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../models/booking.dart';

class FindScrapScreen extends StatefulWidget {
  const FindScrapScreen({super.key});
  @override
  State<FindScrapScreen> createState() => _FindScrapScreenState();
}

class _FindScrapScreenState extends State<FindScrapScreen> {
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                EdgeInsets.only(top: top + 16, left: 24, right: 24, bottom: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
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
                            color: _isOnline
                                ? AppColors.buyerBlue
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: _isOnline,
                          activeThumbColor: AppColors.buyerBlue,
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
                padding: const EdgeInsets.only(top: 20, bottom: 40),
                children: [
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

                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: FirestoreService().availableBookingsDetailed(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.buyerBlue)),
                        );
                      }
                      final items = snapshot.data ?? [];
                      if (items.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(
                            child: Text('No pickup requests nearby',
                                style: TextStyle(
                                    color: AppColors.textSecondary)),
                          ),
                        );
                      }
                      return Column(
                        children: items.map((item) {
                          final b = item['booking'] as Booking;
                          return _RequestCard(
                            item['initials'],
                            item['sellerName'],
                            b.pickupAddress,
                            '—',
                            'Mixed',
                            '—',
                            'ASAP',
                            'assets/images/multiple_scrap_sample.png',
                            'assets/images/davao_nav_map.png',
                          );
                        }).toList(),
                      );
                    },
                  ),
                ]),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
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
                    icon: Icon(Icons.scale_rounded), label: 'Stats'),
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
  final bool active;

  const _FilterChip(this.label, this.active);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.buyerBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: active ? null : Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: AppColors.buyerBlue.withValues(alpha: 0.3),
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

class _RequestCard extends StatelessWidget {
  final String initials,
      name,
      location,
      pcs,
      material,
      weight,
      time,
      imagePath,
      mapPath;
  const _RequestCard(this.initials, this.name, this.location, this.pcs,
      this.material, this.weight, this.time, this.imagePath, this.mapPath);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/request_details', arguments: {
            'initials': initials,
            'name': name,
            'location': location,
            'pcs': pcs,
            'material': material,
            'weight': weight,
            'time': time,
            'imagePath': imagePath,
            'mapPath': mapPath,
          });
        },
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 4))
                ]),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                      child: Center(
                          child: Text(initials,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Color(0xFF111827))),
                        const SizedBox(height: 2),
                        Text(location,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(time,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _Det(pcs, material),
                const _Det('Medium', 'Volume'),
                _Det(weight, 'Est. Weight')
              ]),
            ])),
      ),
    );
  }
}
