import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _googleSignIn = GoogleSignIn();

  static CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  static Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      await _ensureUserProfileDocument(user);
    }
    return credential;
  }

  static Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      await credential.user?.updateDisplayName(trimmed);
    }
    final user = credential.user;
    if (user != null) {
      await _ensureUserProfileDocument(user, preferredName: trimmed);
    }
    return credential;
  }

  /// Returns null if the user cancelled the Google sign-in flow.
  static Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) {
      await _ensureUserProfileDocument(user);
    }
    return userCredential;
  }

  static Future<void> _ensureUserProfileDocument(
    User user, {
    String? preferredName,
  }) async {
    final userRef = _usersCollection.doc(user.uid);
    final snapshot = await userRef.get();

    final trimmedPreferredName = preferredName?.trim();
    final profileName = (trimmedPreferredName != null &&
            trimmedPreferredName.isNotEmpty)
        ? trimmedPreferredName
        : user.displayName;

    if (!snapshot.exists) {
      await userRef.set({
        'name': profileName,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await userRef.set({
      'name': profileName,
      'email': user.email,
    }, SetOptions(merge: true));
  }

  static Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  static Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  static String messageFor(FirebaseAuthException e) => switch (e.code) {
        'invalid-email' => 'Enter a valid email address.',
        'user-disabled' => 'This account has been disabled.',
        'user-not-found' => 'No account found for that email.',
        'wrong-password' || 'invalid-credential' =>
          'Email or password is wrong.',
        'email-already-in-use' => 'That email already has an account.',
        'weak-password' => 'Use at least 6 characters for your password.',
        'operation-not-allowed' => 'Sign-in is not enabled in Firebase.',
        'network-request-failed' => 'Check your connection and try again.',
        _ => e.message ?? 'Authentication failed. Try again.',
      };
}
