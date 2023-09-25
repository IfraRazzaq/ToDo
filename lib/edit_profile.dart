import 'dart:js';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task1/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
  }

  void _saveProfileChanges() async {
    String newEmail = _emailController.text.trim();

    if (newEmail != FirebaseAuth.instance.currentUser?.email) {
      try {
        await FirebaseAuth.instance.currentUser?.updateEmail(newEmail);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({'email': newEmail});

        Navigator.pop(context as BuildContext);
      } catch (e) {
        print('Error updating email: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              style: TextStyle(
                fontSize: 16.0,
              ),
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _saveProfileChanges();
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 30, 92, 143),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
