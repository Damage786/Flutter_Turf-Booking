import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uiproject/OAUTH/google.dart';
import 'package:uiproject/Screen/Forgot_password.dart';
import 'package:uiproject/Screen/Home_page.dart';
import 'package:uiproject/models/authentication.dart';
import 'package:uiproject/utils/Button.dart';
import 'package:uiproject/utils/input_filds.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  final GoogleAuth _googleAuth = GoogleAuth();
  bool _isLoadingEmailPassword = false;
  bool _isLoadingGoogle = false;
  bool _isLoadingSignUp = false;

  String _emailError = '';
  String _passwordError = '';

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
          'Log in',
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
            'Login with the following',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
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
                  _isLoadingGoogle = true;
                });
                User? user = await _googleAuth.signInWithGoogle();
                setState(() {
                  _isLoadingGoogle = false;
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
                child: _isLoadingGoogle
                    ? CircularProgressIndicator()
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
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFieldInput(
              hintText: 'email',
              textEditingController: _emailController,
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
              textEditingController: _passwordController,
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

          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordPage(),
                    ),
                  );
                },
                child: const Text('Forgot password'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Button(
            button: 'Log In',
            isLoading: _isLoadingEmailPassword,
            onTap: () async {
              String email = _emailController.text.trim();
              String password = _passwordController.text.trim();
              if (email.isEmpty || password.isEmpty) {
                setState(() {
                  _emailError = 'Fill all the input';
                  _passwordError = '';
                });
              } else {
                setState(() {
                  _isLoadingEmailPassword = true;
                  _emailError = '';
                  _passwordError = '';
                });
                User? user = await _auth.signInWithEmailAndPassword(email, password);
                setState(() {
                  _isLoadingEmailPassword = false;
                });
                if (user != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                } 
              }
            },
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              setState(() {
                _isLoadingSignUp = true;
              });
              // Add your sign-up logic here
              setState(() {
                _isLoadingSignUp = false;
              });
            },
            child: Container(
              child: Center(
                child: _isLoadingSignUp
                    ? CircularProgressIndicator()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('have account'),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.popAndPushNamed(context, '/registration');
                            },
                            child: const Text(
                              'SignUP',
                              style: TextStyle(fontSize:20 ,
                                fontWeight: FontWeight.bold,
                                color: Color(0xfffADD8E6,),
                              ),
                            ),
                          ),
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
