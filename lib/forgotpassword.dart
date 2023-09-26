import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  Future<void> _forgotPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController
            .text, // Use emailController.text instead of email.text
      );
      // Password reset email sent successfully.
      print('Password reset email sent to ${emailController.text}');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ForgotPasswordPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 80.0),
            Text(
              'Forgot Password?',
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 30, 92, 143)),
            ),
            SizedBox(height: 60.0),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Enter Email',
                prefixIcon: Icon(Icons.email), // Email icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40.0), // Rounded corners
                ),
              ),
            ),
            SizedBox(height: 60.0),
            Center(
              child: ElevatedButton(
                onPressed: () => _forgotPassword(
                    context), // Use _forgotPassword instead of _sendCode
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 30, 92, 143),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ), // Dark blue button background color
                ),
                child: Text('Send Reset Link'),
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child: TextButton(
                onPressed: () {
                  // Implement your "Resend Link" logic here
                  // You can resend the reset password link or code
                },
                child: Text('Resend Email'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
