import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_state.dart';

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
    final auth = AuthState.instance;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Personal Information',
            style: TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w800,
                fontSize: 16)),
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
          _Field(
              label: 'Full Name',
              value: auth.displayName.isEmpty ? 'Full Name' : auth.displayName,
              focusColor: AppColors.sellerGreen),
          _Field(
              label: 'Phone Number',
              value: auth.phone.isEmpty ? '+63' : auth.phone,
              focusColor: AppColors.sellerGreen),
          _Field(
              label: 'Email',
              value: auth.email.isEmpty ? 'email@example.com' : auth.email,
              focusColor: AppColors.sellerGreen),
          _Field(
              label: 'Address',
              value: auth.address.isEmpty ? 'Address' : auth.address,
              focusColor: AppColors.sellerGreen),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.language,
                    color: Color(0xFF9CA3AF), size: 22),
                const SizedBox(width: 12),
                const Text('Language',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563))),
                const Spacer(),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _language,
                    isDense: true,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827)),
                    icon: const Icon(Icons.expand_more,
                        color: Color(0xFF6B7280)),
                    items: ['Bisaya', 'Tagalog', 'English']
                        .map((l) =>
                            DropdownMenuItem(value: l, child: Text(l)))
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
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
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
  const _Field(
      {required this.label, required this.value, required this.focusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563))),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827)),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB), width: 1.5)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB), width: 1.5)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: focusColor, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}
