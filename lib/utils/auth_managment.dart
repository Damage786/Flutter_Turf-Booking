import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:uiproject/Screen/Home_page.dart';
import 'package:uiproject/Screen/Login_Page.dart';

class Auth extends StatelessWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Check if authentication state is available and not null
          if (snapshot.hasData && snapshot.data != null) {
            // User is authenticated, navigate to HomePage
            return  HomePage(
             
            );
          } else {
            // User is not authenticated, show LoginPage
            return  const LoginPage();
          }
        },
      ),
    );
  }
}
