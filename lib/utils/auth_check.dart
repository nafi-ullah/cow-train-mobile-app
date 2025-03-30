import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cowtrain/provider/user_provider.dart';
import 'package:cowtrain/screens/Dashboard.dart';
import 'package:cowtrain/screens/auth/loginscreen.dart';
import 'package:cowtrain/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCheck {
  static Future<Widget> getInitialScreen(BuildContext context) async {
    try {
      final authService = AuthServices();
      final isLoggedIn = await authService.isUserLoggedIn();
      
      if (isLoggedIn) {
        // Get stored user data
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userData = prefs.getString('user_data');
        
        if (userData != null) {
          // Set user data in provider
          Provider.of<UserProvider>(context, listen: false).setUser(userData);
          return DashboardScreen();
        }
      }
      
      return LoginScreen();
    } catch (e) {
      print('Error checking auth status: $e');
      return LoginScreen();
    }
  }
}
