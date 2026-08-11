import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

import '../../widgets/admin_bottom_nav.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding:
                EdgeInsets.only(top: top + 16, left: 24, right: 24, bottom: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reports & Disputes',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827))),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.close,
                            color: Color(0xFF6B7280), size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Manage user complaints and disputes',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                _RCard(
                    '#RPT-0018',
                    'INVESTIGATE',
                    AppColors.warning,
                    'Collector No-Show',
                    const [
                      'Reported by: Maria S. (Household)',
                      'Against: Juan D. (Collector)',
                      'Pickup: #PKP-0035 · June 29, 2026',
                      'Reason: Collector did not arrive within scheduled window'
                    ],
                    response:
                        'Collector response: "Traffic po, nag-message ako sa household"',
                    actions: const [
                      _Act('RESOLVE', AppColors.success, true),
                      _Act('WARN', AppColors.warning, false),
                      _Act('SUSPEND', AppColors.error, false)
                    ]),
                _RCard('#RPT-0017', 'RESOLVED', AppColors.success,
                    'Wrong Items Collected', const [
                  'Reported by: Jose R. (Household)',
                  'Against: Pedro R. (Collector)',
                  'Pickup: #PKP-0032 · June 28, 2026'
                ]),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(current: 2),
    );
  }
}

class _RCard extends StatelessWidget {
  final String id, status, desc;
  final Color statusColor;
  final List<String> details;
  final String? response;
  final List<_Act>? actions;
  const _RCard(this.id, this.status, this.statusColor, this.desc, this.details,
      {this.response, this.actions});
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(id,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error)),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(status,
                          style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: statusColor)))
                ])),
        const Divider(height: 1),
        Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(desc,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              ...details.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(d,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)))),
              if (response != null) ...[
                const SizedBox(height: 8),
                Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(response!,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic)))
              ],
              if (actions != null) ...[
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                    children: actions!
                        .map((a) => Expanded(
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: a.primary
                                            ? a.color
                                            : a.color.withOpacity(0.08),
                                        foregroundColor:
                                            a.primary ? Colors.white : a.color,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    onPressed: () {},
                                    child: Text(a.label,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700))))))
                        .toList())
              ]
            ]))
      ]));
}

class _Act {
  final String label;
  final Color color;
  final bool primary;
  const _Act(this.label, this.color, this.primary);
}
