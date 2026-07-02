/// Role-based access control — permission sets per role
class RolePermissions {
  RolePermissions._();

  // Permission keys
  static const sellScrap = 'sell_scrap';
  static const viewPickups = 'view_pickups';
  static const rateCollector = 'rate_collector';
  static const manageProfile = 'manage_profile';
  static const findScrap = 'find_scrap';
  static const viewIdCard = 'view_id_card';
  static const manageRoute = 'manage_route';
  static const viewEarnings = 'view_earnings';
  static const acceptPickup = 'accept_pickup';
  static const chat = 'chat';
  static const manageUsers = 'manage_users';
  static const verifyCollectors = 'verify_collectors';
  static const manageReports = 'manage_reports';
  static const viewAnalytics = 'view_analytics';
  static const auditAccess = 'audit_access';

  /// Roles with their permission sets
  static const Map<String, List<String>> rolePermissions = {
    'Household': [
      sellScrap, viewPickups, rateCollector, manageProfile, chat,
    ],
    'Collector': [
      findScrap, viewIdCard, manageRoute, viewEarnings, manageProfile, chat,
    ],
    'VerifiedCollector': [
      findScrap, viewIdCard, manageRoute, viewEarnings, acceptPickup, manageProfile, chat,
    ],
    'Admin': [
      manageUsers, verifyCollectors, manageReports, viewAnalytics, auditAccess, chat,
    ],
  };

  /// Route → required permission mapping
  static const Map<String, String> routePermissions = {
    '/sell': sellScrap,
    '/pickups': viewPickups,
    '/rate': rateCollector,
    '/profile': manageProfile,
    '/find': findScrap,
    '/idcard': viewIdCard,
    '/route': manageRoute,
    '/earnings': viewEarnings,
    '/collector_profile': manageProfile,
    '/users': manageUsers,
    '/verify': verifyCollectors,
    '/reports': manageReports,
    '/analytics': viewAnalytics,
  };

  /// Check if a role has a specific permission
  static bool hasPermission(String? role, String permission) {
    if (role == null) return false;
    final permissions = rolePermissions[role] ?? [];
    return permissions.contains(permission);
  }

  /// Check if a role can access a specific route
  static bool canAccessRoute(String? role, String route) {
    // Public routes
    if (route == '/' || route == '/register' || route == '/register-household' || route == '/register-collector') return true;
    // Admin can access everything
    if (role == 'Admin') return true;
    // Check specific route permission
    final required = routePermissions[route];
    if (required == null) return true; // unlisted routes are public
    return hasPermission(role, required);
  }
}
