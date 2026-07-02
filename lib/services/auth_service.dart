import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_state.dart';

/// Firebase Authentication + Firestore role management
class AuthService {
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign in with email/password — fetches role from Firestore
  Future<String?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final doc = await _firestore.collection('sellers').doc(cred.user!.uid).get();
      if (!doc.exists) return null;
      final role = doc['role'] as String? ?? 'Household';
      AuthState.instance.login(role);
      return role;
    } on FirebaseAuthException {
      return null;
    }
  }

  /// Register new user — creates Firebase Auth account + Firestore document with role
  Future<String?> register(String email, String password, String fullName, String phone, String role, {Map<String, dynamic>? extraFields}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection('sellers').doc(cred.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (extraFields != null) ...extraFields,
      });
      // If collector, also create collector profile
      if (role == 'Collector') {
        await _firestore.collection('collectors').doc(cred.user!.uid).set({
          'sellerId': cred.user!.uid,
          'vehicleType': extraFields?['vehicleType'] ?? '',
          'verificationStatus': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      AuthState.instance.login(role);
      return role;
    } on FirebaseAuthException catch (e) {
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    AuthState.instance.logout();
  }
}
