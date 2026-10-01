import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AdminBottomNav extends StatelessWidget {
  final int current;
  const AdminBottomNav({super.key, required this.current});

  @override
  Widget build(BuildContext c) => Container(
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Color(0x06000000), blurRadius: 8, offset: Offset(0, -2))
        ]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: BottomNavigationBar(
              currentIndex: current,
              selectedItemColor: AppColors.adminRed,
              unselectedItemColor: const Color(0xFFBBBBBB),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              onTap: (i) {
                if (i == 0 && current != 0) {
                  Navigator.pushReplacementNamed(c, '/admin');
                }
                if (i == 1 && current != 1) {
                  Navigator.pushReplacementNamed(c, '/verify');
                }
                if (i == 2 && current != 2) {
                  Navigator.pushReplacementNamed(c, '/reports');
                }
                if (i == 3 && current != 3) {
                  Navigator.pushReplacementNamed(c, '/audit');
                }
                if (i == 4 && current != 4) {
                  Navigator.pushReplacementNamed(c, '/admin_profile');
                }
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.verified_user_rounded), label: 'Verify'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.report_problem_rounded), label: 'Reports'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.security_rounded), label: 'Audit'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded), label: 'Profile')
              ],
            ),
          ),
        ),
      );
}
