import 'package:climify/models/buildingModel.dart';
import 'package:flutter/material.dart';

class GlobalState extends ChangeNotifier {
  Map globalState = {
    'email': '',
    'token': '',
    'building': null,
  };

  void updateAccount(String email, String token) {
    globalState['email'] = email;
    globalState['token'] = token;
    notifyListeners();
  }

  void updateBuilding(BuildingModel building) {
    globalState['building'] = building;
    notifyListeners();
  }
}
