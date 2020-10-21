import 'package:climify/models/api_response.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/models/userModel.dart';
import 'package:climify/services/jwtDecoder.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/sharedPreferences.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/submitButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  int _visibleIndex = 0;
  RestService _restService;
  bool _buttonsActive = true;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SharedPrefsHelper _sharedPrefsHelper;
  String _titleText = "User Login";

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _newEmailController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  FocusNode _newPasswordNode = FocusNode();
  FocusNode _confirmPasswordNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _restService = RestService();
    _sharedPrefsHelper = SharedPrefsHelper();
    _sharedPrefsHelper.setOnLoginScreen(true);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _authUser({bool create = false}) async {
    if (!_buttonsActive) return;

    if (create &&
        _newEmailController.text.trim() == "" &&
        _newPasswordController.text.trim() == "" &&
        _confirmPasswordController.text.trim() == "") return;

    if (!create &&
        _emailController.text.trim() == "" &&
        _passwordController.text.trim() == "") return;
    if (!create && _passwordController.text.isEmpty) {
      SnackBarError.showErrorSnackBar(
        "Please provide a password",
        _scaffoldKey,
      );
      return;
    }

    setState(() {
      _buttonsActive = false;
    });
    APIResponse<UserModel> apiResponse;
    if (create) {
      if (_newPasswordController.text == _confirmPasswordController.text) {
        apiResponse = await _restService.postUser(
            _newEmailController.text, _newPasswordController.text);
      } else {
        apiResponse =
            APIResponse(error: true, errorMessage: "Passwords do not match");
      }
    } else {
      apiResponse = await _restService.loginUser(
          _emailController.text, _passwordController.text);
    }
    if (apiResponse.error) {
      SnackBarError.showErrorSnackBar(apiResponse.errorMessage, _scaffoldKey);
    } else {
      SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
      print("tokens directly");
      print(apiResponse.data.authToken);
      print(apiResponse.data.refreshToken);
      await sharedPrefsHelper.setUserTokens(
          Tuple2(apiResponse.data.authToken, apiResponse.data.refreshToken));
      await _sharedPrefsHelper.setOnLoginScreen(false);
      await _sharedPrefsHelper.setManualLogout(false);
      Navigator.of(context).pushReplacementNamed("registered");
    }
    setState(() {
      _buttonsActive = true;
    });
    return;
  }

  void _changeWindow(int index) {
    String _title;
    switch (index) {
      case 0:
        _title = "User Login";
        break;
      case 1:
        _title = "Create User";
        break;
      default:
        _title = "User Login";
    }
    setState(() {
      _visibleIndex = index;
      _titleText = _title;
    });
  }

  void _gotoUnregistered() {
    _sharedPrefsHelper.setStartOnLogin(false);
    _sharedPrefsHelper.setOnLoginScreen(false);
    Navigator.of(context).pushReplacementNamed("unregistered");
  }

  // void _setupDev() {
  //   _newEmailController.text = "test@test.com";
  //   _newPasswordController.text = "test1234";
  //   _newPasswordConfirmController.text = "test1234";
  // }

  // void _setupDev2() {
  //   _emailController.text = "test@test.com";
  //   _passwordController.text = "test1234";
  // }

  DateTime currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(milliseconds: 1500)) {
      currentBackPressTime = now;
      SnackBarError.showErrorSnackBar(
          "Exit application by pressing the back button again", _scaffoldKey,
          duration: Duration(milliseconds: 1500));
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _titleText,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_open),
            title: Text("Login"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            title: Text("Create User"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_forward),
            title: Text("Skip login"),
          ),
        ],
        onTap: (int index) =>
            index == 2 ? _gotoUnregistered() : _changeWindow(index),
        currentIndex: _visibleIndex,
      ),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Container(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Visibility(
                visible: _visibleIndex == 0,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            "Email:",
                          ),
                          Expanded(
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onEditingComplete: () {
                                if (_emailController.text.isNotEmpty)
                                  FocusScope.of(context).nextFocus();
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Password:",
                          ),
                          Expanded(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              autocorrect: false,
                              textInputAction: TextInputAction.go,
                              onEditingComplete: () {
                                if (_emailController.text.isEmpty) {
                                  FocusScope.of(context).previousFocus();
                                } else {
                                  _authUser();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SubmitButton(
                        text: "Login",
                        onPressed: () => _authUser(),
                      ),
                      // RaisedButton(
                      //   child: Text(
                      //     "asd",
                      //   ),
                      //   onPressed: () => _setupDev2(),
                      // ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _visibleIndex == 1,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            "Email:",
                          ),
                          Expanded(
                            child: TextField(
                              controller: _newEmailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onEditingComplete: () {
                                if (_newEmailController.text.isNotEmpty)
                                  _newPasswordNode.requestFocus();
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Password:",
                          ),
                          Expanded(
                            child: TextField(
                              controller: _newPasswordController,
                              obscureText: true,
                              autocorrect: false,
                              textInputAction: TextInputAction.next,
                              onEditingComplete: () {
                                if (_newPasswordController.text.isNotEmpty)
                                  _confirmPasswordNode.requestFocus();
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Confirm Password:",
                          ),
                          Expanded(
                            child: TextField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              autocorrect: false,
                              textInputAction: TextInputAction.go,
                              onEditingComplete: () => _authUser(create: true),
                            ),
                          ),
                        ],
                      ),
                      SubmitButton(
                        text: "Create User",
                        onPressed: () => _authUser(create: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
