import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_state.dart';

/// Firebase Authentication + Firestore role management
///
/// Collections: UserAccount, ScrapSeller, ScrapCollector
class AuthService {
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const colAccount = 'UserAccount';
  static const colSeller = 'ScrapSeller';
  static const colCollector = 'ScrapCollector';

  /// Sign in — reads role from UserAccount
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

  /// Register — creates UserAccount + role-specific profile document
  Future<String?> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    Map<String, dynamic>? extraFields,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;

      // 1. UserAccount — login credentials + role (matches Table 6 in paper)
      await _firestore.collection(colAccount).doc(uid).set({
        'Account_Id': uid,
        'Auth_UID': uid,
        'Email': email,
        'Phone': phone,
        'Role': role,
        'Created_At': FieldValue.serverTimestamp(),
      });

      // 2. Role-specific profile document
      if (role == 'Household') {
        await _firestore.collection(colSeller).doc(uid).set({
          'Seller_Id': uid,
          'Account_Id': uid,
          'FullName': fullName,
          'Address': extraFields?['address'] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          if (extraFields != null) ...extraFields,
        });
      } else if (role == 'Collector') {
        await _firestore.collection(colCollector).doc(uid).set({
          'Collector_Id': uid,
          'Account_Id': uid,
          'FullName': fullName,
          'VehicleType': extraFields?['vehicleType'] ?? '',
          'VehicleCapacityKg': extraFields?['vehicleCapacityKg'] ?? 0,
          'VerificationStatus': 'pending',
          'OnlineStatus': false,
          'AvgRating': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
          if (extraFields != null) ...extraFields,
        });
      }

      AuthState.instance.login(role, uid);
      return role;
    } on FirebaseAuthException {
      return null;
    }
  }

  /// Get user profile data for display
  Future<Map<String, dynamic>?> getProfile(String? uid) async {
    if (uid == null) return null;
    final role = AuthState.instance.role;
    if (role == 'Household') {
      final doc = await _firestore.collection(colSeller).doc(uid).get();
      return doc.data();
    } else if (role == 'Collector') {
      final doc = await _firestore.collection(colCollector).doc(uid).get();
      return doc.data();
    }
    return null;
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    AuthState.instance.logout();
  }
}
