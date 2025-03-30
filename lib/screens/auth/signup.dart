import 'package:cowtrain/constants.dart';
import 'package:cowtrain/screens/Dashboard.dart';
import 'package:cowtrain/screens/auth/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cowtrain/constants/theme_constants.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signup() async {
    if (!_validateInputs()) return;

    final String fullName = _fullNameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String farmName = _farmNameController.text;
    final String location = _locationController.text;
    final String phone = _phoneController.text;

    final url = Uri.parse('$uri/users');
    final body = jsonEncode({
      "full_name": fullName,
      "email": email,
      "password": password,
      "cattle_farm_name": farmName,
      "location": location,
      "phone_number": phone
    });

    setState(() => _isLoading = true);

    try {
      http.Response response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 307) {
        String? redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          response = await http.post(
            Uri.parse(redirectUrl),
            headers: {'Content-Type': 'application/json'},
            body: body,
          );
        }
      }

      if (response.statusCode == 200) {
        _showSuccessMessage();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen())
        );
      } else {
        _showErrorMessage("Signup failed: ${response.body}");
      }
    } catch (e) {
      _showErrorMessage("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateInputs() {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _farmNameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      _showErrorMessage("Please fill in all fields");
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      _showErrorMessage("Please enter a valid email address");
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showErrorMessage("Password must be at least 6 characters long");
      return false;
    }
    return true;
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Signup successful!"),
      backgroundColor: AppTheme.darkGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

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
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBrown.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      "assets/images/landingscreen.png",
                      height: 100,
                      width: 100,
                    ),
                  ),
                ),
                SizedBox(height: AppTheme.spacingL),
                Text(
                  "Create Account",
                  style: AppTheme.headingLarge.copyWith(color: AppTheme.primaryBrown),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacingS),
                Text(
                  "Start managing your cattle farm today!",
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacingXL),
                _buildInputField(
                  controller: _fullNameController,
                  label: "Full Name",
                  icon: Icons.person_outline,
                ),
                SizedBox(height: AppTheme.spacingM),
                _buildInputField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: AppTheme.spacingM),
                _buildInputField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                SizedBox(height: AppTheme.spacingM),
                _buildInputField(
                  controller: _farmNameController,
                  label: "Farm Name",
                  icon: Icons.business_outlined,
                ),
                SizedBox(height: AppTheme.spacingM),
                _buildInputField(
                  controller: _locationController,
                  label: "Location",
                  icon: Icons.location_on_outlined,
                ),
                SizedBox(height: AppTheme.spacingM),
                _buildInputField(
                  controller: _phoneController,
                  label: "Phone Number",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: AppTheme.spacingL),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: AppTheme.primaryButton,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Create Account",
                            style: AppTheme.bodyLarge.copyWith(color: Colors.white),
                          ),
                  ),
                ),
                SizedBox(height: AppTheme.spacingM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: AppTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      ),
                      child: Text(
                        "Sign In",
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? (obscureText ?? true) : false,
        keyboardType: keyboardType,
        style: AppTheme.bodyMedium,
        decoration: AppTheme.inputDecoration(label).copyWith(
          prefixIcon: Icon(icon, color: AppTheme.primaryBrown),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ?? true ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppTheme.primaryBrown,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.lightBrown.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryBrown, width: 2),
          ),
        ),
      ),
    );
  }
}
