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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pickup Preferences',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 12),
          const Text('Set your default pickup preferences',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          // Default type
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.schedule_outlined, color: AppColors.textSecondary, size: 22),
              title: const Text('Default Pickup Type', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
              trailing: SwitchListTile(
                value: _asap,
                onChanged: (v) => setState(() => _asap = v),
                title: Text(_asap ? 'ASAP' : 'Scheduled',
                    style: TextStyle(fontSize: 12, color: _asap ? AppColors.sellerGreen : AppColors.textSecondary)),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          if (!_asap) ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.access_time, color: AppColors.textSecondary, size: 22),
                title: const Text('Preferred Time Window',
                    style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                trailing: SizedBox(
                  width: 200,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _timeWindow,
                      isDense: true,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.sellerGreen),
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
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _pushNotifications,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                  title: const Text('Push Notifications',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  subtitle: const Text('Receive alerts when a collector accepts your booking',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  value: _smsNotifications,
                  onChanged: (v) => setState(() => _smsNotifications = v),
                  title: const Text('SMS Notifications',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  subtitle: const Text('Receive text messages for booking updates',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Save', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
