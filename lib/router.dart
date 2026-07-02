import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'screens/login_screen.dart';
import 'screens/household_dashboard.dart';
import 'screens/collector_dashboard.dart';
import 'screens/collector_id_card.dart';
import 'screens/admin_dashboard.dart';
import 'screens/stubs.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _page(const LoginScreen());
      case '/register':
        return _page(stubScreen('Register', AppColors.sellerGreen, subtitle: 'Account registration'));
      case '/household':
        return _page(const HouseholdDashboard());
      case '/collector':
        return _page(const CollectorDashboard());
      case '/admin':
        return _page(const AdminDashboard());
      case '/sell':
        return _page(stubScreen('Sell Scrap', AppColors.sellerGreen, subtitle: 'Camera-only capture'));
      case '/bookings':
        return _page(stubScreen('My Bookings', AppColors.sellerGreen, subtitle: 'Pickup history'));
      case '/profile':
        return _page(stubScreen('My Profile', AppColors.sellerGreen, subtitle: 'Account settings'));
      case '/find':
        return _page(stubScreen('Find Scrap', AppColors.buyerBlue, subtitle: 'Map view with nearby requests'));
      case '/idcard':
        return _page(const CollectorIDCard());
      case '/earnings':
        return _page(stubScreen('My Earnings', AppColors.buyerBlue, subtitle: 'Revenue tracking'));
      case '/collector_profile':
        return _page(stubScreen('Collector Profile', AppColors.buyerBlue, subtitle: 'Verification & stats'));
      default:
        return _page(const LoginScreen());
    }
  }

  static MaterialPageRoute _page(Widget child) => MaterialPageRoute(builder: (_) => child);
}
