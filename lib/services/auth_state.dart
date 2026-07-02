/// Simple auth state holder — demo mode (replace with Firebase later)
class AuthState {
  AuthState._();
  static final AuthState _instance = AuthState._();
  static AuthState get instance => _instance;

  String? _role; // 'Household', 'Collector', 'Admin'

  String? get role => _role;
  bool get isLoggedIn => _role != null;
  bool get isHousehold => _role == 'Household';
  bool get isCollector => _role == 'Collector';
  bool get isAdmin => _role == 'Admin';

  void login(String role) => _role = role;
  void logout() => _role = null;

  /// Check if current role can access the given route prefix
  bool canAccess(String route) {
    if (_role == null) return false;
    if (route.startsWith('/household') || route.startsWith('/sell') || route.startsWith('/pickups') || route.startsWith('/profile') || route == '/rate') return isHousehold;
    if (route.startsWith('/collector') || route.startsWith('/find') || route.startsWith('/idcard') || route.startsWith('/earnings') || route.startsWith('/route') || route.startsWith('/collector_profile')) return isCollector;
    if (route.startsWith('/admin') || route.startsWith('/users') || route.startsWith('/verify') || route.startsWith('/reports') || route.startsWith('/analytics')) return isAdmin;
    return true; // public routes: /, /register, /chat
  }
}
