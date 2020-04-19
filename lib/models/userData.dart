import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  Map userData = {
    'email': '',
    'token': '',
  };

  void updateAccount(input) {
    userData = input;
    notifyListeners();
  }
}
