import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/admin_bottom_nav.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: top + 16, left: 24, right: 24, bottom: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827)
                  )
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                // Stat cards Row 1
                Row(
                  children: [
                    _Stat(
                      val: '342',
                      label: 'Total Users',
                      color: const Color(0xFF111827),
                      icon: Icons.people_outline,
                      onTap: () => Navigator.pushNamed(context, '/users')
                    ),
                    const SizedBox(width: 12),
                    _Stat(
                      val: '18',
                      label: 'Active Pickups',
                      color: const Color(0xFF111827),
                      icon: Icons.local_shipping_outlined,
                    ),
                  ]
                ),
                const SizedBox(height: 12),
                
                // Stat cards Row 2
                Row(
                  children: [
                    _Stat(
                      val: '47',
                      label: 'Pickups Today',
                      color: const Color(0xFF111827),
                      icon: Icons.today_outlined,
                    ),
                    const SizedBox(width: 12),
                    _Stat(
                      val: '5',
                      label: 'Pending Verify',
                      color: AppColors.adminRed,
                      icon: Icons.verified_user_outlined,
                      onTap: () => Navigator.pushNamed(context, '/verify')
                    ),
                  ]
                ),
                
                const SizedBox(height: 32),
                
                // Last 7 Days Analytics
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                    boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4))]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LAST 7 DAYS',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2
                        )
                      ),
                      const SizedBox(height: 20),
                      const _Bar('Pickups', 47, 50, '47/day', AppColors.buyerBlue),
                      const _Bar('New Users', 12, 30, '12/day', AppColors.buyerBlue),
                      const _Bar('Reports', 3, 20, '3/week', AppColors.buyerBlue),
                      const _Bar('Avg Rating', 4.6, 5.0, '4.6 ★', AppColors.star),
                    ]
                  )
                ),
                
                const SizedBox(height: 32),
                
                // Pending Verifications
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                    boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4))]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'PENDING VERIFICATIONS',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2
                            )
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: const BoxDecoration(
                              color: AppColors.adminRed,
                              shape: BoxShape.circle
                            ),
                            child: const Text(
                              '5',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)
                            )
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/verify'),
                            child: const Text(
                              'View all →',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.buyerBlue)
                            )
                          )
                        ]
                      ),
                      const SizedBox(height: 20),
                      const _VerifyCard('Pedro Reyes', 'Tricycle · Barangay Maa', '2h ago'),
                      const Divider(height: 24, color: Color(0xFFF3F4F6)),
                      const _VerifyCard('Ana Lopez', 'Kariton · Barangay Ecoland', '5h ago'),
                    ]
                  )
                ),
                
                const SizedBox(height: 24),
                
                // User Complaints
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                    boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4))]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'USER COMPLAINTS',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2
                            )
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/reports'),
                            child: const Text(
                              'View all →',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.buyerBlue)
                            )
                          )
                        ]
                      ),
                      const SizedBox(height: 20),
                      const _ReportCard('#RPT-0018', 'Investigate', AppColors.warning, 'Collector no-show for #PKP-0035', 'Maria S. · June 29'),
                      const Divider(height: 24, color: Color(0xFFF3F4F6)),
                      const _ReportCard('#RPT-0017', 'Resolved', AppColors.success, 'Wrong items collected', 'Jose R. · June 28'),
                    ]
                  )
                ),
                
                const SizedBox(height: 40),
              ]
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(current: 0),
    );
  }
}

class _Stat extends StatelessWidget {
  final String val, label;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _Stat({
    required this.val,
    required this.label,
    required this.color,
    required this.icon,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4))]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    val,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: color,
                      height: 1
                    )
                  ),
                  Icon(icon, color: color.withOpacity(0.5), size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600
                )
              )
            ]
          )
        )
      )
    );
  }
}

class _Bar extends StatelessWidget {
  final String label, right;
  final double val, max;
  final Color color;
  
  const _Bar(this.label, this.val, this.max, this.right, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827)
                )
              ),
              Text(
                right,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color
                )
              )
            ]
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: val / max,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10
            )
          )
        ]
      )
    );
  }
}

class _VerifyCard extends StatelessWidget {
  final String name, detail, time;
  const _VerifyCard(this.name, this.detail, this.time);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Color(0xFF111827)
                      )
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600
                      )
                    )
                  ]
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280)
                  )
                )
              ]
            )
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () {},
            child: const Icon(Icons.check, size: 18)
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEF2F2),
              foregroundColor: AppColors.error,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () {},
            child: const Icon(Icons.close, size: 18)
          ),
        ]
      )
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String id, status, issue, detail;
  final Color color;
  
  const _ReportCard(this.id, this.status, this.color, this.issue, this.detail);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                id,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color
                )
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.5
                  )
                )
              )
            ]
          ),
          const SizedBox(height: 12),
          Text(
            issue,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827)
            )
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280)
            )
          ),
        ]
      )
    );
  }
}

