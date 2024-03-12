import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn() ?? null;
      
      if (googleSignInAccount == null) {
        print('Google sign-in cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Check if the user already exists
      UserCredential? authResult = await _auth.signInWithCredential(credential);

      // Use the null-aware assignment operator '??='

      return authResult.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    print("User Signed Out");
  }
}
