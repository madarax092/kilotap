import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'screens/login_screen.dart';
import 'screens/household_dashboard.dart';
import 'screens/sell_scrap_screen.dart';
import 'screens/my_pickups_screen.dart';
import 'screens/household_profile_screen.dart';
import 'screens/collector_dashboard.dart';
import 'screens/collector_id_card.dart';
import 'screens/my_earnings_screen.dart';
import 'screens/collector_profile_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/register_screen.dart';
import 'screens/remaining_screens.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/': return _page(const LoginScreen());
      case '/register': return _page(const RegisterScreen());
      case '/household': return _page(const HouseholdDashboard());
      case '/collector': return _page(const CollectorDashboard());
      case '/admin': return _page(const AdminDashboard());
      case '/sell': return _page(const SellScrapScreen());
      case '/pickups': return _page(const MyPickupsScreen());
      case '/rate': return _page(const RateCollectorScreen());
      case '/profile': return _page(const HouseholdProfileScreen());
      case '/find': return _page(const FindScrapScreen());
      case '/idcard': return _page(const CollectorIDCard());
      case '/route': return _page(const MyRouteScreen());
      case '/earnings': return _page(const MyEarningsScreen());
      case '/collector_profile': return _page(const CollectorProfileScreen());
      case '/users': return _page(const UserManagementScreen());
      case '/verify': return _page(const VerifyCollectorScreen(collectorId: ''));
      case '/reports': return _page(const ReportsScreen());
      case '/analytics': return _page(const AnalyticsScreen());
      case '/chat': return _page(const ChatScreen());
      default: return _page(const LoginScreen());
    }
  }
  static MaterialPageRoute _page(Widget child) => MaterialPageRoute(builder: (_) => child);
}
