import 'package:climify/models/api_response.dart';
import 'package:climify/models/userModel.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/jwtDecoder.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class SharedPrefsHelper {
  final String unregisteredAuthTokenKey = "unauthorizedToken";
  final String unregisteredRefreshTokenKey = "unauthorizedRefreshToken";
  final String tokenKey = "authToken";
  final String registeredRefreshTokenKey = "refreshToken";
  final String startOnLogin = "startOnLogin";
  final String onLoginScreenKey = "onLoginScreen";
  final String manualLogout = "manualLogout";

  const SharedPrefsHelper();

  Future<Tuple2<String, String>> getUnauthorizedTokens(
    RestService restService,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String unregisteredAuthToken =
        sharedPreferences.getString(unregisteredAuthTokenKey);
    String refreshToken =
        sharedPreferences.getString(unregisteredRefreshTokenKey);
    if (unregisteredAuthToken == null || refreshToken == null) {
      print("posting new user");
      APIResponse<Tuple2<String, String>> newUserAPIResponse =
          await restService.postUnauthorizedUser();
      print(newUserAPIResponse.data);
      if (!newUserAPIResponse.error) {
        await sharedPreferences.setString(
            unregisteredAuthTokenKey, newUserAPIResponse.data.item1);
        await sharedPreferences.setString(
            unregisteredRefreshTokenKey, newUserAPIResponse.data.item2);
        return Tuple2(
            newUserAPIResponse.data.item1, newUserAPIResponse.data.item2);
      } else {
        return null;
      }
    } else {
      return Tuple2(unregisteredAuthToken, refreshToken);
    }
  }

  // Future getAll() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   print("getting all tokens");
  //   print(sharedPreferences.getString(unregisteredAuthTokenKey));
  //   print(sharedPreferences.getString(unregisteredRefreshTokenKey));
  //   print(sharedPreferences.getString(tokenKey));
  //   print(sharedPreferences.getString(registeredRefreshTokenKey));
  // }

  Future<bool> _getBool(key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool value = sharedPreferences.getBool(key) ?? false;
    return value;
  }

  Future<void> _setBool(key, b) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(key, b);
    return;
  }

  Future<bool> getManualLogout() async => _getBool(manualLogout);
  Future<void> setManualLogout(bool b) async => _setBool(manualLogout, b);

  Future<bool> getOnLoginScreen() async => _getBool(onLoginScreenKey);
  Future<void> setOnLoginScreen(bool b) async => _setBool(onLoginScreenKey, b);

  Future<bool> getStartOnLogin() async => _getBool(startOnLogin);
  Future<void> setStartOnLogin(bool b) async => _setBool(startOnLogin, b);

  Future<String> getUserAuthToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (await getStartOnLogin()) {
      return sharedPreferences.getString(tokenKey);
    } else {
      return sharedPreferences.getString(unregisteredAuthTokenKey);
    }
    // String token = sharedPreferences.getString(tokenKey);
    // return token;
  }

  Future<void> setUserTokens(Tuple2<String, String> tokens) async {
    await _setUserAuthToken(tokens.item1);
    await _setUserRefreshToken(tokens.item2);
    return;
  }

  Future<void> _setUserAuthToken(String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(tokenKey, token);
    if (!await getStartOnLogin()) {
      await sharedPreferences.setString(unregisteredAuthTokenKey, token);
    }
    return;
  }

  Future<void> _setUserRefreshToken(String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (await getStartOnLogin()) {
      await sharedPreferences.setString(registeredRefreshTokenKey, token);
    } else {
      await sharedPreferences.setString(unregisteredRefreshTokenKey, token);
    }
    return;
  }

  Future<String> getUserRefreshToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token;
    if (await getStartOnLogin()) {
      token = sharedPreferences.getString(registeredRefreshTokenKey);
    } else {
      token = sharedPreferences.getString(unregisteredRefreshTokenKey);
    }
    return token;
  }
}
