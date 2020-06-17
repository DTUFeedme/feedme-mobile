import 'dart:convert';

import 'package:climify/models/answerOption.dart';
import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/routes/viewAnsweredQuestions.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/sharedPreferences.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:climify/routes/feedback.dart';

class UnregisteredUserScreen extends StatefulWidget {
  const UnregisteredUserScreen({
    Key key,
  }) : super(key: key);

  @override
  _UnregisteredUserScreenState createState() => _UnregisteredUserScreenState();
}

class _UnregisteredUserScreenState extends State<UnregisteredUserScreen> {
  SharedPrefsHelper _sharedPrefsHelper = SharedPrefsHelper();
  RestService _restService = RestService();
  String _token;
  GlobalKey<ScaffoldState> _scaffoldKey;
  GlobalKey<ViewAnsweredQuestionsWidgetState> _feedbackListKey =
  GlobalKey<ViewAnsweredQuestionsWidgetState>();
  int _visibleIndex = 0;
  String _userId;
  BuildingModel _building;
  List<FeedbackQuestion> _questions = [];
  RoomModel _room;
  String _title = "Provide feedback";
  String _subtitle = "Room: scanning...";

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
      await _setupState();
      _getActiveQuestions();
    }
  }

  Future<void> _setupState() async {
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

  Future<void> _getActiveQuestions() async {
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

    //room = RoomModel("5ecce5fecd42d414a535e4b9", "Living Room");
    
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
      _room = room;
      _setSubtitle();
    });
  }

  void _gotoLogin() {
    _sharedPrefsHelper.setStartOnLogin(true);
    Navigator.of(context).pushReplacementNamed("login");
  }

  void _setSubtitle() {
    setState(() {
      _subtitle = _room == null
          ? "Failed scanning room, tap to retry"
          : "Room: ${_room.name}";
    });
  }

  void _changeWindow(int index) {
    setState(() {
      _visibleIndex = index;
      _setSubtitle();
      switch (index) {
        case 0:
          _title = "Give feedback";
          break;
        case 1:
          _title = "View your feedback";
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: InkWell(
          onTap: () => _getActiveQuestions(),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _title,
                    ),
                    Text(
                      _subtitle,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                    Expanded(
                      child: Container(
                        child: _questions.isNotEmpty
                          ? Container(
                              child: RefreshIndicator(
                                onRefresh: () => _getActiveQuestions(),
                                child: Container(
                                  child: ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    itemCount: _questions.length,
                                    itemBuilder: (_, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(),
                                          ),
                                        ),
                                        child: Material(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => FeedbackWidget(token: _token, question: _questions[index], room: _room)
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                              child: Text(
                                                _questions[index].value,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              maintainState: true,
              visible: _visibleIndex == 1,
              child: Container(
                child: _token != null ? 
                  ViewAnsweredQuestionsWidget(
                    scaffoldKey: _scaffoldKey,
                    token: _token,
                    user: "me",
                  )
                : Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
