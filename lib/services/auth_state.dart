import 'role_permissions.dart';

// Shared by every post-login navigation site (login_screen.dart,
// landing_screen.dart's session restore) so there's one place that decides
// where a role lands — rather than each site re-guessing with its own
// ternary, where an unrecognized role (e.g. data corruption writing
// 'VerifiedCollector' into Role instead of 'Collector') used to silently
// fall through to '/household'. Returns null for anything that isn't
// exactly Household/Collector/Admin (Table 7) so callers can surface that
// as an error instead of misrouting.
String? routeForRole(String? role) {
  switch (role) {
    case 'Household':
      return '/household';
    case 'Collector':
      return '/collector';
    case 'Admin':
      return '/admin';
    default:
      return null;
  }
}

class AuthState {
  AuthState._();
  static final AuthState _instance = AuthState._();
  static AuthState get instance => _instance;

  String? _role;
  String? _uid;

  String _displayName = '';
  String _email = '';
  String _phone = '';

  String? get role => _role;
  String? get uid => _uid;
  String get displayName => _displayName;
  String get email => _email;
  String get phone => _phone;
  bool get isLoggedIn => _role != null;
  bool get isHousehold => _role == 'Household';
  bool get isCollector => _role == 'Collector';
  bool get isAdmin => _role == 'Admin';

  String _sellerAddress = '';
  String _preferredSchedule = 'ASAP';
  String get address => _sellerAddress;
  String get preferredSchedule => _preferredSchedule;

  // Last-used pickup pin (ScrapSeller.Address_GPS) — null until the household
  // confirms one on Sell Scrap, and cleared if their barangay/city changes.
  double? _addressLat;
  double? _addressLon;
  double? get addressLat => _addressLat;
  double? get addressLon => _addressLon;
  bool get hasAddressPin => _addressLat != null && _addressLon != null;

  void setAddressPin(double? lat, double? lon) {
    _addressLat = lat;
    _addressLon = lon;
  }

  String _vehicleType = '';
  double _vehicleCapacityKg = 0;
  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _verificationDocs = [];
  List<String> _preferredMaterials = [];
  String _verificationStatus = 'Pending';
  String _digitalBadgeUrl = '';
  double _avgRating = 0;
  double _currentLatitude = 0;
  double _currentLongitude = 0;
  bool _onlineStatus = false;
  String _collectorAddress = '';

  String get vehicleType => _vehicleType;
  double get vehicleCapacityKg => _vehicleCapacityKg;
  List<Map<String, dynamic>> get vehicles => _vehicles;
  List<Map<String, dynamic>> get verificationDocs => _verificationDocs;
  List<String> get preferredMaterials => _preferredMaterials;
  String get verificationStatus => _verificationStatus;
  String get digitalBadgeUrl => _digitalBadgeUrl;
  double get avgRating => _avgRating;
  double get currentLatitude => _currentLatitude;
  double get currentLongitude => _currentLongitude;
  bool get onlineStatus => _onlineStatus;
  String get collectorAddress => _collectorAddress;

  // Digital ID details (ScrapCollector Profile_Photo_URL / Birthdate /
  // Signature_URL). Kept out of setCollectorProfile on purpose — its many
  // re-call sites would otherwise each have to carry these through.
  String _profilePhotoUrl = '';
  DateTime? _birthdate;
  String _signatureUrl = '';

  String get profilePhotoUrl => _profilePhotoUrl;
  DateTime? get birthdate => _birthdate;
  String get signatureUrl => _signatureUrl;

  // Admin-approved vehicle types (ScrapCollector.Verified_Vehicles, with the
  // legacy fallback from core/vehicle_verification.dart already applied).
  List<String> _verifiedVehicles = [];
  List<String> get verifiedVehicles => _verifiedVehicles;

  bool isVehicleApproved(String vehicleType) =>
      _verifiedVehicles.contains(vehicleType);

  void setVerifiedVehicles(List<String> types) {
    _verifiedVehicles = types;
  }

  void setIdDetails({
    String? profilePhotoUrl,
    DateTime? birthdate,
    String? signatureUrl,
  }) {
    if (profilePhotoUrl != null) _profilePhotoUrl = profilePhotoUrl;
    if (birthdate != null) _birthdate = birthdate;
    if (signatureUrl != null) _signatureUrl = signatureUrl;
  }

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
    List<Map<String, dynamic>> vehicles = const [],
    List<Map<String, dynamic>> verificationDocs = const [],
    List<String> preferredMaterials = const [],
    String verificationStatus = 'Pending',
    String digitalBadgeUrl = '',
    double avgRating = 0,
    double currentLatitude = 0,
    double currentLongitude = 0,
    bool onlineStatus = false,
    String collectorAddress = '',
  }) {
    _vehicleType = vehicleType;
    _vehicleCapacityKg = vehicleCapacityKg;
    _vehicles = vehicles;
    _verificationDocs = verificationDocs;
    _preferredMaterials = preferredMaterials;
    _verificationStatus = verificationStatus;
    _digitalBadgeUrl = digitalBadgeUrl;
    _avgRating = avgRating;
    _currentLatitude = currentLatitude;
    _currentLongitude = currentLongitude;
    _onlineStatus = onlineStatus;
    _collectorAddress = collectorAddress;
  }

  // Lets a single-field update (e.g. after saving the structured address
  // form) skip re-supplying every other collector field via
  // setCollectorProfile.
  void updateCollectorAddress(String address) {
    _collectorAddress = address;
  }

  void updateOnlineStatus(bool online) {
    _onlineStatus = online;
  }

  // Lets a single-field update (e.g. after re-uploading a verification
  // document) skip re-supplying every other collector field via
  // setCollectorProfile.
  void updateVerificationDocs(List<Map<String, dynamic>> docs) {
    _verificationDocs = docs;
  }

  void logout() {
    _role = null;
    _uid = null;
    _displayName = '';
    _email = '';
    _phone = '';
    _sellerAddress = '';
    _addressLat = null;
    _addressLon = null;
    _preferredSchedule = 'ASAP';
    _vehicleType = '';
    _vehicleCapacityKg = 0;
    _vehicles = [];
    _verificationDocs = [];
    _preferredMaterials = [];
    _verificationStatus = 'Pending';
    _digitalBadgeUrl = '';
    _avgRating = 0;
    _currentLatitude = 0;
    _currentLongitude = 0;
    _onlineStatus = false;
    _collectorAddress = '';
    _profilePhotoUrl = '';
    _birthdate = null;
    _signatureUrl = '';
    _verifiedVehicles = [];
  }

  // 'VerifiedCollector' is a permission tier, not a stored Role value —
  // Firestore's Role field only ever holds Household/Collector/Admin (Table
  // 7). It's computed here from the collector's actual Verification_Status
  // instead, so accept_pickup only unlocks once they're really verified.
  String? get _effectiveRole =>
      _role == 'Collector' && _verificationStatus == 'Verified'
          ? 'VerifiedCollector'
          : _role;

  bool canAccess(String route) =>
      RolePermissions.canAccessRoute(_effectiveRole, route);
  bool hasPermission(String permission) =>
      RolePermissions.hasPermission(_effectiveRole, permission);
}
