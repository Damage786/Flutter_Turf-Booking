import 'package:flutter/material.dart';
import 'package:uiproject/models/authentication.dart';
// import 'package:your_app/auth_service.dart'; // Import your AuthService class

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController _emailController = TextEditingController();
  String _emailError = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              onChanged: (value) {
                setState(() {
                  // Reset error message on change
                  _emailError = '';
                });
              },
              decoration: InputDecoration(
                labelText: 'Enter your email',
                errorText: _emailError.isNotEmpty ? _emailError : null,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String email = _emailController.text.trim();

                // Perform email validation
                if (!_isValidEmail(email)) {
                  setState(() {
                    _emailError = 'Please enter a valid email';
                  });
                  return; // Stop further execution if email is invalid
                }

                // Call your AuthService's method to send the password reset email
                AuthService().sendPasswordResetEmail(email);
                // Optionally, you can show a message indicating that the email has been sent
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password reset email has been sent to $email'),
                  ),
                );
              },
              child: Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to validate email address
  bool _isValidEmail(String email) {
    String emailPattern =
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'; // Regular expression pattern for email validation
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }
}
