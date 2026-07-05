import 'role_permissions.dart';

/// Auth state — matches ACM Paper: role from UserAccount/{uid}/Role
class AuthState {
  AuthState._();
  static final AuthState _instance = AuthState._();
  static AuthState get instance => _instance;

  String? _role;
  String? _uid;

  String? get role => _role;
  String? get uid => _uid;
  bool get isLoggedIn => _role != null;

  void login(String role, String uid) { _role = role; _uid = uid; }
  void logout() { _role = null; _uid = null; }

  bool canAccess(String route) => RolePermissions.canAccessRoute(_role, route);
  bool hasPermission(String permission) => RolePermissions.hasPermission(_role, permission);
}
