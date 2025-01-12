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
      http.Response res = await http.post(Uri.parse('$uri/login'),
          body: jsonEncode({
            'email': email,
            'password': password
          }),
          headers: <String, String>{
            // "Access-Control-Allow-Origin": "*",
            'Content-Type': 'application/json; charset=UTF-8',
            // 'Accept': '*/*'
          }
      );

      //print(res.body);


//      print(res.body);
      httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () async {
            // log in er por token store kore rakhbo jeno barbar log in krte na hoy

            SharedPreferences prefs = await SharedPreferences.getInstance();
            Provider.of<UserProvider>(context, listen: false).setUser(res.body);
            await prefs.setString('userid', jsonDecode(res.body)['userid']);


            final user = Provider
                .of<UserProvider>(context, listen: false)
                .user;

            print(user.toJson());

            //shared preference a jst token ta thakbe
            Navigator.pushAndRemoveUntil(
                context,
                // generateRoute(
                //     RouteSettings(name: MyHomePage.routeName)
                // ),
                MaterialPageRoute(builder: (context) => DashboardScreen()),
                //same as above
                    (route) => false);
          }
      );
    } catch (e) {
      print(e.toString());
      showSnackBar(context, e.toString());
    }
  }
}