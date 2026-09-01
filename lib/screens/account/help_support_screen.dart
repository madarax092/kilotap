import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  final bool isCollector;
  const HelpSupportScreen({super.key, this.isCollector = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Help & Support', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: const Color(0xFFE5E7EB), height: 1.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          const Text('How can we help you?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 8),
          const Text('Find answers to common questions or reach out to our team.', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),
          if (!isCollector) ...[
            const _FaqTile(question: 'How do I schedule a pickup?', answer: 'Go to the Sell Scrap tab, select the items you want to sell, estimate their weight, and choose either ASAP or a scheduled time window.'),
            const SizedBox(height: 12),
            const _FaqTile(question: 'How are prices calculated?', answer: 'Prices are determined by the real-time market value of the specific scrap material, multiplied by the estimated weight of your items.'),
            const SizedBox(height: 12),
            const _FaqTile(question: 'What if the collector doesn\'t arrive?', answer: 'You can report the issue from the My Pickups screen. Navigate to the completed/failed pickup and tap the Report button.'),
          ] else ...[
            const _FaqTile(question: 'How do I accept a pickup request?', answer: 'Go to the Find Scrap tab, view the available requests near you, and tap Accept. Make sure you can accommodate the estimated weight and volume.'),
            const SizedBox(height: 12),
            const _FaqTile(question: 'How do I update my vehicle details?', answer: 'Go to the Profile tab, tap on Vehicle Details, and update your vehicle type and plate number. This helps households identify you when you arrive.'),
            const SizedBox(height: 12),
            const _FaqTile(question: 'How do I get paid?', answer: 'Currently, payouts are handled in cash directly with the household or through integrated mobile wallets depending on your arrangement with the platform.'),
          ],
          const SizedBox(height: 32),
          const Text('Contact Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5)),
            child: const Column(
              children: [
                _ContactRow(icon: Icons.email_outlined, title: 'Email Support', subtitle: 'support@kilotap.com'),
                Divider(height: 24, color: Color(0xFFE5E7EB)),
                _ContactRow(icon: Icons.phone_outlined, title: 'Call Us', subtitle: '+63 917 123 4567'),
              ],
            )
          )
        ],
      )
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question, answer;
  const _FaqTile({required this.question, required this.answer});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        iconColor: const Color(0xFF111827),
        collapsedIconColor: const Color(0xFF6B7280),
        shape: const RoundedRectangleBorder(),
        children: [
          Text(answer, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.5)),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _ContactRow({required this.icon, required this.title, required this.subtitle});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFF111827), size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ],
        )
      ],
    );
  }
}
