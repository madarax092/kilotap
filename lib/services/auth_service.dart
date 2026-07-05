import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_state.dart';

/// Firebase Auth + Firestore — matches ACM Paper Data Dictionary (Tables 6-8)
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
      final role = doc['Role'] as String? ?? 'Household';
      AuthState.instance.login(role, cred.user!.uid);
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

      // Table 6: UserAccount
      await _firestore.collection(colAccount).doc(uid).set({
        'Account_Id': uid,
        'Auth_UID': uid,
        'Email': email,
        'Phone': phone,
        'Role': role,
        'Created_At': FieldValue.serverTimestamp(),
      });

      // Table 7: ScrapSeller (subcollection)
      if (role == 'Household') {
        await _firestore.collection(colAccount).doc(uid).collection(colSeller).doc(uid).set({
          'Seller_Id': uid,
          'Account_Id': uid,
          'FullName': fullName,
          'Address': address,
        });
      }

      // Table 8: ScrapCollector (subcollection)
      if (role == 'Collector') {
        await _firestore.collection(colAccount).doc(uid).collection(colCollector).doc(uid).set({
          'Collector_ID': uid,
          'Account_Id': uid,
          'FullName': fullName,
          'VehicleType': '',
          'VehicleCapacityKg': 0,
          'VerificationStatus': 'Pending',
          'VerificationDocs': '',
          'DigitalBadgeURL': '',
          'OnlineStatus': false,
          'CurrentGPS': null,
          'AvgRating': 0.0,
        });
      }

      AuthState.instance.login(role, uid);
      return role;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile(String? uid) async {
    if (uid == null) return null;
    final role = AuthState.instance.role;
    if (role == 'Household') {
      final doc = await _firestore.collection(colAccount).doc(uid).collection(colSeller).doc(uid).get();
      return doc.data();
    }
    if (role == 'Collector') {
      final doc = await _firestore.collection(colAccount).doc(uid).collection(colCollector).doc(uid).get();
      return doc.data();
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    AuthState.instance.logout();
  }
}
