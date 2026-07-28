import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FindScrapScreen extends StatefulWidget {
  const FindScrapScreen({super.key});
  @override
  State<FindScrapScreen> createState() => _FindScrapScreenState();
}

class _FindScrapScreenState extends State<FindScrapScreen> {
  bool _accepted = false;
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header
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
                padding: const EdgeInsets.only(top: 20, bottom: 40),
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
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/davao_map.png'),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: const [
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle),
                                        child: const Center(
                                            child: Text('MS',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14)))),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text('Maria Santos',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15,
                                                  color: Color(0xFF111827))),
                                          SizedBox(height: 2),
                                          Text('Maa · 0.3 km away',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF6B7280))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color:
                                              AppColors.error.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Text('ASAP',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.error)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: const [
                                      _Det('12 pcs', 'Plastic'),
                                      _Det('Medium', 'Volume'),
                                      _Det('15 kg', 'Est. Weight')
                                    ]),
                                const SizedBox(height: 16),
                                Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.info_outline,
                                            size: 16, color: Color(0xFF6B7280)),
                                        SizedBox(width: 8),
                                        Expanded(
                                            child: Text(
                                                '"Gate code #1234, ring bell"',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF4B5563),
                                                    fontStyle:
                                                        FontStyle.italic))),
                                      ],
                                    )),
                                const SizedBox(height: 16),
                                Row(children: [
                                  Expanded(
                                      child: ElevatedButton.icon(
                                          icon:
                                              const Icon(Icons.check, size: 18),
                                          label: const Text('Accept',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.buyerBlue,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                content: Text('Pickup accepted! Starting navigation...'),
                                                backgroundColor: AppColors.success,
                                                behavior: SnackBarBehavior.floating,
                                            ));
                                            Navigator.pushReplacementNamed(context, '/collector');
                                          },
                                      )),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: OutlinedButton.icon(
                                          icon:
                                              const Icon(Icons.close, size: 18),
                                          label: const Text('Decline',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  const Color(0xFF2C2C2C),
                                              side: const BorderSide(
                                                  color: Color(0xFFE5E7EB)),
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          onPressed: () =>
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text('Request declined'))))),
                                ]),
                              ])),
                    ),

                  if (_accepted)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.success.withOpacity(0.3))),
                          child: Row(children: const [
                            Icon(Icons.check_circle,
                                color: AppColors.success, size: 24),
                            SizedBox(width: 12),
                            Expanded(
                                child: Text(
                                    'Pickup accepted! Navigation started. ETA: 5 min',
                                    style: TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)))
                          ])),
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
                    icon: Icon(Icons.payments_rounded), label: 'Earn'),
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
