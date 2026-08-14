import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PickupPrefsPage extends StatefulWidget {
  const PickupPrefsPage({super.key});

  @override
  State<PickupPrefsPage> createState() => _PickupPrefsPageState();
}

class _PickupPrefsPageState extends State<PickupPrefsPage> {
  bool _asap = true;
  String _timeWindow = 'Morning (8 AM - 12 PM)';
  bool _pushNotifications = true;
  bool _smsNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pickup Preferences',
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
          const Text('Set your default pickup preferences',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            child: SwitchListTile(
              secondary: const Icon(Icons.schedule_outlined, color: Color(0xFF9CA3AF), size: 22),
              title: const Text('Default Pickup Type',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              subtitle: Text(_asap ? 'ASAP' : 'Scheduled',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _asap ? AppColors.sellerGreen : const Color(0xFF6B7280))),
              value: _asap,
              activeColor: AppColors.sellerGreen,
              onChanged: (v) => setState(() => _asap = v),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),

          if (!_asap) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Color(0xFF9CA3AF), size: 22),
                title: const Text('Preferred Time Window',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                trailing: SizedBox(
                  width: 200,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _timeWindow,
                      isDense: true,
                      icon: const Icon(Icons.expand_more, color: Color(0xFF6B7280)),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.sellerGreen),
                      items: [
                        'Morning (8 AM - 12 PM)',
                        'Afternoon (12 PM - 5 PM)',
                        'Evening (5 PM - 8 PM)',
                      ].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => setState(() => _timeWindow = v!),
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ],

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  value: _pushNotifications,
                  activeColor: AppColors.sellerGreen,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                  title: const Text('Push Notifications',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                  subtitle: const Text('Receive alerts when a collector accepts',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE5E7EB)),
                SwitchListTile(
                  value: _smsNotifications,
                  activeColor: AppColors.sellerGreen,
                  onChanged: (v) => setState(() => _smsNotifications = v),
                  title: const Text('SMS Notifications',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                  subtitle: const Text('Receive text messages for updates',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Preferences updated successfully.'),
                  backgroundColor: AppColors.sellerGreen,
                ));
              },
              child: const Text('SAVE PREFERENCES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
