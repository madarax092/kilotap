import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ─── Auth State Stream ─────────────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ─── Email / Password Sign Up ──────────────────────────────────────────────
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required String address,
    required UserRole role,
    SellerAccountType? accountType,
    String? areaOfOperation,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(displayName);

    // Create user document in Firestore
    final userModel = UserModel(
      uid: credential.user!.uid,
      displayName: displayName,
      email: email,
      phone: phone,
      address: address,
      role: role,
      accountType: accountType,
      areaOfOperation: areaOfOperation,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.colUsers)
        .doc(credential.user!.uid)
        .set(userModel.toFirestore());

    return credential;
  }

  // ─── Email / Password Sign In ──────────────────────────────────────────────
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ─── Phone Number Sign In (using email fallback for prototype) ─────────────
  Future<UserCredential> signInWithPhone(String phoneOrEmail, String password) async {
    // In prototype, we treat phone as email identifier
    final email = phoneOrEmail.contains('@')
        ? phoneOrEmail
        : '${phoneOrEmail.replaceAll(' ', '')}@kilotap.app';
    return signInWithEmail(email: email, password: password);
  }

  // ─── Google Sign In ────────────────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle({required UserRole role}) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    // Create/update Firestore user doc if new user
    final userDoc = await _firestore
        .collection(AppConstants.colUsers)
        .doc(userCredential.user!.uid)
        .get();

    if (!userDoc.exists) {
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        displayName: userCredential.user!.displayName ?? '',
        email: userCredential.user!.email ?? '',
        phone: '',
        address: '',
        role: role,
        photoUrl: userCredential.user!.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.colUsers)
          .doc(userCredential.user!.uid)
          .set(userModel.toFirestore());
    }

    return userCredential;
  }

  // ─── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── Get User Profile ──────────────────────────────────────────────────────
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.colUsers)
        .doc(uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // ─── Update User Profile ───────────────────────────────────────────────────
  Future<void> updateUserProfile(UserModel user) async {
    await _firestore
        .collection(AppConstants.colUsers)
        .doc(user.uid)
        .update(user.toFirestore());
  }

  // ─── Password Reset ────────────────────────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
