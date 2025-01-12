
import 'package:cowtrain/models/auth_model.dart';
import 'package:flutter/material.dart';


class UserProvider extends ChangeNotifier{
  User _user = User(
      userid: '',
      fullName: '',
      email: '',
      cattleFarmName: '',
      location: '',
      phoneNumber: '',
  );

  User get user => _user; // karon eta private variable

  void setUser(String user){   // provider a save hoise log in data
    // Provider.of<UserProvider>(context, listen: false).setUser(res.body);
    _user = User.fromJson(user);
    notifyListeners();
  }

}