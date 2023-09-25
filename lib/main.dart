import 'package:flutter/material.dart';
import 'package:task1/forgotpassword.dart';
import 'package:task1/home.dart';
import 'package:task1/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task1/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(await checkUserLoggedIn() ? TodoApp() : LoginApp());
}

Future<bool> checkUserLoggedIn() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user != null;
}
