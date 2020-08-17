import 'package:climify/models/api_response.dart';
import 'package:climify/models/userModel.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/jwtDecoder.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class SharedPrefsHelper {
  final String tokenKey = "unauthorizedToken";
  final String refreshTokenKey = "refreshToken";
  final String startOnLogin = "alreadyUser";
  final String userToken = "userToken";

  final BuildContext context;

  const SharedPrefsHelper(
    this.context,
  );

  Future<Tuple2<String, String>> getUnauthorizedTokens(
    RestService restService,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String authToken = sharedPreferences.getString(tokenKey);
    String refreshToken = sharedPreferences.getString(refreshTokenKey);
    if (authToken == null || refreshToken == null) {
      APIResponse<Tuple2<String,String>> newUserAPIResponse =
          await restService.postUnauthorizedUser();
      if (!newUserAPIResponse.error) {
        return new Tuple2(newUserAPIResponse.data.item1, newUserAPIResponse.data.item2);
      } else {
        return null;
      }
    } else {
      return new Tuple2(authToken, refreshToken);
    }
  }

  Future<bool> getStartOnLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool startLogin = sharedPreferences.getBool(startOnLogin) ?? false;
    return startLogin;
  }

  Future<void> setStartOnLogin(bool b) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(startOnLogin, b);
    return;
  }

  Future<void> setUserAuthToken(String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(tokenKey, token);
    return;
  }

  Future<void> setUserRefreshToken(String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(refreshTokenKey, token);
    return;
  }
}
