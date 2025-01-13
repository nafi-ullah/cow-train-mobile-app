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

  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // Ensure the URI is correct
      print('Requesting: $uri/login');

      // Initial request
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

      // Debugging response
      print('Status Code: ${res.statusCode}');
      print('Response Body: ${res.body}');

      if (res.statusCode == 307) {
        // Handle redirect by fetching the "location" header
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
          print('Redirect Response Status Code: ${res.statusCode}');
          print('Redirect Response Body: ${res.body}');
        } else {
          throw Exception('Redirect location not found');
        }
      }

      if (res.statusCode == 200) {
        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () async {
            // Parse response and handle user data
            SharedPreferences prefs = await SharedPreferences.getInstance();
            Provider.of<UserProvider>(context, listen: false).setUser(res.body);
            await prefs.setString('userid', jsonDecode(res.body)['userid']);

            final user = Provider.of<UserProvider>(context, listen: false).user;
            print('User Data: ${user.toJson()}');

            // Navigate to Dashboard
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


}