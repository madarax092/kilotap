import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Verification Documents',
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
          const Text(
            'These documents are verified by the system administrator before you can receive bookings.',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          _DocCard(
            title: 'Valid Government ID',
            status: 'Verified',
            statusColor: AppColors.success,
          ),
          _DocCard(
            title: 'Vehicle Photo',
            status: 'Verified',
            statusColor: AppColors.success,
          ),
          _DocCard(
            title: 'Profile Photo Match',
            status: 'Verified',
            statusColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;

  const _DocCard({
    required this.title,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: ListTile(
        leading: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle, size: 20, color: statusColor),
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        subtitle: Text(status,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () {},
      ),
    );
  }
}
