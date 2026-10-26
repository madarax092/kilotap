import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/system_settings.dart';
import '../../services/system_settings_service.dart';

// Questions and answers for each role ('Household' | 'Collector' | 'Admin').
const Map<String, List<(String, String)>> _faqsByRole = {
  'Household': [
    ('How do I schedule a pickup?',
        'Go to the Sell Scrap tab, take a photo or add your items, enter their weight, pin your location, and choose ASAP or a scheduled date and time.'),
    ('Does KiloTap set the price?',
        'No. KiloTap matches you with a nearby collector and shows the estimated weight (kg) of your items. You and the collector agree on any price directly at pickup.'),
    ('How do I know who is coming?',
        'Open the pickup in My Pickups. Once a collector accepts, you see their photo, name, vehicle and plate number.'),
    ('Can I cancel a request?',
        'Yes. A pending request can be cancelled shortly after you send it, and an accepted pickup can be cancelled from My Pickups. The collector is notified.'),
    ('What if the collector doesn\'t arrive?',
        'Open the pickup in My Pickups and tap Report. An admin reviews every report.'),
  ],
  'Collector': [
    ('How do I get verified?',
        'Complete the Required Actions on your dashboard: a formal photo, a Valid ID, a vehicle photo and, for vehicles other than a pushcart, the plate number. A Barangay Clearance is optional and earns a "Barangay Cleared" badge.'),
    ('How do I accept a pickup request?',
        'Go online in Find Scrap, open a request near you and tap Accept. Make sure your vehicle can carry the estimated weight.'),
    ('How do I update my vehicle details?',
        'Go to Profile, then Vehicle Details, to update your vehicle type, capacity and plate number. A vehicle added after you are verified needs admin approval.'),
    ('Does KiloTap handle payment?',
        'No. KiloTap does not set prices or process payments. You and the household agree on any price directly at pickup, based on the weight measured on site.'),
    ('How do I report a problem with a household?',
        'On the navigation screen of a pickup, tap "Report a problem with this pickup".'),
  ],
  'Admin': [
    ('How do I verify a collector?',
        'Open Verify, choose a collector, tap each document to view it, then Approve or Reject. The Barangay Clearance is optional.'),
    ('How do I handle a report?',
        'Open Reports & Disputes. Mark it Investigating, then Resolve, Warn, Suspend or Dismiss. The reporter is told the outcome and every action is in the audit log.'),
    ('How do I suspend or close an account?',
        'Open User Management, tap the user, and choose Suspend or Close with a reason. Their open bookings are settled automatically. Reactivate lifts it.'),
    ('What can I change in System Settings?',
        'Dispatch timing, how long households can cancel a pending request, pausing new requests, the dashboard announcement and this support contact. Every change is recorded in the audit log.'),
  ],
};

class HelpSupportScreen extends StatelessWidget {
  final String role;
  const HelpSupportScreen({super.key, this.role = 'Household'});

  @override
  Widget build(BuildContext context) {
    final faqs = _faqsByRole[role] ?? _faqsByRole['Household']!;
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
          Text(
              role == 'Admin'
                  ? 'Guides for managing KiloTap.'
                  : 'Find answers to common questions or reach out to our team.',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),
          for (final (q, a) in faqs) ...[
            _FaqTile(question: q, answer: a),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 20),
          const Text('Contact Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          ValueListenableBuilder<SystemSettings>(
            valueListenable: SystemSettingsService.instance.current,
            builder: (context, s, _) {
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5)),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      _ContactRow(
                          icon: Icons.email_outlined,
                          title: 'Email Support',
                          subtitle: s.supportEmail,
                          uri: Uri(scheme: 'mailto', path: s.supportEmail)),
                      const Divider(height: 1, color: Color(0xFFE5E7EB)),
                      _ContactRow(
                          icon: Icons.phone_outlined,
                          title: 'Call Us',
                          subtitle: s.supportPhone,
                          uri: Uri(
                              scheme: 'tel',
                              path: s.supportPhone.replaceAll(' ', ''))),
                    ],
                  ),
                ),
              );
            },
          ),
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
  final Uri uri;
  const _ContactRow({required this.icon, required this.title, required this.subtitle, required this.uri});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      onTap: () => launchUrl(uri),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF111827), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
    );
  }
}
