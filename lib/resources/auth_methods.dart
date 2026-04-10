/*import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ✅ needed for kIsWeb
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meetup/utils/utils.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();
  User get user => _auth.currentUser!;

  Future<bool> signInWithGoogle(BuildContext context) async {
    bool res = false;

    try {

      UserCredential userCredential;

      if (kIsWeb) {
        // ✅ WEB: Use Firebase popup sign-in directly
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        userCredential = await _auth.signInWithPopup(googleProvider);

      } else {
        // ✅ MOBILE (Android/iOS): Use GoogleSignIn package
        await GoogleSignIn.instance.initialize(
          serverClientId:
              "1066416141379-luek5jjso4cdrf7jrr8inn4gdiv27hbm.apps.googleusercontent.com",
        );

        final GoogleSignInAccount googleUser =
            await GoogleSignIn.instance.authenticate();
        final GoogleSignInAuthentication googleAuth =
            googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName,
            'uid': user.uid,
            'photoUrl': user.photoURL,
          });
        }
      }

      res = true;

    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
      res = false;
    } catch (e) {
      showSnackBar(context, e.toString());
      res = false;
    }

    return res;
  }

  void signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meetup/utils/constants.dart';
import 'package:meetup/utils/utils.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();

  /// Throws if called when no user is signed in.
  User get user => _auth.currentUser!;

  bool get isGuest => _auth.currentUser?.isAnonymous ?? true;

  // ── Google sign-in ────────────────────────────────────────────────────────

  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        userCredential = await _auth.signInWithPopup(provider);
      } else {
        await GoogleSignIn.instance.initialize(
          serverClientId: AppConstants.googleServerClientId,
        );
        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user != null &&
          (userCredential.additionalUserInfo?.isNewUser ?? false)) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName,
          'uid': user.uid,
          'photoUrl': user.photoURL,
          'isAnonymous': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) showSnackBar(context, e.message ?? 'Sign-in failed');
      return false;
    } catch (e) {
      if (context.mounted) showSnackBar(context, e.toString());
      return false;
    }
  }

  // ── Anonymous / guest sign-in ─────────────────────────────────────────────
  // Using real anonymous auth means currentUser is never null in guest flows,
  // so every currentUser! call in the app is safe.

  Future<bool> signInAsGuest(BuildContext context) async {
    try {
      await _auth.signInAnonymously();
      return true;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.message ?? 'Could not continue as guest');
      }
      return false;
    } catch (e) {
      if (context.mounted) showSnackBar(context, e.toString());
      return false;
    }
  }

  // ── Sign-out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('signOut error: $e');
    }
  }
}