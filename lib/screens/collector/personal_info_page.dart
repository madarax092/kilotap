import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CollectorPersonalInfoPage extends StatefulWidget {
  const CollectorPersonalInfoPage({super.key});

  @override
  State<CollectorPersonalInfoPage> createState() => _CollectorPersonalInfoPageState();
}

class _CollectorPersonalInfoPageState extends State<CollectorPersonalInfoPage> {
  String _language = 'Bisaya';
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Personal Info',
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
          const Text('Update your personal information',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          _Field(label: 'Full Name', value: 'Juan Dela Cruz', editing: _editing),
          _Field(label: 'Phone Number', value: '+63927XXXXXXX', editing: _editing),
          _Field(label: 'Email', value: 'juan@email.com', editing: _editing),
          _Field(label: 'Address', value: 'Purok 5, Barangay Maa, Davao City', editing: _editing),
          const SizedBox(height: 10),
          // Language dropdown
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.language, color: AppColors.textSecondary, size: 22),
              title: const Text('Language', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
              trailing: SizedBox(
                width: 130,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _language,
                    isDense: true,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    items: ['Bisaya', 'Tagalog', 'English']
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (v) => setState(() => _language = v!),
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buyerBlue,
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

class _Field extends StatelessWidget {
  final String label, value;
  final bool editing;
  const _Field({required this.label, required this.value, required this.editing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
