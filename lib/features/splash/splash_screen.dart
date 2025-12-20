import 'package:flutter/material.dart';

import '../auth/presentation/sign_in_screen.dart'; // adjust path if needed
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../habits/presentation/habits_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Debug check – you can remove later
    print('Firebase apps: ${Firebase.apps.length}');
    print('FirebaseAuth instance: ${FirebaseAuth.instance}');

    // Wait a bit, then navigate to Sign In
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AuthGate(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // black
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 220, // tweak as needed
            child: Image.asset(
              'lib/assets/Light_Logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
