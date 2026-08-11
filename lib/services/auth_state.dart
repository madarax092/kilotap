import 'role_permissions.dart';

/// Tracks current user role, profile, and permissions from Firestore
class AuthState {
  AuthState._();
  static final AuthState _instance = AuthState._();
  static AuthState get instance => _instance;

  // ── Core ──
  String? _role;
  String? _uid;

  // ── UserAccount (Table 7) ──
  String _displayName = '';
  String _email = '';
  String _phone = '';

  // ── Getters ──
  String? get role => _role;
  String? get uid => _uid;
  String get displayName => _displayName;
  String get email => _email;
  String get phone => _phone;
  bool get isLoggedIn => _role != null;
  bool get isHousehold => _role == 'Household';
  bool get isCollector => _role == 'Collector';
  bool get isAdmin => _role == 'Admin';

  // ── ScrapSeller (Table 8) ──
  String _sellerAddress = '';
  String _preferredSchedule = 'ASAP';
  String get address => _sellerAddress;
  String get preferredSchedule => _preferredSchedule;

  // ── ScrapCollector (Table 9) ──
  String _vehicleType = '';
  double _vehicleCapacityKg = 0;
  List<String> _preferredMaterials = [];
  String _verificationStatus = 'Pending';
  String _digitalBadgeUrl = '';
  double _avgRating = 0;
  double _currentLatitude = 0;
  double _currentLongitude = 0;
  bool _onlineStatus = false;

  String get vehicleType => _vehicleType;
  double get vehicleCapacityKg => _vehicleCapacityKg;
  List<String> get preferredMaterials => _preferredMaterials;
  String get verificationStatus => _verificationStatus;
  String get digitalBadgeUrl => _digitalBadgeUrl;
  double get avgRating => _avgRating;
  double get currentLatitude => _currentLatitude;
  double get currentLongitude => _currentLongitude;
  bool get onlineStatus => _onlineStatus;

  // ── Login ──
  void login(String role, String uid) {
    _role = role;
    _uid = uid;
  }

  void setProfile({
    required String displayName,
    required String email,
    required String phone,
  }) {
    _displayName = displayName;
    _email = email;
    _phone = phone;
  }

  void setSellerProfile({
    String address = '',
    String preferredSchedule = 'ASAP',
  }) {
    _sellerAddress = address;
    _preferredSchedule = preferredSchedule;
  }

  void setCollectorProfile({
    String vehicleType = '',
    double vehicleCapacityKg = 0,
    List<String> preferredMaterials = const [],
    String verificationStatus = 'Pending',
    String digitalBadgeUrl = '',
    double avgRating = 0,
    double currentLatitude = 0,
    double currentLongitude = 0,
    bool onlineStatus = false,
  }) {
    _vehicleType = vehicleType;
    _vehicleCapacityKg = vehicleCapacityKg;
    _preferredMaterials = preferredMaterials;
    _verificationStatus = verificationStatus;
    _digitalBadgeUrl = digitalBadgeUrl;
    _avgRating = avgRating;
    _currentLatitude = currentLatitude;
    _currentLongitude = currentLongitude;
    _onlineStatus = onlineStatus;
  }

  void logout() {
    _role = null;
    _uid = null;
    _displayName = '';
    _email = '';
    _phone = '';
    _sellerAddress = '';
    _preferredSchedule = 'ASAP';
    _vehicleType = '';
    _vehicleCapacityKg = 0;
    _preferredMaterials = [];
    _verificationStatus = 'Pending';
    _digitalBadgeUrl = '';
    _avgRating = 0;
    _currentLatitude = 0;
    _currentLongitude = 0;
    _onlineStatus = false;
  }

  bool canAccess(String route) => RolePermissions.canAccessRoute(_role, route);
  bool hasPermission(String permission) => RolePermissions.hasPermission(_role, permission);
}
