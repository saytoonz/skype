import 'package:flutter/material.dart';
import 'package:skype/models/user.dart';
import 'package:skype/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  UserModel _userModel;
  AuthMethods _authMethods = AuthMethods();

  UserModel get getUserModel => _userModel;

  Future<void> refreshUser() async {
    UserModel userM = await _authMethods.getUserDetails();
    _userModel = userM;
    notifyListeners();
  }
}
