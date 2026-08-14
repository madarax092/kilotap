import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_state.dart';

// ─── Auth: Sign In / Sign Up / Sign Out (Tables 7-9) ───

class AuthService {
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const colAccount = 'UserAccount';
  static const colSeller = 'ScrapSeller';
  static const colCollector = 'ScrapCollector';

  Future<String?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final doc = await _firestore.collection(colAccount).doc(cred.user!.uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final role = data['Role'] as String? ?? 'Household';

      AuthState.instance.login(role, cred.user!.uid);
      AuthState.instance.setProfile(
        displayName: data['Display_Name'] ?? '',
        email: data['Email'] ?? '',
        phone: data['Phone'] ?? '',
      );

      if (role == 'Household') {
        final sellerDoc = await _firestore
            .collection(colAccount).doc(cred.user!.uid)
            .collection(colSeller).doc(cred.user!.uid).get();
        if (sellerDoc.exists) {
          final s = sellerDoc.data()!;
          AuthState.instance.setSellerProfile(
            address: s['Address'] ?? '',
            preferredSchedule: s['Preferred_Schedule'] ?? 'ASAP',
          );
        }
      } else if (role == 'Collector') {
        final collectorDoc = await _firestore
            .collection(colAccount).doc(cred.user!.uid)
            .collection(colCollector).doc(cred.user!.uid).get();
        if (collectorDoc.exists) {
          final c = collectorDoc.data()!;
          AuthState.instance.setCollectorProfile(
            vehicleType: c['Vehicle_Type'] ?? '',
            vehicleCapacityKg: (c['Vehicle_Capacity_Kg'] ?? 0).toDouble(),
            preferredMaterials: List<String>.from(c['Preferred_Materials'] ?? []),
            verificationStatus: c['Verification_Status'] ?? 'Pending',
            digitalBadgeUrl: c['Digital_Badge_URL'] ?? '',
            avgRating: (c['Avg_Rating'] ?? 0).toDouble(),
            currentLatitude: (c['Current_Latitude'] ?? 0).toDouble(),
            currentLongitude: (c['Current_Longitude'] ?? 0).toDouble(),
            onlineStatus: c['Online_Status'] ?? false,
          );
        }
      }

      return role;
    } on FirebaseAuthException {
      return null;
    }
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
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;

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
        await _firestore.collection(colAccount).doc(uid).collection(colSeller).doc(uid).set({
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
        await _firestore.collection(colAccount).doc(uid).collection(colCollector).doc(uid).set({
          'Collector_ID': uid,
          'Account_Id': uid,
          'Full_Name': fullName,
          'Vehicle_Type': '',
          'Vehicle_Capacity_Kg': 0,
          'Preferred_Materials': [],
          'Verification_Status': 'Pending',
          'Verification_Docs': [
            {'type': 'Valid ID', 'url': '', 'status': 'pending'},
            {'type': 'Vehicle Photo', 'url': '', 'status': 'pending'},
            {'type': 'Profile Photo Match', 'url': '', 'status': 'pending'},
          ],
          'Digital_Badge_URL': '',
          'Avg_Rating': 0.0,
          'Current_Latitude': 0.0,
          'Current_Longitude': 0.0,
          'Online_Status': false,
        });
      }

      AuthState.instance.login(role, uid);
      AuthState.instance.setProfile(
        displayName: fullName,
        email: email,
        phone: phone,
      );
      if (role == 'Household') {
        AuthState.instance.setSellerProfile(address: address);
      } else if (role == 'Collector') {
        AuthState.instance.setCollectorProfile();
      }
      return role;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile(String? uid) async {
    if (uid == null) return null;
    final role = AuthState.instance.role;
    final col = role == 'Household' ? colSeller : colCollector;
    final doc = await _firestore.collection(colAccount).doc(uid).collection(col).doc(uid).get();
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
    await _firestore.collection(colAccount).doc(uid)
        .collection(colSeller).doc(uid).update({
      'Address': address,
      if (preferredSchedule != null) 'Preferred_Schedule': preferredSchedule,
    });
    AuthState.instance.setSellerProfile(
      address: address,
      preferredSchedule: preferredSchedule ?? AuthState.instance.preferredSchedule,
    );
  }

  Future<void> updateCollectorProfile({
    String? vehicleType,
    double? vehicleCapacityKg,
    List<String>? preferredMaterials,
  }) async {
    final uid = AuthState.instance.uid;
    if (uid == null) return;
    await _firestore.collection(colAccount).doc(uid)
        .collection(colCollector).doc(uid).update({
      if (vehicleType != null) 'Vehicle_Type': vehicleType,
      if (vehicleCapacityKg != null) 'Vehicle_Capacity_Kg': vehicleCapacityKg,
      if (preferredMaterials != null) 'Preferred_Materials': preferredMaterials,
    });
    AuthState.instance.setCollectorProfile(
      vehicleType: vehicleType ?? AuthState.instance.vehicleType,
      vehicleCapacityKg: vehicleCapacityKg ?? AuthState.instance.vehicleCapacityKg,
      preferredMaterials: preferredMaterials ?? AuthState.instance.preferredMaterials,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    AuthState.instance.logout();
  }
}
