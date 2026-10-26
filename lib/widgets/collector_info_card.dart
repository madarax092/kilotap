import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/vehicle_verification.dart';
import '../core/verification_docs.dart';
import '../services/firestore_service.dart';
import 'full_screen_image_page.dart';

/// Who is coming for a household's pickup: the collector's formal photo,
/// name, vehicle and plate number, rating, and the Barangay Cleared badge
/// when they have one (paper 2.3: the household sees the matched
/// collector's verified profile photo).
class CollectorInfoCard extends StatelessWidget {
  final String collectorId;
  const CollectorInfoCard({super.key, required this.collectorId});

  Future<(Map<String, dynamic>?, Map<String, dynamic>?)> _load() async {
    final svc = FirestoreService();
    final results = await Future.wait(
        [svc.userAccount(collectorId), svc.collectorProfile(collectorId)]);
    return (results[0], results[1]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(Map<String, dynamic>?, Map<String, dynamic>?)>(
      future: _load(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(minHeight: 2),
          );
        }
        final (account, profile) = snap.data!;
        final name = (account?['Display_Name'] as String?) ?? 'Collector';
        final phone = (account?['Phone'] as String?) ?? '';
        final photo = (profile?['Profile_Photo_URL'] as String?) ?? '';
        final vehicle = (profile?['Vehicle_Type'] as String?) ?? '';
        final plate = plateNumberOf(profile, vehicle);
        final rating = ((profile?['Avg_Rating'] ?? 0) as num).toDouble();
        final cleared = hasBarangayClearance(profile);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('YOUR COLLECTOR',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
              const SizedBox(height: 12),
              Row(children: [
                GestureDetector(
                  onTap: photo.isEmpty
                      ? null
                      : () => showFullScreenImage(context,
                          title: name, url: photo),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.buyerBlue.withValues(alpha: 0.1),
                    backgroundImage:
                        photo.isEmpty ? null : NetworkImage(photo),
                    child: photo.isEmpty
                        ? const Icon(Icons.person,
                            color: AppColors.buyerBlue, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      if (rating > 0)
                        Text('Rating ${rating.toStringAsFixed(1)} / 5',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      if (cleared) ...[
                        const SizedBox(height: 4),
                        const _Badge(),
                      ],
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              _Row('Vehicle', vehicle.isEmpty ? 'Not set' : vehicle),
              if (vehicleNeedsPlate(vehicle))
                _Row('Plate Number', plate.isEmpty ? 'Not provided' : plate),
              if (phone.isNotEmpty) _Row('Mobile', phone),
            ],
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.verified_outlined, size: 14, color: AppColors.success),
        SizedBox(width: 4),
        Text('Barangay Cleared',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.success)),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ]),
    );
  }
}
