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
      credit: 0
  );

  User get user => _user; // karon eta private variable

  void setUser(String user){   // provider a save hoise log in data
    // Provider.of<UserProvider>(context, listen: false).setUser(res.body);
    _user = User.fromJson(user);
    notifyListeners();
  }

  void updateCredit(int newCredit) {
    _user = User(
      userid: _user.userid,
      fullName: _user.fullName,
      email: _user.email,
      cattleFarmName: _user.cattleFarmName,
      location: _user.location,
      phoneNumber: _user.phoneNumber,
      credit: newCredit, // Update credit field
    );
    notifyListeners();
  }

  void clearUser() {
    _user = User(
      userid: '',
      fullName: '',
      email: '',
      cattleFarmName: '',
      location: '',
      phoneNumber: '',
      credit: 0
    );
    notifyListeners();
  }
}