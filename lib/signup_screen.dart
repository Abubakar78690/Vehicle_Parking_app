import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  late AnimationController _animationController;
  late Animation<double> _bouncingAnimation;

  bool isAdmin = false; // Role selection flag

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _bouncingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void handleSignUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String role = isAdmin ? 'admin' : 'user';

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }

    var user = await _authService.signUp(email, password, role);
    if (user != null) {
      Fluttertoast.showToast(msg: "Account Created Successfully!");
      Navigator.pop(context); // Navigate back to Login screen
    } else {
      Fluttertoast.showToast(msg: "Sign-Up Failed. Try Again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/cars_parked.jpg', // Replace with your local image path
            fit: BoxFit.cover,
          ),
          // Semi-transparent Overlay
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated Title
                  AnimatedBuilder(
                    animation: _bouncingAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bouncingAnimation.value),
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          "Park Ease",
                          style: GoogleFonts.pacifico(
                            textStyle: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const Text(
                          "The Ultimate Parking App",
                          style: TextStyle(
                            fontSize: 19,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Input Fields Section
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Email Input
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(Icons.email, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Password Input
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Role Selection Switch
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Sign Up as Admin?",
                                style: TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                              Switch(
                                value: isAdmin,
                                onChanged: (value) {
                                  setState(() {
                                    isAdmin = value;
                                  });
                                },
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Sign-Up Button
                          ElevatedButton(
                            onPressed: handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 18.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                            ),
                            child: const Text(
                              "SIGN UP",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Back to Login Option
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Navigate back to Login
                    },
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
