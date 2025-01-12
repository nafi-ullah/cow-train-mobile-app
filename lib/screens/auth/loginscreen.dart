import 'package:cowtrain/screens/Dashboard.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Placeholder for asset
              Image.asset(
                "assets/images/landingscreen.png",
                height: 200,
                width: 200,
              ),
              SizedBox(height: 30),
              Text(
                "Login here",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 131, 57, 0),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Welcome back you’ve been missed!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Forgot Password Functionality
                  },
                  child: Text(
                    "Forgot your password?",
                    style: TextStyle(color: const Color.fromARGB(255, 131, 57, 0)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Sign In Functionality
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>  DashboardScreen())
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 131, 57, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                  EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: Text(
                  "Sign in",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navigate to Create Account
                },
                child: Text(
                  "Create new account",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Or continue with",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      // Google Sign-In
                    },
                    icon: Icon(Icons.g_mobiledata),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      // Facebook Sign-In
                    },
                    icon: Icon(Icons.facebook),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      // Apple Sign-In
                    },
                    icon: Icon(Icons.apple),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
