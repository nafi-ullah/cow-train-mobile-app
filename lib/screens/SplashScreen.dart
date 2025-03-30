import 'dart:async';

import 'package:cowtrain/provider/user_provider.dart';
import 'package:cowtrain/screens/Dashboard.dart';
import 'package:cowtrain/screens/auth/landingscreen.dart';
import 'package:cowtrain/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuthAndNavigate();
  }

  Future<void> checkAuthAndNavigate() async {
    try {
      // Wait for splash screen animation
      await Future.delayed(Duration(seconds: 3));
      
      if (!mounted) return;

      final authService = AuthServices();
      final isLoggedIn = await authService.isUserLoggedIn();
      
      if (isLoggedIn) {
        // Get stored user data
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userData = prefs.getString('user_data');
        
        if (userData != null && mounted) {
          // Set user data in provider
          Provider.of<UserProvider>(context, listen: false).setUser(userData);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen())
          );
          return;
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingScreen())
        );
      }
    } catch (e) {
      print('Error during auth check: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingScreen())
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        child: Image.asset(
          "assets/images/splashlogo.gif",
          fit: BoxFit.cover,
        )
      )
    );
  }
}