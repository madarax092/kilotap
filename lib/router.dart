import 'package:flutter/material.dart';
import '../services/auth_state.dart';
import 'screens/account/login_screen.dart';
import 'screens/household/household_dashboard.dart';
import 'screens/household/sell_scrap_screen.dart';
import 'screens/household/my_pickups_screen.dart';
import 'screens/household/household_profile_screen.dart';
import 'screens/collector/collector_dashboard.dart';
import 'screens/collector/find_scrap_screen.dart';
import 'screens/collector/collector_id_card.dart';
import 'screens/collector/my_collection_screen.dart';
import 'screens/collector/my_route_screen.dart';
import 'screens/collector/collector_profile_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/user_management_screen.dart';
import 'screens/admin/verify_collector_screen.dart';
import 'screens/admin/audit_logs_screen.dart';
import 'screens/admin/admin_profile_screen.dart';
import 'screens/admin/reports_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/household/chat_collector_screen.dart';
import 'screens/household/detection_results_screen.dart';
import 'screens/account/role_picker_screen.dart';
import 'screens/account/household_register_screen.dart';
import 'screens/account/collector_register_screen.dart';
import 'screens/collector/chat_screen.dart';
import 'screens/household/rate_collector_screen.dart';
import 'screens/collector/collector_navigation_screen.dart';
import 'screens/collector/request_details_screen.dart';

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
      case '/earnings': return _tab(const MyCollectionScreen());
      case '/collector_profile': return _tab(const CollectorProfileScreen());
      
      // Standard Routes
      case '/admin': return _page(const AdminDashboard());
      case '/idcard': return _page(const CollectorIDCard());
      case '/rate': return _page(const RateCollectorScreen());
      case '/route': return _page(const MyRouteScreen());
      case '/users': return _page(const UserManagementScreen());
      case '/verify': return _page(const VerifyCollectorScreen());
      case '/audit': return _page(const AuditLogsScreen());
      case '/admin_profile': return _page(const AdminProfileScreen());
      case '/reports': return _page(const ReportsScreen());
      case '/analytics': return _page(const AnalyticsScreen());
      case '/chat': return _page(const ChatScreen());
      case '/detection': return _page(const DetectionResultsScreen());
      case '/collector_nav': return _page(const CollectorNavigationScreen(), settings);
      case '/request_details': return _page(const RequestDetailsScreen(), settings);
      default: return _page(const LoginScreen());
    }
  }
  
  static MaterialPageRoute _page(Widget child, [RouteSettings? settings]) => MaterialPageRoute(builder: (_) => child, settings: settings);
  
  static PageRouteBuilder _tab(Widget child, [RouteSettings? settings]) => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    settings: settings,
  );
}
