import 'package:climify/models/buildingModel.dart';
import 'package:climify/services/sharedPreferences.dart';
import 'package:flutter/material.dart';

class GlobalState extends ChangeNotifier {
  Map globalState = {
    'email': '',
    'authToken': '',
    'refreshToken': '',
    'building': null,
  };

  void updateAccount(String email, String authToken, String refreshToken, BuildContext context) {
    final SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper(context);

    globalState['email'] = email;
    globalState['authToken'] = authToken;
    globalState['refreshToken'] = refreshToken;
    sharedPrefsHelper.setUserAuthToken(authToken);
    sharedPrefsHelper.setUserRefreshToken(refreshToken);
    
    notifyListeners();
  }

  void updateBuilding(BuildingModel building) {
    globalState['building'] = building;
    notifyListeners();
  }
}
