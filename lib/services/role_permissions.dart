class RolePermissions {
  RolePermissions._();

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

  static const Map<String, String> routePermissions = {
    '/sell': sellScrap,
    '/pickups': viewPickups,
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

  static bool hasPermission(String? role, String permission) {
    if (role == null) return false;
    final permissions = rolePermissions[role] ?? [];
    return permissions.contains(permission);
  }

  static bool canAccessRoute(String? role, String route) {
    if (route == '/' || route == '/register' || route == '/register-household' || route == '/register-collector') return true;
    if (role == 'Admin') return true;
    final required = routePermissions[route];
    if (required == null) return true;
    return hasPermission(role, required);
  }
}
