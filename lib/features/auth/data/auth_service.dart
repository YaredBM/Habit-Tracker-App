import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// SIGN UP – creates the auth user and then saves a profile doc in Firestore.
  /// Firestore write is *not* awaited so signup can’t get stuck.
  Future<UserCredential> signUpWithEmailAndUsername({
    required String email,
    required String username,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedUsername = username.trim();
    final usernameLower = trimmedUsername.toLowerCase();

    // Create auth user
    final credential = await _auth.createUserWithEmailAndPassword(
      email: trimmedEmail,
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      // Set display name
      await user.updateDisplayName(trimmedUsername);

      // Save user profile in Firestore (background)
      _saveUserProfile(
        uid: user.uid,
        email: trimmedEmail,
        username: trimmedUsername,
        usernameLower: usernameLower,
      );
    }

    return credential;
  }

  Future<void> _saveUserProfile({
    required String uid,
    required String email,
    required String username,
    required String usernameLower,
  }) async {
    try {
      await _db.collection('users').doc(uid).set(
        {
          'uid': uid,
          'email': email,
          'username': username,
          'usernameLower': usernameLower,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      // Don’t block signup; just log for debugging
      // ignore: avoid_print
      print('Error saving user profile: $e');
    }
  }

  /// SIGN IN – identifier can be *email or username*.
  Future<UserCredential> signInWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    final trimmed = identifier.trim();

    // If it looks like an email, sign in directly with email/password
    if (trimmed.contains('@')) {
      return _auth.signInWithEmailAndPassword(
        email: trimmed,
        password: password,
      );
    }

    // Otherwise treat as username → look up email in Firestore
    final usernameLower = trimmed.toLowerCase();

    final query = await _db
        .collection('users')
        .where('usernameLower', isEqualTo: usernameLower)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for that username.',
      );
    }

    final data = query.docs.first.data();
    final email = data['email'] as String?;

    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-user-data',
        message: 'User data is incomplete.',
      );
    }

    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
