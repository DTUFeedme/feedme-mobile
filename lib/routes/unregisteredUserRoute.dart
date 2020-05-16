import 'dart:convert';

import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/models/questionModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/sharedPreferences.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UnregisteredUserScreen extends StatefulWidget {
  @override
  _UnregisteredUserScreenState createState() => _UnregisteredUserScreenState();
}

class _UnregisteredUserScreenState extends State<UnregisteredUserScreen> {
  SharedPrefsHelper _sharedPrefsHelper = SharedPrefsHelper();
  RestService _restService = RestService();
  String _token;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _visibleIndex = 0;
  String _userId;
  BuildingModel _building;
  List<FeedbackQuestion> _questions = [];

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
      _setupState();
    }
  }

  void _setupState() async {
    String token = await _sharedPrefsHelper.getUnauthorizedUserToken();
    String user = token.split('.')[1];
    List<int> res = base64.decode(base64.normalize(user));
    String s = utf8.decode(res);
    Map map = json.decode(s);
    String userId = map['_id'];

    setState(() {
      _token = token;
      _userId = userId;
    });

    // temp solution
    APIResponse<BuildingModel> apiResponse =
        await _restService.getBuilding(_token, "5ea1c600cd42d414a535e2b5");
    if (!apiResponse.error) {
      setState(() {
        _building = apiResponse.data;
      });
    }

    Provider.of<GlobalState>(context).updateAccount("", token);
    Provider.of<GlobalState>(context).updateBuilding(_building);
  }

  void _getActiveQuestions() async {
    RoomModel room;
    BluetoothServices bluetooth = BluetoothServices();

    APIResponse<RoomModel> apiResponseRoom =
        await bluetooth.getRoomFromBuilding(_building, _token);
    if (apiResponseRoom.error) {
      SnackBarError.showErrorSnackBar(
        apiResponseRoom.errorMessage,
        _scaffoldKey,
      );
      return;
    }

    room = apiResponseRoom.data;

    APIResponse<List<FeedbackQuestion>> apiResponseQuestions =
        await _restService.getActiveQuestionsByRoom(room.id, _token);
    if (apiResponseQuestions.error) {
      SnackBarError.showErrorSnackBar(
        apiResponseQuestions.errorMessage,
        _scaffoldKey,
      );
      return;
    }

    setState(() {
      _questions = apiResponseQuestions.data;
    });
    print(_questions);
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
                child: Column(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () => _getActiveQuestions(),
                      child: Text(
                        "Give Feedback. Token: $_token",
                      ),
                    ),
                    Container(
                      child: _questions.isNotEmpty
                          ? Text(
                              _questions[0].value,
                            )
                          : Container(),
                    ),
                  ],
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
