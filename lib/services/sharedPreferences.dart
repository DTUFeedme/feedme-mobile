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
  final String startOnLogin = "alreadyUser";
  final String userToken = "userToken";
  final String userLoginType = "userLoginType";

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
      APIResponse<Tuple2<String, String>> newUserAPIResponse =
          await restService.postUnauthorizedUser();
      if (!newUserAPIResponse.error) {
        await sharedPreferences.setString(
            unregisteredAuthToken, newUserAPIResponse.data.item1);
        await sharedPreferences.setString(
            unregisteredRefreshTokenKey, newUserAPIResponse.data.item2);
        return new Tuple2(
            newUserAPIResponse.data.item1, newUserAPIResponse.data.item2);
      } else {
        return null;
      }
    } else {
      return new Tuple2(unregisteredAuthToken, refreshToken);
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
    // await sharedPreferences.setString(tokenKey, token);
    if (await getStartOnLogin()) {
      await sharedPreferences.setString(tokenKey, token);
    } else {
      await sharedPreferences.setString(unregisteredAuthTokenKey, token);
    }
    return;
  }

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

  // Future<void> setUserTokens(Tuple2<String, String> token) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   await sharedPreferences.setString(tokenKey, token.item1);
  //   await sharedPreferences.setString(refreshTokenKey, token.item2);
  //   print(token.item2);
  //   return;
  // }

  Future<void> setUserRefreshToken(String token) async {
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

  Future<void> setUserLoginType(bool registered) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(userLoginType, registered);
  }
}
