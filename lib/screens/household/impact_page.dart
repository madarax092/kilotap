import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ImpactPage extends StatelessWidget {
  const ImpactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Recycling Impact',
            style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800, fontSize: 16)),
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
          const Text('Your contribution to the environment',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                  boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: const Column(children: [
                  Icon(Icons.eco, color: AppColors.sellerGreen, size: 32),
                  SizedBox(height: 12),
                  Text('6', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  SizedBox(height: 4),
                  Text('Trees Saved', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                ]),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                  boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: const Column(children: [
                  Icon(Icons.recycling, color: AppColors.sellerGreen, size: 32),
                  SizedBox(height: 12),
                  Text('245.7', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  SizedBox(height: 4),
                  Text('Kg Recycled', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                  boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: const Column(children: [
                  Icon(Icons.local_shipping, color: AppColors.sellerGreen, size: 32),
                  SizedBox(height: 12),
                  Text('16', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  SizedBox(height: 4),
                  Text('Total Pickups', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                ]),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                  boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: const Column(children: [
                  Icon(Icons.cloud, color: AppColors.sellerGreen, size: 32),
                  SizedBox(height: 12),
                  Text('42', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  SizedBox(height: 4),
                  Text('Kg CO2 Saved', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          const Text('How This Is Calculated',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              _InfoRow('Trees Saved', 'Based on the formula: 45 kg of recycled material prevents the cutting of one mature tree.'),
              SizedBox(height: 16),
              _InfoRow('CO2 Saved', 'Based on EPA estimates: each kg of recycled material saves approximately 0.17 kg of CO2 emissions compared to landfill disposal.'),
              SizedBox(height: 16),
              _InfoRow('Total Kg', 'Sum of estimated weights from all completed YOLOv8n-detected pickups.'),
            ]),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title, description;
  const _InfoRow(this.title, this.description);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
      const SizedBox(height: 4),
      Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
    ]);
  }
}
