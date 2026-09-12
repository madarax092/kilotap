import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_state.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _statusLabel(String status) {
    if (status.isEmpty) return 'Pending';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final docs = AuthState.instance.verificationDocs;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Verification Documents',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 12),
          const Text(
            'These documents are verified by the system administrator before you can receive bookings.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          if (docs.isEmpty)
            const Text('No verification documents on file yet.',
                style: TextStyle(color: AppColors.textSecondary))
          else
            ...docs.map((d) {
              final status = (d['status'] as String? ?? 'pending');
              return _DocCard(
                title: d['type'] as String? ?? 'Document',
                status: _statusLabel(status),
                statusColor: _statusColor(status),
              );
            }),
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 14, color: Colors.white),
        ),
        title: Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        subtitle: Text(status,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
