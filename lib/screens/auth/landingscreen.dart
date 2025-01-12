import 'package:cowtrain/screens/auth/loginscreen.dart';
import 'package:cowtrain/screens/auth/signup.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Replace with actual asset
              SizedBox(height: 100),
              Container(
                height: 350,
                width: 350,
                child: Center(
                  child: Image.asset("assets/images/landingscreen.png"),
                ),
              ),
              SizedBox(height: 100),
              Text(
                "Discover Cow Weight Predictions",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 131, 57, 0),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Explore all the cow weight prediction tools based on advanced algorithms and easy-to-use features.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) =>  LoginScreen())
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
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      // Navigate to Register
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) =>  SignupScreen())
                      );
                    },
                    style: TextButton.styleFrom(
                      padding:
                      EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 131, 57, 0),
                      ),
                    ),
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
