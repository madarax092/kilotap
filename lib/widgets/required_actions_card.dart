import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/vehicle_verification.dart';
import '../core/verification_docs.dart';
import '../screens/collector/documents_page.dart';
import '../screens/collector/vehicle_details_page.dart';
import '../services/auth_state.dart';

/// The collector's Required Actions: what is still needed before an admin
/// can verify them. Formal photo, Valid ID, Vehicle Photo and the plate
/// number of every vehicle that has one are required; the Barangay
/// Clearance is optional. Hidden once verified with nothing missing.
class RequiredActionsCard extends StatefulWidget {
  const RequiredActionsCard({super.key});

  @override
  State<RequiredActionsCard> createState() => _RequiredActionsCardState();
}

class _RequiredActionsCardState extends State<RequiredActionsCard> {
  Future<void> _go(Widget? page, {String? route}) async {
    if (route != null) {
      await Navigator.pushNamed(context, route);
    } else if (page != null) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthState.instance;
    final docs = auth.verificationDocs;
    bool uploaded(String type) => isDocUploaded(verificationDocOf(docs, type));
    final platesDone = auth.vehicles.every((v) {
      final type = v['Vehicle_Type'] as String? ?? '';
      return !vehicleNeedsPlate(type) ||
          ((v['Plate_Number'] as String?) ?? '').trim().isNotEmpty;
    });

    final steps = <_Step>[
      _Step('Formal photo', 'A clear photo of your face, for your Digital ID',
          auth.profilePhotoUrl.isNotEmpty, () => _go(null, route: '/idcard')),
      _Step('Valid ID', 'Any government-issued ID', uploaded('Valid ID'),
          () => _go(const DocumentsPage())),
      _Step('Vehicle photo', 'A photo of the vehicle you use',
          uploaded('Vehicle Photo'), () => _go(const DocumentsPage())),
      _Step('Plate number', 'For a tricycle, multicab or truck', platesDone,
          () => _go(const VehicleDetailsPage())),
      _Step(
          'Barangay Clearance',
          'Optional. Earns a "Barangay Cleared" badge',
          uploaded(barangayClearanceDocType),
          () => _go(const DocumentsPage()),
          optional: true),
    ];
    final requiredLeft = steps.where((s) => !s.optional && !s.done).length;
    final verified = auth.verificationStatus == 'Verified';
    if (verified && requiredLeft == 0) return const SizedBox.shrink();

    final headline = requiredLeft > 0
        ? '$requiredLeft required step${requiredLeft == 1 ? '' : 's'} left'
        : 'Waiting for admin review';
    final color = requiredLeft > 0 ? AppColors.warning : AppColors.buyerBlue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withValues(alpha: 0.5), width: 1.5)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: color,
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                const Icon(Icons.assignment_outlined,
                    color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Required Actions',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      Text(headline,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ]),
            ),
            for (final s in steps)
              ListTile(
                dense: true,
                onTap: s.onTap,
                leading: Icon(
                    s.done ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: s.done ? AppColors.success : AppColors.textMuted),
                title: Text(s.optional ? '${s.title} (optional)' : s.title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: s.done
                            ? AppColors.textSecondary
                            : AppColors.textPrimary)),
                subtitle: Text(s.hint, style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

class _Step {
  final String title, hint;
  final bool done;
  final VoidCallback onTap;
  final bool optional;
  const _Step(this.title, this.hint, this.done, this.onTap,
      {this.optional = false});
}
