import 'package:cowtrain/screens/Dashboard.dart';
import 'package:cowtrain/screens/auth/signup.dart';
import 'package:cowtrain/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:cowtrain/constants/theme_constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  final AuthServices authService = AuthServices();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void login() {
    authService.signInUser(
        context: context,
        email: emailController.text,
        password: passwordController.text);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  "assets/images/landingscreen.png",
                  height: 180,
                  width: 180,
                ),
                SizedBox(height: AppTheme.spacingL),
                Text(
                  "Welcome Back",
                  style: AppTheme.headingLarge.copyWith(color: AppTheme.primaryBrown),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacingS),
                Text(
                  "Welcome back you've been missed!",
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacingXL),
                TextField(
                  controller: emailController,
                  style: TextStyle(color: Colors.black),
                  decoration: AppTheme.inputDecoration("Email")
                      .copyWith(prefixIcon: Icon(Icons.email, color: AppTheme.primaryBrown)),
                ),
                SizedBox(height: AppTheme.spacingM),
                TextField(
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  controller: passwordController,
                  decoration: AppTheme.inputDecoration("Password")
                      .copyWith(prefixIcon: Icon(Icons.lock, color: AppTheme.primaryBrown)),
                ),
                SizedBox(height: AppTheme.spacingS),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Forgot Password Functionality
                    },
                    child: Text(
                      "Forgot your password?",
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryBrown),
                    ),
                  ),
                ),
                SizedBox(height: AppTheme.spacingM),
                ElevatedButton(
                  onPressed: login,
                  style: AppTheme.primaryButton,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                    child: Text("Sign In", style: AppTheme.bodyLarge.copyWith(color: Colors.white)),
                  ),
                ),
                SizedBox(height: AppTheme.spacingM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupScreen()),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
