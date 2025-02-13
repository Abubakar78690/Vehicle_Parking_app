import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_dashboard.dart';
import 'user_dashboard.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyCbXL1d5F0KOia7JHdM9-dw9OnWT3VAl9Q",
        authDomain: "vehicle-parking-manageme-9f3b4.firebaseapp.com",
        projectId: "vehicle-parking-manageme-9f3b4",
        storageBucket: "vehicle-parking-manageme-9f3b4.firebasestorage.app",
        messagingSenderId: "493376948116",
        appId: "1:493376948116:web:eb40b6fb02727ead93f181",
        measurementId: "G-CSQDLPZ263"
    ),
  );

  runApp(ParkingManagementApp());
}
class ParkingManagementApp extends StatelessWidget {
  const ParkingManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: LoginScreen(),
    );
  }
}
