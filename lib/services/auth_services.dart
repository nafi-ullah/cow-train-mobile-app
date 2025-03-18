import 'dart:convert';

import 'package:cowtrain/constants.dart';
import 'package:cowtrain/constants/error_handling.dart';
import 'package:cowtrain/models/auth_model.dart';
import 'package:cowtrain/provider/user_provider.dart';
import 'package:cowtrain/screens/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/auth/loginscreen.dart';

class AuthServices {

  void signUpUser({
    required BuildContext context,
    required String full_name,
    required String email,
    required String password
  }) async {
    try {
      User user = User(
        userid: '',
        fullName: '',
        email: '',
        cattleFarmName: '',
        location: '',
        phoneNumber: '',
        credit: 0
      );

      http.Response res = await http.post(Uri.parse('$uri/users'),
          body: user.toJson(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',

          }
      );
      print("Sign up info");
      print(res.body);


      httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            //print("Account opened");
            showSnackBar(context,
                'Account created! Log in with same email and password');
          }
      );
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Try again with right information")));
    }
  }

  // Method to check if user is logged in
  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    return userData != null;
  }

  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      print('Requesting: $uri/login');

      http.Response res = await http.post(
        Uri.parse('$uri/login'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Status Code: ${res.statusCode}');
      print('Response Body: ${res.body}');

      if (res.statusCode == 307) {
        String? redirectUrl = res.headers['location'];
        if (redirectUrl != null) {
          print('Redirecting to: $redirectUrl');
          res = await http.post(
            Uri.parse(redirectUrl),
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
          );
        } else {
          throw Exception('Redirect location not found');
        }
      }

      if (res.statusCode == 200) {
        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            // Store complete user data
            await prefs.setString('user_data', res.body);
            Provider.of<UserProvider>(context, listen: false).setUser(res.body);

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
              (route) => false,
            );
          },
        );
      } else {
        showSnackBar(context, 'Failed with status code: ${res.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      showSnackBar(context, e.toString());
    }
  }

  // Method to handle logout
  Future<void> logout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all stored data
      Provider.of<UserProvider>(context, listen: false).clearUser();
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Error during logout: $e');
      showSnackBar(context, 'Error during logout');
    }
  }
}