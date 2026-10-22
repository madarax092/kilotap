import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/address_format.dart';
import '../core/vehicle_verification.dart';
import '../core/verification_docs.dart';
import 'auth_state.dart';
import 'push_notification_service.dart';

// ─── Auth: Sign In / Sign Up / Sign Out (Tables 7-9) ───

class GoogleAuthResult {
  final bool needsRegistration;
  final String? role;
  final String uid;
  final String email;
  final String displayName;

  const GoogleAuthResult({
    required this.needsRegistration,
    this.role,
    required this.uid,
    required this.email,
    required this.displayName,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  static const colAccount = 'UserAccount';
  static const colSeller = 'ScrapSeller';
  static const colCollector = 'ScrapCollector';

  Future<String?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final doc =
          await _firestore.collection(colAccount).doc(cred.user!.uid).get();
      if (!doc.exists) return null;
      return _loadUserDataIntoState(cred.user!.uid, doc.data()!);
    } on FirebaseAuthException {
      return null;
    }
  }

  // Firebase keeps the sign-in session across app restarts, but AuthState
  // (the in-memory role/profile cache) starts empty every cold start — this
  // re-hydrates it from the still-valid session so the app can skip straight
  // past the login screen instead of showing it to an already-signed-in user.
  Future<String?> tryRestoreSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore.collection(colAccount).doc(user.uid).get();
      if (!doc.exists) return null;
      return _loadUserDataIntoState(user.uid, doc.data()!);
    } catch (_) {
      return null;
    }
  }

  Future<GoogleAuthResult?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      final uid = cred.user!.uid;
      final email = cred.user!.email ?? googleUser.email;
      final displayName =
          cred.user!.displayName ?? googleUser.displayName ?? '';

      final doc = await _firestore.collection(colAccount).doc(uid).get();
      if (!doc.exists) {
        return GoogleAuthResult(
            needsRegistration: true,
            uid: uid,
            email: email,
            displayName: displayName);
      }

      final role = await _loadUserDataIntoState(uid, doc.data()!);
      return GoogleAuthResult(
          needsRegistration: false,
          role: role,
          uid: uid,
          email: email,
          displayName: displayName);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _loadUserDataIntoState(
      String uid, Map<String, dynamic> data) async {
    // 'VerifiedCollector' was briefly (incorrectly) written to Firestore's
    // Role field by a since-fixed bug in setCollectorVerification() — it's a
    // computed permission tier (see AuthState._effectiveRole), never meant
    // to be stored. Normalized here so any account already carrying that
    // legacy value keeps working without a manual Firestore edit.
    final rawRole = data['Role'] as String? ?? 'Household';
    final role = rawRole == 'VerifiedCollector' ? 'Collector' : rawRole;

    AuthState.instance.login(role, uid);
    unawaited(PushNotificationService.instance.registerDeviceToken(uid));
    AuthState.instance.setProfile(
      displayName: data['Display_Name'] ?? '',
      email: data['Email'] ?? '',
      phone: data['Phone'] ?? '',
    );
    if (role == 'Household') {
      final sellerDoc = await _firestore
          .collection(colAccount)
          .doc(uid)
          .collection(colSeller)
          .doc(uid)
          .get();
      if (sellerDoc.exists) {
        final s = sellerDoc.data()!;
        AuthState.instance.setSellerProfile(
          address: s['Address'] ?? '',
          preferredSchedule: s['Preferred_Schedule'] ?? 'ASAP',
        );
        final pin = s['Address_GPS'];
        if (pin is GeoPoint) {
          AuthState.instance.setAddressPin(pin.latitude, pin.longitude);
        }
      }
    } else if (role == 'Collector') {
      final collectorDoc = await _firestore
          .collection(colAccount)
          .doc(uid)
          .collection(colCollector)
          .doc(uid)
          .get();
      if (collectorDoc.exists) {
        final c = collectorDoc.data()!;
        AuthState.instance.setCollectorProfile(
          vehicleType: c['Vehicle_Type'] ?? '',
          vehicleCapacityKg: (c['Vehicle_Capacity_Kg'] ?? 0).toDouble(),
          vehicles: List<Map<String, dynamic>>.from(
              (c['Vehicles'] as List<dynamic>?)
                      ?.map((v) => Map<String, dynamic>.from(v)) ??
                  const []),
          verificationDocs: normalizeVerificationDocs(
              List<Map<String, dynamic>>.from(
                  (c['Verification_Docs'] as List<dynamic>?)
                          ?.map((v) => Map<String, dynamic>.from(v)) ??
                      const [])),
          preferredMaterials: List<String>.from(c['Preferred_Materials'] ?? []),
          verificationStatus: c['Verification_Status'] ?? 'Pending',
          digitalBadgeUrl: c['Digital_Badge_URL'] ?? '',
          avgRating: (c['Avg_Rating'] ?? 0).toDouble(),
          currentLatitude: (c['Current_Latitude'] ?? 0).toDouble(),
          currentLongitude: (c['Current_Longitude'] ?? 0).toDouble(),
          onlineStatus: c['Online_Status'] ?? false,
          collectorAddress: c['Address'] ?? '',
        );
        AuthState.instance.setIdDetails(
          profilePhotoUrl: c['Profile_Photo_URL'] ?? '',
          birthdate: (c['Birthdate'] as Timestamp?)?.toDate(),
          signatureUrl: c['Signature_URL'] ?? '',
        );
        AuthState.instance.setVerifiedVehicles(effectiveVerifiedVehicles(c));
      }
    }
    return role;
  }

  Future<String?> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    required String address,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _createAccountDocs(
        uid: cred.user!.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        role: role,
        address: address,
      );
      return role;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<String?> completeGoogleRegistration({
    required String uid,
    required String email,
    required String fullName,
    required String phone,
    required String role,
    required String address,
  }) async {
    try {
      await _createAccountDocs(
        uid: uid,
        email: email,
        fullName: fullName,
        phone: phone,
        role: role,
        address: address,
      );
      return role;
    } catch (_) {
      return null;
    }
  }

  Future<void> _createAccountDocs({
    required String uid,
    required String email,
    required String fullName,
    required String phone,
    required String role,
    required String address,
  }) async {
    await _firestore.collection(colAccount).doc(uid).set({
      'Account_Id': uid,
      'Auth_UID': uid,
      'Display_Name': fullName,
      'Email': email,
      'Phone': phone,
      'Role': role,
      'Created_At': FieldValue.serverTimestamp(),
    });

    if (role == 'Household') {
      await _firestore
          .collection(colAccount)
          .doc(uid)
          .collection(colSeller)
          .doc(uid)
          .set({
        'Seller_Id': uid,
        'Account_Id': uid,
        'Full_Name': fullName,
        'Phone': phone,
        'Email': email,
        'Address': address,
        'Preferred_Schedule': 'ASAP',
        'Created_At': FieldValue.serverTimestamp(),
      });
    }

    if (role == 'Collector') {
      await _firestore
          .collection(colAccount)
          .doc(uid)
          .collection(colCollector)
          .doc(uid)
          .set({
        'Collector_ID': uid,
        'Account_Id': uid,
        'Full_Name': fullName,
        'Address': address,
        'Vehicle_Type': 'Pushcart',
        'Vehicle_Capacity_Kg': 20.0,
        'Vehicles': [
          {'Vehicle_Type': 'Pushcart', 'Vehicle_Capacity_Kg': 20.0},
        ],
        'Preferred_Materials': [],
        'Verification_Status': 'Pending',
        'Verification_Docs': emptyVerificationDocs(),
        'Digital_Badge_URL': '',
        'Avg_Rating': 0.0,
        'Current_Latitude': 0.0,
        'Current_Longitude': 0.0,
        'Online_Status': false,
      });
    }

    AuthState.instance.login(role, uid);
    unawaited(PushNotificationService.instance.registerDeviceToken(uid));
    AuthState.instance.setProfile(
      displayName: fullName,
      email: email,
      phone: phone,
    );
    if (role == 'Household') {
      AuthState.instance.setSellerProfile(address: address);
    } else if (role == 'Collector') {
      AuthState.instance.setCollectorProfile(
        vehicleType: 'Pushcart',
        vehicleCapacityKg: 20.0,
        vehicles: const [
          {'Vehicle_Type': 'Pushcart', 'Vehicle_Capacity_Kg': 20.0},
        ],
        verificationDocs: emptyVerificationDocs(),
        collectorAddress: address,
      );
    }
  }

  Future<Map<String, dynamic>?> getProfile(String? uid) async {
    if (uid == null) return null;
    final role = AuthState.instance.role;
    final col = role == 'Household' ? colSeller : colCollector;
    final doc = await _firestore
        .collection(colAccount)
        .doc(uid)
        .collection(col)
        .doc(uid)
        .get();
    return doc.data();
  }

  Future<void> updateUserAccount({
    required String displayName,
    required String phone,
  }) async {
    final uid = AuthState.instance.uid;
    if (uid == null) return;
    await _firestore.collection(colAccount).doc(uid).update({
      'Display_Name': displayName,
      'Phone': phone,
    });
    AuthState.instance.setProfile(
      displayName: displayName,
      email: AuthState.instance.email,
      phone: phone,
    );
  }

  Future<void> updateSellerProfile({
    required String address,
    String? preferredSchedule,
  }) async {
    final uid = AuthState.instance.uid;
    if (uid == null) return;
    // A saved pin only stays valid while the barangay and city are the same;
    // changing either means the old pin likely points somewhere else now.
    final clearPin = AuthState.instance.hasAddressPin &&
        addressArea(AuthState.instance.address) != addressArea(address);
    await _firestore
        .collection(colAccount)
        .doc(uid)
        .collection(colSeller)
        .doc(uid)
        .update({
      'Address': address,
      if (clearPin) 'Address_GPS': FieldValue.delete(),
      if (preferredSchedule != null) 'Preferred_Schedule': preferredSchedule,
    });
    AuthState.instance.setSellerProfile(
      address: address,
      preferredSchedule:
          preferredSchedule ?? AuthState.instance.preferredSchedule,
    );
    if (clearPin) AuthState.instance.setAddressPin(null, null);
  }

  // Remembers the last confirmed pickup pin so a returning household doesn't
  // have to place it again. ScrapSeller.Address_GPS is outside the paper's
  // Table 8 — documented in CLAUDE.md alongside the other added fields.
  Future<void> updateSellerPin(double lat, double lon) async {
    final uid = AuthState.instance.uid;
    if (uid == null) return;
    await _firestore
        .collection(colAccount)
        .doc(uid)
        .collection(colSeller)
        .doc(uid)
        .update({'Address_GPS': GeoPoint(lat, lon)});
    AuthState.instance.setAddressPin(lat, lon);
  }

  Future<void> updateCollectorAddress(String address) async {
    final uid = AuthState.instance.uid;
    if (uid == null) return;
    await _firestore
        .collection(colAccount)
        .doc(uid)
        .collection(colCollector)
        .doc(uid)
        .update({'Address': address});
    AuthState.instance.updateCollectorAddress(address);
  }

  // The active Vehicle_Type/Vehicle_Capacity_Kg fields are what
  // vehicleCanHandle() actually filters Find Scrap by — they're separate
  // from the Vehicles array and used to go stale the moment a collector
  // edited their vehicle here without also going through the multi-vehicle
  // online-toggle picker. Keeping the first entry as "active" on every save
  // closes that gap; a collector with 2 vehicles can still re-pick which is
  // active via that picker when going online. Once verified, only an
  // admin-approved vehicle can become active (enforced in firestore.rules
  // too), so a newly added vehicle never silently takes over.
  Future<void> updateCollectorVehicles(
      List<Map<String, dynamic>> vehicles) async {
    final uid = AuthState.instance.uid;
    if (uid == null) return;
    final auth = AuthState.instance;
    final candidates = auth.verificationStatus == 'Verified'
        ? vehicles
            .where((v) => auth.isVehicleApproved(v['Vehicle_Type'] as String))
            .toList()
        : vehicles;
    final active = candidates.isNotEmpty ? candidates.first : null;
    final activeType = active?['Vehicle_Type'] as String? ??
        AuthState.instance.vehicleType;
    final activeCapacity = (active?['Vehicle_Capacity_Kg'] as num?)
            ?.toDouble() ??
        AuthState.instance.vehicleCapacityKg;
    await _firestore
        .collection(colAccount)
        .doc(uid)
        .collection(colCollector)
        .doc(uid)
        .update({
      'Vehicles': vehicles,
      'Vehicle_Type': activeType,
      'Vehicle_Capacity_Kg': activeCapacity,
    });
    AuthState.instance.setCollectorProfile(
      vehicleType: activeType,
      vehicleCapacityKg: activeCapacity,
      vehicles: vehicles,
      verificationDocs: AuthState.instance.verificationDocs,
      preferredMaterials: AuthState.instance.preferredMaterials,
      verificationStatus: AuthState.instance.verificationStatus,
      digitalBadgeUrl: AuthState.instance.digitalBadgeUrl,
      avgRating: AuthState.instance.avgRating,
      currentLatitude: AuthState.instance.currentLatitude,
      currentLongitude: AuthState.instance.currentLongitude,
      onlineStatus: AuthState.instance.onlineStatus,
      collectorAddress: AuthState.instance.collectorAddress,
    );
  }

  Future<void> updateCollectorProfile({
    String? vehicleType,
    double? vehicleCapacityKg,
    List<String>? preferredMaterials,
  }) async {
    final uid = AuthState.instance.uid;
    if (uid == null) return;
    await _firestore
        .collection(colAccount)
        .doc(uid)
        .collection(colCollector)
        .doc(uid)
        .update({
      if (vehicleType != null) 'Vehicle_Type': vehicleType,
      if (vehicleCapacityKg != null) 'Vehicle_Capacity_Kg': vehicleCapacityKg,
      if (preferredMaterials != null) 'Preferred_Materials': preferredMaterials,
    });
    AuthState.instance.setCollectorProfile(
      vehicleType: vehicleType ?? AuthState.instance.vehicleType,
      vehicleCapacityKg:
          vehicleCapacityKg ?? AuthState.instance.vehicleCapacityKg,
      vehicles: AuthState.instance.vehicles,
      verificationDocs: AuthState.instance.verificationDocs,
      preferredMaterials:
          preferredMaterials ?? AuthState.instance.preferredMaterials,
      verificationStatus: AuthState.instance.verificationStatus,
      digitalBadgeUrl: AuthState.instance.digitalBadgeUrl,
      avgRating: AuthState.instance.avgRating,
      currentLatitude: AuthState.instance.currentLatitude,
      currentLongitude: AuthState.instance.currentLongitude,
      onlineStatus: AuthState.instance.onlineStatus,
      collectorAddress: AuthState.instance.collectorAddress,
    );
  }

  Future<void> updateCollectorLocation(double lat, double lon) async {
    final uid = AuthState.instance.uid;
    if (uid == null) return;
    await _firestore
        .collection(colAccount)
        .doc(uid)
        .collection(colCollector)
        .doc(uid)
        .update({'Current_Latitude': lat, 'Current_Longitude': lon});
    AuthState.instance.setCollectorProfile(
      vehicleType: AuthState.instance.vehicleType,
      vehicleCapacityKg: AuthState.instance.vehicleCapacityKg,
      vehicles: AuthState.instance.vehicles,
      verificationDocs: AuthState.instance.verificationDocs,
      preferredMaterials: AuthState.instance.preferredMaterials,
      verificationStatus: AuthState.instance.verificationStatus,
      digitalBadgeUrl: AuthState.instance.digitalBadgeUrl,
      avgRating: AuthState.instance.avgRating,
      currentLatitude: lat,
      currentLongitude: lon,
      onlineStatus: AuthState.instance.onlineStatus,
      collectorAddress: AuthState.instance.collectorAddress,
    );
  }

  // Digital ID fields — not in the paper's documented Table 9, added so the
  // ID card can show who the collector actually is (see CLAUDE.md schema).
  Future<void> updateCollectorIdDetails({
    String? profilePhotoUrl,
    DateTime? birthdate,
    String? signatureUrl,
  }) async {
    final uid = AuthState.instance.uid;
    if (uid == null) return;
    await _firestore
        .collection(colAccount)
        .doc(uid)
        .collection(colCollector)
        .doc(uid)
        .update({
      if (profilePhotoUrl != null) 'Profile_Photo_URL': profilePhotoUrl,
      if (birthdate != null) 'Birthdate': Timestamp.fromDate(birthdate),
      if (signatureUrl != null) 'Signature_URL': signatureUrl,
    });
    AuthState.instance.setIdDetails(
      profilePhotoUrl: profilePhotoUrl,
      birthdate: birthdate,
      signatureUrl: signatureUrl,
    );
  }

  // Online_Status (Table 9) is what the new-booking Cloud Function filters
  // on, so the Find Scrap toggle has to persist it, not just flip local UI.
  Future<void> setOnlineStatus(bool online) async {
    final uid = AuthState.instance.uid;
    if (uid == null) return;
    await _firestore
        .collection(colAccount)
        .doc(uid)
        .collection(colCollector)
        .doc(uid)
        .update({'Online_Status': online});
    AuthState.instance.updateOnlineStatus(online);
  }

  Future<void> signOut() async {
    final uid = AuthState.instance.uid;
    if (uid != null) {
      await PushNotificationService.instance.clearDeviceToken(uid);
      if (AuthState.instance.isCollector && AuthState.instance.onlineStatus) {
        try {
          await setOnlineStatus(false);
        } catch (_) {
          // Non-fatal — sign-out must still go through.
        }
      }
    }
    await _auth.signOut();
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
    AuthState.instance.logout();
  }
}
