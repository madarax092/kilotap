import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class MyEarningsScreen extends StatelessWidget {
  const MyEarningsScreen({super.key});

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(automaticallyImplyLeading: false, 
        backgroundColor: AppColors.canvas, elevation: 0,
        title: const Text('My Earnings', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 28), children: [
        const SizedBox(height: 8),
        // Week cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _DayCard('Mon', '₱320', false),
            _DayCard('Tue', '₱450', false),
            _DayCard('Wed', '₱180', false),
            _DayCard('Thu', '₱450', true),
            _DayCard('Fri', '—', false),
          ]),
        ),
        const SizedBox(height: 12),
        // Weekly total
        const Center(child: Text.rich(TextSpan(children: [
          TextSpan(text: 'This Week: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          TextSpan(text: '₱1,400', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.buyerBlue)),
        ]))),
        const SizedBox(height: 20),
        // Monthly stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
          child: Column(children: [
            Row(children: [
              _StatBox('42', 'Pickups'),
              const SizedBox(width: 10),
              _StatBox('487 kg', 'Total Weight'),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _StatBox('₱1,250', 'Fuel Spent'),
              const SizedBox(width: 10),
              _StatBox('₱3,400', 'Est. Value'),
            ]),
          ]),
        ),
        const SizedBox(height: 24),
        // Transaction history
        const Text('RECENT TRANSACTIONS', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 8),
        _Txn('Jose R.', 'Scrap Iron 25kg', '₱180-₱250', 'Jun 30'),
        _Txn('Maria S.', 'Plastic 3.2kg', '₱20-₱30', 'Jun 30'),
        _Txn('Pedro L.', 'Mixed 12kg', '₱80-₱120', 'Jun 29'),
        _Txn('Ana L.', 'Cardboard 4kg', '₱20-₱30', 'Jun 28'),
        _Txn('Carlos M.', 'Metal 8kg', '₱120-₱180', 'Jun 27'),
        const SizedBox(height: 30),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/collector');
          if (i == 1) Navigator.pushNamed(context, '/find');
          if (i == 2) Navigator.pushNamed(context, '/idcard');
          if (i == 4) Navigator.pushNamed(context, '/collector_profile');
        },
        selectedItemColor: AppColors.buyerBlue, unselectedItemColor: AppColors.textMuted,
        backgroundColor: AppColors.canvas, type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'ID Card'),
          BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Earn'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final String day, value; final bool today;
  const _DayCard(this.day, this.value, this.today);
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 4),
    padding: const EdgeInsets.all(12),
    width: 58,
    decoration: BoxDecoration(
      color: today ? AppColors.buyerBlue.withOpacity(0.06) : AppColors.pureWhite,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: today ? AppColors.buyerBlue : AppColors.divider),
    ),
    child: Column(children: [
      Text(day, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: today ? AppColors.buyerBlue : AppColors.textPrimary)),
    ]),
  );
}

class _StatBox extends StatelessWidget {
  final String val, label;
  const _StatBox(this.val, this.label);
  @override Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
      ]),
    ),
  );
}

class _Txn extends StatelessWidget {
  final String name, detail, amount, date;
  const _Txn(this.name, this.detail, this.amount, this.date);
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(detail, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.buyerBlue)),
        Text(date, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
      ]),
    ]),
  );
}
