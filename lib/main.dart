import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supplier_app/auth/login_screen.dart';
import 'package:supplier_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      home: const LoginScreen(),
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
    ),
  );
}



