import 'package:cowtrain/screens/auth/loginscreen.dart';
import 'package:cowtrain/screens/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:cowtrain/constants/theme_constants.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppTheme.spacingXL),
                _buildLogoSection(),
                SizedBox(height: AppTheme.spacingXL),
                _buildContentSection(),
                SizedBox(height: AppTheme.spacingXL * 2),
                _buildButtonsSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.lightBrown.withOpacity(0.1),
          ),
        ),
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.lightBrown.withOpacity(0.15),
          ),
        ),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingM),
              child: Image.asset(
                "assets/images/landingscreen.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Column(
      children: [
        Text(
          "Discover Cow Weight Predictions",
          style: AppTheme.headingLarge.copyWith(
            color: AppTheme.primaryBrown,
            fontSize: 32,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.spacingM),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
          child: Text(
            "Explore all the cow weight prediction tools based on advanced algorithms and easy-to-use features.",
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsSection(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          ),
          style: AppTheme.primaryButton.copyWith(
            minimumSize: MaterialStateProperty.all(
              Size(double.infinity, 56),
            ),
            elevation: MaterialStateProperty.all(2),
          ),
          child: Text(
            "Login",
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: AppTheme.spacingM),
        OutlinedButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignupScreen()),
          ),
          style: AppTheme.secondaryButton.copyWith(
            minimumSize: MaterialStateProperty.all(
              Size(double.infinity, 56),
            ),
            side: MaterialStateProperty.all(
              BorderSide(color: AppTheme.primaryBrown, width: 2),
            ),
          ),
          child: Text(
            "Create Account",
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.primaryBrown,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
