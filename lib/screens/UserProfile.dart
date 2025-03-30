import 'package:cowtrain/constants/theme_constants.dart';
import 'package:cowtrain/models/auth_model.dart';
import 'package:cowtrain/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers for the Edit Profile form
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Controllers for the Change Password form
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _farmNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Opens a dialog/bottom sheet to edit the user's profile information.
  void _showEditProfileDialog(User user) {
    // Initialize the controllers with current user info
    _fullNameController.text = user.fullName;
    _emailController.text = user.email;
    _farmNameController.text = user.cattleFarmName;
    _locationController.text = user.location;
    _phoneController.text = user.phoneNumber;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Edit Profile',
            style: AppTheme.modalHeading,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _fullNameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: AppTheme.inputDecoration('Full Name'),
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.black),
                  decoration: AppTheme.inputDecoration('Email'),
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextField(
                  controller: _farmNameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: AppTheme.inputDecoration('Cattle Farm Name'),
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextField(
                  controller: _locationController,
                  style: const TextStyle(color: Colors.black),
                  decoration: AppTheme.inputDecoration('Location'),
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextField(
                  controller: _phoneController,
                  style: const TextStyle(color: Colors.black),
                  decoration: AppTheme.inputDecoration('Phone Number'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: AppTheme.secondaryButton,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: AppTheme.primaryButton,
              onPressed: () => _updateProfile(user),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Opens a dialog/bottom sheet to change the user's password.
  void _showChangePasswordDialog() {
    // Clear existing inputs
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Change Password',
            style: AppTheme.headingMedium,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newPasswordController,
                  decoration: AppTheme.inputDecoration('New Password'),
                  obscureText: true,
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: AppTheme.inputDecoration('Confirm Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: AppTheme.secondaryButton,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: AppTheme.primaryButton,
              onPressed: _changePassword,
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  /// Sends a PUT request to update user profile details.
  Future<void> _updateProfile(User user) async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final farmName = _farmNameController.text.trim();
    final location = _locationController.text.trim();
    final phoneNumber = _phoneController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        farmName.isEmpty ||
        location.isEmpty ||
        phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    try {
      Navigator.of(context).pop(); // close the dialog first

      // Example PUT request (adjust headers & auth as needed)
      final response = await http.put(
        Uri.parse('http://13.233.130.128:8000/users/${user.userid}'), // e.g. 'https://api.example.com/user'
        headers: {
          'Content-Type': 'application/json',
          // Add authorization headers if needed
        },
        body: jsonEncode(user.toMap()
          ..addAll({
            'full_name': fullName,
            'email': email,
            'cattle_farm_name': farmName,
            'location': location,
            'phone_number': phoneNumber,
          }),
        ),
      );

      if (response.statusCode == 200) {
        // Optionally, parse updated user info from response and update provider
        final updatedUserMap = user.toMap()
          ..update('full_name', (_) => fullName)
          ..update('email', (_) => email)
          ..update('cattle_farm_name', (_) => farmName)
          ..update('location', (_) => location)
          ..update('phone_number', (_) => phoneNumber);

        final updatedUser = User.fromMap(updatedUserMap);

        // Update provider so UI refreshes with updated data
        Provider.of<UserProvider>(context, listen: false)
            .setUser(updatedUser.toJson());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text('Failed to update profile. Code: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      // Handle error
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  /// Sends a PUT request to change the user's password.
  Future<void> _changePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields.')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    try {
      Navigator.of(context).pop(); // close the dialog first

      final response = await http.put(
        Uri.parse('YOUR_PUT_ENDPOINT'), // e.g. 'https://api.example.com/user'
        headers: {
          'Content-Type': 'application/json',
        },
        body: '{"password": "$newPassword"}',
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text('Failed to change password. Code: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error changing password: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Profile', style: AppTheme.headingMedium),
        backgroundColor: AppTheme.primaryBrown,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  // Circle Avatar (Placeholder for user image)
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    user.fullName.isEmpty ? 'Full Name' : user.fullName,
                    style: AppTheme.headingMedium,
                  ),
                  Text(
                    user.email.isEmpty ? 'Email' : user.email,
                    style: AppTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Farm',
                        style: AppTheme.bodyMedium,
                      ),
                      Text(
                        user.cattleFarmName,
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Location',
                        style: AppTheme.bodyMedium,
                      ),
                      Text(
                        user.location,
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Phone',
                        style: AppTheme.bodyMedium,
                      ),
                      Text(
                        user.phoneNumber,
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Credit',
                        style: AppTheme.bodyMedium,
                      ),
                      Text(
                        '${user.credit}',
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppTheme.primaryButton,
                onPressed: () => _showEditProfileDialog(user),
                child: const Text('Edit Profile'),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Change Password Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppTheme.primaryButton,
                onPressed: _showChangePasswordDialog,
                child: const Text('Change Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
