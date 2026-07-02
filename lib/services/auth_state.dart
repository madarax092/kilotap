import 'role_permissions.dart';

/// Simple auth state holder — demo mode (replace with Firebase later)
class AuthState {
  AuthState._();
  static final AuthState _instance = AuthState._();
  static AuthState get instance => _instance;

  String? _role;
  String? get role => _role;
  bool get isLoggedIn => _role != null;
  bool get isVerified => _role == 'VerifiedCollector';

  void login(String role) => _role = role;
  void logout() => _role = null;

  /// Check if current role can access the given route
  bool canAccess(String route) => RolePermissions.canAccessRoute(_role, route);

  /// Check if current role has a specific permission
  bool hasPermission(String permission) => RolePermissions.hasPermission(_role, permission);
}
