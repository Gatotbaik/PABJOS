import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nyemangati/landing.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully!");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hapus banner debug
     
      home: LandingPage(), // Rute awal adalah halaman login
    );
  }
}
