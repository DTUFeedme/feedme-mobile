import 'package:climify/services/sharedPreferences.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SharedPrefsHelper _sharedPrefsHelper;

  @override
  void initState() {
    super.initState();
    _sharedPrefsHelper = SharedPrefsHelper();
    _nextScreen();
  }

  void _nextScreen() async {
    bool alreadyUser = await _sharedPrefsHelper.getStartOnLogin();
    // await Future.delayed(Duration(milliseconds: 1250));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(),
    );
  }
}
