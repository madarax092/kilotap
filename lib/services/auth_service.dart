import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_state.dart';

/// Firebase Auth + Firestore — matches ACM Paper Data Dictionary (Tables 7-9)
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

      // Table 7: UserAccount
      await _firestore.collection(colAccount).doc(uid).set({
        'Account_Id': uid,
        'Auth_UID': uid,
        'Display_Name': fullName,
        'Email': email,
        'Phone': phone,
        'Role': role,
        'Created_At': FieldValue.serverTimestamp(),
      });

      // Table 8: ScrapSeller (subcollection)
      if (role == 'Household') {
        await _firestore.collection(colAccount).doc(uid).collection(colSeller).doc(uid).set({
          'Seller_Id': uid,
          'Account_Id': uid,
          'Full_Name': fullName,
          'Address': address,
          'Housing_Type': '',
          'Preferred_Schedule': 'ASAP',
          'Created_At': FieldValue.serverTimestamp(),
        });
      }

      // Table 9: ScrapCollector (subcollection)
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

  Future<void> signOut() async {
    await _auth.signOut();
    AuthState.instance.logout();
  }
}
