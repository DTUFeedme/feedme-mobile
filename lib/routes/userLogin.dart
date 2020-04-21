import 'package:climify/models/api_response.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/models/userModel.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  int _visibleIndex = 0;
  RestService _restService = RestService();
  bool _buttonsActive = true;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _newEmailController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _newPasswordConfirmController = TextEditingController();

  Future<void> _authUser({bool create = false}) async {
    if (!_buttonsActive) return;
    if (create &&
        _newEmailController.text.trim() == "" &&
        _newPasswordController.text.trim() == "" &&
        _newPasswordConfirmController.text.trim() == "") return;
    if (!create &&
        _emailController.text.trim() == "" &&
        _passwordController.text.trim() == "") return;
    setState(() {
      _buttonsActive = false;
    });
    APIResponse<UserModel> apiResponse;
    if (create) {
      if (_newPasswordController.text == _newPasswordConfirmController.text) {
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
      Provider.of<GlobalState>(context)
          .updateAccount(apiResponse.data.email, apiResponse.data.authToken);
      Navigator.of(context).pushReplacementNamed("buildings");
    }
    setState(() {
      _buttonsActive = true;
    });
    return;
  }

  void _changeWindow(int index) {
    setState(() {
      _visibleIndex = index;
    });
  }

  void _setupDev() {
    _newEmailController.text = "test@test.com";
    _newPasswordController.text = "test1234";
    _newPasswordConfirmController.text = "test1234";
  }

  void _setupDev2() {
    _emailController.text = "test@test.com";
    _passwordController.text = "test1234";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "User Login",
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_open),
            title: Text("Login"),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), title: Text("Create User"))
        ],
        onTap: (int index) => _changeWindow(index),
        currentIndex: _visibleIndex,
      ),
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Visibility(
              visible: _visibleIndex == 0,
              child: Column(
                children: <Widget>[
                  Text("Login"),
                  Row(
                    children: <Widget>[
                      Text(
                        "Email:",
                      ),
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
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
                        child: _passwordField(
                          controller: _passwordController,
                        ),
                      ),
                    ],
                  ),
                  RaisedButton(
                    child: Text(
                      "Login",
                    ),
                    onPressed: () => _authUser(),
                  ),
                  RaisedButton(
                    child: Text(
                      "Test Input",
                    ),
                    onPressed: () => _setupDev2(),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _visibleIndex == 1,
              child: Column(
                children: <Widget>[
                  Text("Create User"),
                  Row(
                    children: <Widget>[
                      Text(
                        "Email:",
                      ),
                      Expanded(
                        child: TextField(
                          controller: _newEmailController,
                          keyboardType: TextInputType.emailAddress,
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
                        child: _passwordField(
                          controller: _newPasswordController,
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
                        child: _passwordField(
                          controller: _newPasswordConfirmController,
                        ),
                      ),
                    ],
                  ),
                  RaisedButton(
                    child: Text(
                      "Create User",
                    ),
                    onPressed: () => _authUser(create: true),
                  ),
                  RaisedButton(
                    child: Text("test input"),
                    onPressed: () => _setupDev(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextField _passwordField({@required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: true,
      autocorrect: false,
    );
  }
}
