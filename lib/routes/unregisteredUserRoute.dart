import 'dart:convert';

import 'package:climify/models/globalState.dart';
import 'package:climify/services/sharedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UnregisteredUserScreen extends StatefulWidget {
  @override
  _UnregisteredUserScreenState createState() => _UnregisteredUserScreenState();
}

class _UnregisteredUserScreenState extends State<UnregisteredUserScreen> {
  SharedPrefsHelper _sharedPrefsHelper = SharedPrefsHelper();
  String _authToken;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _visibleIndex = 0;
  String _userId;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  void _checkUserStatus() async {
    bool alreadyUser = await _sharedPrefsHelper.getStartOnLogin();
    if (alreadyUser) {
      _gotoLogin();
    } else {
      String token = await _sharedPrefsHelper.getUnauthorizedUserToken();
      String user = token.split('.')[1];
      List<int> res = base64.decode(base64.normalize(user));
      String s = utf8.decode(res);
      Map map = json.decode(s);
      String userId = map['_id'];
      setState(() {
        _authToken = token;
        _userId = userId;
      });
      Provider.of<GlobalState>(context).updateAccount("", token);
    }
  }

  void _gotoLogin() {
    _sharedPrefsHelper.setStartOnLogin(true);
    Navigator.of(context).pushReplacementNamed("login");
  }

  void _changeWindow(int index) {
    setState(() {
      _visibleIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Not logged in",
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            title: Text("Give feedback"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            title: Text("See feedback"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_open),
            title: Text("Login"),
          ),
        ],
        onTap: (int index) => index == 2 ? _gotoLogin() : _changeWindow(index),
        currentIndex: _visibleIndex,
      ),
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Visibility(
              visible: _visibleIndex == 0,
              child: Container(
                child: Text(
                  "Give Feedback. Token: $_authToken",
                ),
              ),
            ),
            Visibility(
              visible: _visibleIndex == 1,
              child: Container(
                child: Text(
                  "See Feedback. User ID: $_userId",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
