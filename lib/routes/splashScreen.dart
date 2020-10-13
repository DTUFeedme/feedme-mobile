import 'package:climify/services/jwtDecoder.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/sharedPreferences.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SharedPrefsHelper _sharedPrefsHelper;
  RestService _restService;

  @override
  void initState() {
    super.initState();
    _sharedPrefsHelper = SharedPrefsHelper();
    _restService = RestService();
    _nextScreen();
  }

  void _nextScreen() async {
    bool alreadyUser = await _sharedPrefsHelper.getStartOnLogin();
    // await Future.delayed(Duration(milliseconds: 1250));

    if (await _attemptLogin()) return;

    if (alreadyUser) {
      _gotoRegistered();
    } else {
      _gotoUnregistered();
    }
  }

  void _gotoRegistered() {
    _sharedPrefsHelper.setStartOnLogin(true);
    Navigator.of(context).pushReplacementNamed("login");
  }

  void _gotoUnregistered() {
    _sharedPrefsHelper.setStartOnLogin(false);
    Navigator.of(context).pushReplacementNamed("unregistered");
  }

  Future<bool> _attemptLogin() async {
    if (await _sharedPrefsHelper.getManualLogout()) {
      return false;
    }
    // TODO
    // Make a better check than this api call to see if tokens are still functioning
    // This should already take care of expired refresh tokens, as the user is simply prompted to reauth if the refresh token is expired
    // We still have to implement refreshing the refresh token while logged in
    String authToken = await _sharedPrefsHelper.getUserAuthToken();
    if (authToken == null) {
      return false;
    }
    int role = JwtDecoder.parseJwtPayLoad(authToken)['role'];
    if (role == 1) {
      var apiResponse = await _restService.getBuildingsWithAdminRights();
      if (!apiResponse.error) {
        await _sharedPrefsHelper.setOnLoginScreen(false);
        Navigator.of(context).pushReplacementNamed("registered");
        return true;
      }
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          value: null,
        ),
      ),
    );
  }
}
