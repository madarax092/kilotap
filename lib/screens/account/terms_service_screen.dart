import 'package:flutter/material.dart';

class TermsServiceScreen extends StatelessWidget {
  const TermsServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Terms of Service', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800, fontSize: 16)),
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
          const Text('Last updated: July 27, 2026', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Acceptance of Terms', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                SizedBox(height: 8),
                Text('By accessing and using KiloTap, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.', style: TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.5)),
                SizedBox(height: 24),
                
                Text('2. User Responsibilities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                SizedBox(height: 8),
                Text('Users must provide accurate information regarding the scrap materials being sold. Collectors must fulfill accepted pickups professionally and safely.', style: TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.5)),
                SizedBox(height: 24),
                
                Text('3. Pricing and Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                SizedBox(height: 8),
                Text('Prices shown on the app are estimates based on market value. Final payouts are determined at the time of pickup based on the actual measured weight.', style: TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.5)),
                SizedBox(height: 24),
                
                Text('4. Privacy Policy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                SizedBox(height: 8),
                Text('Your use of KiloTap is also governed by our Privacy Policy. We collect and process personal data in accordance with applicable laws.', style: TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.5)),
              ]
            ),
          )
        ],
      )
    );
  }
}
