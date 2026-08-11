import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HouseholdPersonalInfoPage extends StatefulWidget {
  const HouseholdPersonalInfoPage({super.key});

  @override
  State<HouseholdPersonalInfoPage> createState() =>
      _HouseholdPersonalInfoPageState();
}

class _HouseholdPersonalInfoPageState extends State<HouseholdPersonalInfoPage> {
  String _language = 'Bisaya';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Personal Information',
            style: TextStyle(
                color: Color(0xFF111827), fontWeight: FontWeight.w800, fontSize: 16)),
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
          const Text('Update your personal information',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),
          const _Field(label: 'Full Name', value: 'Maria Santos', focusColor: AppColors.sellerGreen),
          const _Field(label: 'Phone Number', value: '+63917XXXXXXX', focusColor: AppColors.sellerGreen),
          const _Field(label: 'Email', value: 'maria@email.com', focusColor: AppColors.sellerGreen),
          const _Field(
              label: 'Address',
              value: 'Block 5, Lot 12, Barangay Maa, Davao City', focusColor: AppColors.sellerGreen),
          const SizedBox(height: 8),
          // Housing Type dropdown
          const _HousingTypeDropdown(),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.language, color: Color(0xFF9CA3AF), size: 22),
                const SizedBox(width: 12),
                const Text('Language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                const Spacer(),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _language,
                    isDense: true,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                    icon: const Icon(Icons.expand_more, color: Color(0xFF6B7280)),
                    items: ['Bisaya', 'Tagalog', 'English']
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (v) => setState(() => _language = v!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Profile updated successfully.'),
                  backgroundColor: AppColors.sellerGreen,
                ));
              },
              child: const Text('SAVE CHANGES',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HousingTypeDropdown extends StatefulWidget {
  const _HousingTypeDropdown();

  @override
  State<_HousingTypeDropdown> createState() => _HousingTypeDropdownState();
}

class _HousingTypeDropdownState extends State<_HousingTypeDropdown> {
  String _housingType = 'Single-Detached House';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.home_outlined, color: Color(0xFF9CA3AF), size: 22),
          const SizedBox(width: 12),
          const Text('Housing Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
          const Spacer(),
          SizedBox(
            width: 200,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _housingType,
                isDense: true,
                isExpanded: true,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
              icon: const Icon(Icons.expand_more, color: Color(0xFF6B7280)),
              items: const [
                DropdownMenuItem(value: 'Apartment', child: Text('Apartment')),
                DropdownMenuItem(value: 'Boarding House / Dormitory', child: Text('Boarding House / Dormitory')),
                DropdownMenuItem(value: 'Duplex', child: Text('Duplex')),
                DropdownMenuItem(value: 'Single-Attached House', child: Text('Single-Attached House')),
                DropdownMenuItem(value: 'Single-Detached House', child: Text('Single-Detached House')),
                DropdownMenuItem(value: 'Townhouse / Rowhouse', child: Text('Townhouse / Rowhouse')),
              ],
              onChanged: (v) => setState(() => _housingType = v!),
            ),
          ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label, value;
  final Color focusColor;
  const _Field({required this.label, required this.value, required this.focusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4B5563))),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: focusColor, width: 1.5)),
            ),
          ),
        ],
      )
    );
  }
}
