import 'package:flutter/material.dart';
import '../services/auth_state.dart';
import 'screens/login_screen.dart';
import 'screens/household/dashboard.dart';
import 'screens/household/sell_scrap.dart';
import 'screens/household/pickups.dart';
import 'screens/household/profile.dart';
import 'screens/collector/dashboard.dart';
import 'screens/collector/find_scrap.dart';
import 'screens/collector/id_card.dart';
import 'screens/collector/earnings.dart';
import 'screens/collector/route.dart';
import 'screens/collector/profile.dart';
import 'screens/admin_dashboard.dart';
import 'screens/user_management_screen.dart';
import 'screens/verify_collector_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/chat_collector_screen.dart';
import 'screens/role_picker_screen.dart';
import 'screens/household/register.dart';
import 'screens/collector/register.dart';
import 'screens/chat_screen.dart';
import 'screens/household/rate.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final route = settings.name ?? '/';

    // Route guard — redirect unauthorized roles to login
    if (!AuthState.instance.canAccess(route) && route != '/') {
      return _page(const LoginScreen());
    }

    switch (route) {
      case '/': return _page(const LoginScreen());
      case '/register': return _page(const RolePickerScreen());
      case '/register-household': return _page(const HouseholdRegisterScreen());
      case '/register-collector': return _page(const CollectorRegisterScreen());
      
      // Bottom Nav Routes (No animation to prevent Map hanging)
      case '/household': return _tab(const HouseholdDashboard());
      case '/collector': return _tab(const CollectorDashboard());
      case '/sell': return _tab(const SellScrapScreen());
      case '/pickups': return _tab(const MyPickupsScreen());
      case '/profile': return _tab(const HouseholdProfileScreen());
      case '/find': return _tab(const FindScrapScreen());
      case '/chat_collector': return _tab(const ChatCollectorScreen());
      case '/earnings': return _tab(const MyEarningsScreen());
      case '/collector_profile': return _tab(const CollectorProfileScreen());
      
      // Standard Routes
      case '/admin': return _page(const AdminDashboard());
      case '/idcard': return _page(const CollectorIDCard());
      case '/rate': return _page(const RateCollectorScreen());
      case '/route': return _page(const MyRouteScreen());
      case '/users': return _page(const UserManagementScreen());
      case '/verify': return _page(const VerifyCollectorScreen());
      case '/reports': return _page(const ReportsScreen());
      case '/analytics': return _page(const AnalyticsScreen());
      case '/chat': return _page(const ChatScreen());
      default: return _page(const LoginScreen());
    }
  }
  
  static MaterialPageRoute _page(Widget child) => MaterialPageRoute(builder: (_) => child);
  
  static PageRouteBuilder _tab(Widget child) => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}
