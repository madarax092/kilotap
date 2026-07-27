import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class MyEarningsScreen extends StatelessWidget {
  const MyEarningsScreen({super.key});

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
                    const Text('My Earnings',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827))),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.account_balance_wallet_outlined,
                          color: Color(0xFF4B5563), size: 22),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Track your daily income and statistics',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              children: [
                // Week cards
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: const [
                    _DayCard('Mon', '₱320', false),
                    _DayCard('Tue', '₱450', false),
                    _DayCard('Wed', '₱180', false),
                    _DayCard('Thu', '₱450', true),
                    _DayCard('Fri', '—', false),
                    _DayCard('Sat', '—', false),
                  ]),
                ),
                const SizedBox(height: 24),

                // Weekly total Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.buyerBlue,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.buyerBlue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total This Week',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFE1F5FE),
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: const [
                                Text('₱',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                Text('1,400',
                                    style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                                Text('.00',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: const [
                              Icon(Icons.trending_up,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text('+12%',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Monthly stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 8,
                              offset: Offset(0, 4))
                        ]),
                    child: Column(children: [
                      Row(children: const [
                        _StatBox('42', 'Pickups Completed',
                            Icons.local_shipping_outlined),
                        SizedBox(width: 12),
                        _StatBox('487 kg', 'Total Weight Collected',
                            Icons.scale_outlined),
                      ]),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                            color: Color(0xFFF3F4F6),
                            thickness: 1.5,
                            height: 1),
                      ),
                      Row(children: const [
                        _StatBox('₱1,250', 'Est. Fuel Spent',
                            Icons.local_gas_station_outlined),
                        SizedBox(width: 12),
                        _StatBox('₱3,400', 'Material Value',
                            Icons.inventory_2_outlined),
                      ]),
                    ]),
                  ),
                ),
                const SizedBox(height: 32),

                // Transaction history
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('RECENT TRANSACTIONS',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2)),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: const [
                      _Txn(
                          'Jose R.', 'Scrap Iron 25kg', '₱250', 'Jun 30', true),
                      _Txn('Maria S.', 'Plastic 3.2kg', '₱30', 'Jun 30', true),
                      _Txn('Pedro L.', 'Mixed 12kg', '₱120', 'Jun 29', true),
                      _Txn('Ana L.', 'Cardboard 4kg', '₱30', 'Jun 28', true),
                      _Txn('Carlos M.', 'Metal 8kg', '₱180', 'Jun 27', false),
                    ],
                  ),
                ),
              ],
            ),
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
              currentIndex: 3,
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

class _DayCard extends StatelessWidget {
  final String day, value;
  final bool today;
  const _DayCard(this.day, this.value, this.today);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      width: 70,
      decoration: BoxDecoration(
        color: today ? AppColors.buyerBlue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: today ? null : Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: today
            ? [
                BoxShadow(
                    color: AppColors.buyerBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(day,
              style: TextStyle(
                  fontSize: 11,
                  color: today ? Colors.white70 : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: today ? Colors.white : const Color(0xFF111827))),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String val, label;
  final IconData icon;
  const _StatBox(this.val, this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
            const SizedBox(height: 10),
            Text(val,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827))),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _Txn extends StatelessWidget {
  final String name, detail, amount, date;
  final bool isLatest;
  const _Txn(this.name, this.detail, this.amount, this.date, this.isLatest);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x04000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: const Icon(Icons.payments_outlined,
                color: Color(0xFF6B7280), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(detail,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(amount,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.buyerBlue)),
            const SizedBox(height: 2),
            Text(date,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500)),
          ]),
        ],
      ),
    );
  }
}
