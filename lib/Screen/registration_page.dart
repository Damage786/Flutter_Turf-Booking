import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uiproject/OAUTH/google.dart';
import 'package:uiproject/Screen/Home_page.dart';
import 'package:uiproject/Screen/Login_Page.dart';
import 'package:uiproject/models/authentication.dart';
import 'package:uiproject/utils/Button.dart';
import 'package:uiproject/utils/input_filds.dart';

class SignUP extends StatefulWidget {
  const SignUP({Key? key}) : super(key: key);

  @override
  State<SignUP> createState() => _SignUPState();
}

class _SignUPState extends State<SignUP> {
  final TextEditingController _emailcon = TextEditingController();
  final TextEditingController _passcon = TextEditingController();
  final TextEditingController _Confirmpasscon = TextEditingController();

  final GoogleAuth _googleAuth = GoogleAuth();
  final AuthService _auth = AuthService();
  bool _isLoading = false;
  


  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  @override
  void dispose() {
    super.dispose();
    _emailcon.dispose();
    _passcon.dispose();
    _Confirmpasscon.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        title: const Text(
          'SignUp',
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: Container(),
          ),
          const Text(
            'SignUp with the following',
            style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color:Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : Colors.black,),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/apple.png',
                height: 50,
                width: 50,
              ),
            ),
          ),
          const SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  _isLoading = true;
                });
                User? user = await _googleAuth.signInWithGoogle();
                setState(() {
                  _isLoading = false;
                });
                if (user != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sign-in failed. Please try again.'),
                    ),
                  );
                }
              },
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color:Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : Colors.black,),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          'assets/google.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFieldInput(
              hintText: 'email',
              textEditingController: _emailcon,
              textInputType: TextInputType.emailAddress,
              isPass: false,
            ),
          ),
          _emailError.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    _emailError,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : SizedBox(height: 0),

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFieldInput(
              hintText: 'password',
              textEditingController: _passcon,
              textInputType: TextInputType.text,
              isPass: true,
            ),
          ),
          _passwordError.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    _passwordError,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : SizedBox(height: 0),

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFieldInput(
              hintText: 'confirm password',
              textEditingController: _Confirmpasscon,
              textInputType: TextInputType.text,
              isPass: true,
            ),
          ),
          _confirmPasswordError.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    _confirmPasswordError,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : SizedBox(height: 0),

          Button(
            button: 'Sign up',
            isLoading: _isLoading,
            onTap: () async {
              String email = _emailcon.text.trim();
              String password = _passcon.text.trim();
              String confirmPassword = _Confirmpasscon.text.trim();

              RegExp gmailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail.com$');

              if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                setState(() {
                  _emailError = 'Please fill in all fields.';
                  _passwordError = '';
                  _confirmPasswordError = '';
                });
              } else if (password != confirmPassword) {
                setState(() {
                  _emailError = '';
                  _passwordError = '';
                  _confirmPasswordError = 'Passwords do not match. Please try again.';
                });
              } else if (password.length < 6 || confirmPassword.length < 6) {
                setState(() {
                  _emailError = '';
                  _passwordError = 'Password should be at least 6 characters long.';
                  _confirmPasswordError = '';
                });
              } else if (!gmailPattern.hasMatch(email)) {
                setState(() {
                  _emailError = 'Please enter a valid Gmail address.';
                  _passwordError = '';
                  _confirmPasswordError = '';
                });
              } else {
                setState(() {
                  _isLoading = true;
                  _emailError = '';
                  _passwordError = '';
                  _confirmPasswordError = '';
                });

                try {
                  await _auth.registerWithEmailAndPassword(email, password);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                } catch (e) {
                  if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
                    setState(() {
                      _emailError = 'Email is already in use. Please use a different email.';
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('An error occurred. Please try again later.'),
                      ),
                    );
                  }
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
          ),

          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            ),
            child: Container(
              child: const Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('no account'),
                    SizedBox(width: 5),
                    Text(
                      'LogIn',
                      style: TextStyle(fontSize:20 ,
                          fontWeight: FontWeight.bold, color: Color(0xfffADD8E6)),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 140),
        ],
      ),
    );
  }
}
