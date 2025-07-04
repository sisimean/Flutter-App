// splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'TerminalLoader.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.brown.shade800,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Wrap the Lottie animation in a SizedBox with fixed height to reserve space
            // SizedBox(
            //   width: 200,
            //   height: 200,
            //   child: Lottie.network(
            //     'https://lottie.host/9e1338a0-2f78-4151-8de3-8ca3f2bcd93e/T1S4sU09ja.json',
            //     fit: BoxFit.contain,
            //   ),
            // ),
            // const Text(
            //   'Customer System',
            //   style: TextStyle(
            //     fontSize: 30,
            //     color: Colors.white,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            const SizedBox(height: 10),
            TerminalLoader(),
          ],
        ),
      ),
    );
  }
}
