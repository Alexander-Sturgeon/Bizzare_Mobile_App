import 'package:flutter/material.dart';
import 'package:bizzareapp/models/user_model.dart';

class LoginStateProvider extends ChangeNotifier {
  final UserModel _user = UserModel(); //use the model to store user-related data

  UserModel get user => _user; //getter to access the UserModel data

  //method to login. to be called from the login page
  void login(String username, String password) { //values passed from the login page
    if (username == 'user' && password == 'password') {
      _user.isLoggedIn = true;
      _user.errorMessage = '';
    } else {
      _user.isLoggedIn = false;
      _user.errorMessage = 'Invalid credentials';
    }
    notifyListeners(); //notify ui about the state changes
  }
}