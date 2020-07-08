import 'package:climify/models/buildingModel.dart';
import 'package:climify/services/sharedPreferences.dart';
import 'package:flutter/material.dart';

class GlobalState extends ChangeNotifier {
  Map globalState = {
    'email': '',
    'token': '',
    'building': null,
  };

  void updateAccount(String email, String token, BuildContext context) {
    final SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper(context);

    globalState['email'] = email;
    globalState['token'] = token;
    sharedPrefsHelper.setUserToken(token);
    notifyListeners();
  }

  void updateBuilding(BuildingModel building) {
    globalState['building'] = building;
    notifyListeners();
  }
}
