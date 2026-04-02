// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser =>
      FirebaseService.isAvailable ? FirebaseAuth.instance.currentUser : null;

  bool get isSignedIn => currentUser != null;

  Stream<User?> get authStateChanges {
    if (!FirebaseService.isAvailable) return const Stream.empty();
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<User?> signInWithGoogle() async {
    if (!FirebaseService.isAvailable) return null;
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint('[Auth] Signed in: ${result.user?.displayName}');
      return result.user;
    } catch (e) {
      debugPrint('[Auth] Sign in failed: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    if (!FirebaseService.isAvailable) return;
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        FirebaseAuth.instance.signOut(),
      ]);
      debugPrint('[Auth] Signed out');
    } catch (e) {
      debugPrint('[Auth] Sign out error: $e');
    }
  }
}
