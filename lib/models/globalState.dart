import 'package:flutter/material.dart';

class GlobalState extends ChangeNotifier {
  Map globalState = {
    'email': '',
    'token': '',
    'buildingId': '',
  };

  void updateAccount(email, token) {
    globalState['email'] = email;
    globalState['token'] = token;
    notifyListeners();
  }

  void updateBuildingId(buildingId) {
    globalState['buildingId'] = buildingId;
    notifyListeners();
  }
}
