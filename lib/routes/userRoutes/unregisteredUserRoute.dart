import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/userModel.dart';
import 'package:climify/routes/userRoutes/scanHelper.dart';
import 'package:climify/routes/viewAnsweredQuestions.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/sharedPreferences.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/listButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:climify/routes/feedback.dart';
import 'package:tuple/tuple.dart';

class UnregisteredUserScreen extends StatefulWidget {
  const UnregisteredUserScreen({
    Key key,
  }) : super(key: key);

  @override
  _UnregisteredUserScreenState createState() => _UnregisteredUserScreenState();
}

class _UnregisteredUserScreenState extends State<UnregisteredUserScreen> {
  ScanHelper _scanHelper;
  SharedPrefsHelper _sharedPrefsHelper;
  RestService _restService;
  BluetoothServices _bluetooth;
  String _token;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _visibleIndex = 0;
  bool _loadingState = false;
  BuildingModel _building;
  List<FeedbackQuestion> _questions = [];
  RoomModel _room;
  String _title = "Provide feedback";
  String _subtitle = "Room: scanning...";

  @override
  void initState() {
    super.initState();
    _restService = RestService(context);
    _sharedPrefsHelper = SharedPrefsHelper(context);
    _bluetooth = BluetoothServices(context);
    _checkUserStatus();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _checkUserStatus() async {
    bool alreadyUser = await _sharedPrefsHelper.getStartOnLogin();
    if (alreadyUser) {
      _gotoLogin();
    } else {
      await _setupState();
    }
  }

  Future<void> _setupState({
    bool forceBuildingRescan = false,
  }) async {
    Tuple2 tokens =
        await _sharedPrefsHelper.getUnauthorizedTokens(_restService);
    setState(() {
      _token = tokens.item1;
    });

    if (_loadingState) return;

    await Future.delayed(Duration.zero);

    setState(() {
      _loadingState = true;
    });
    _setSubtitle();
    if (!await _bluetooth.isOn) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", _scaffoldKey);
    }
    _scanHelper = ScanHelper(
      context,
      scaffoldKey: _scaffoldKey,
      token: _token,
    );
    Provider.of<GlobalState>(context).updateAccount("no email", tokens.item1, tokens.item2, context);
    Provider.of<GlobalState>(context).updateBuilding(_building);
    await _scanForRoom(forceBuildingRescan);
    setState(() {
      _loadingState = false;
    });
    _setSubtitle();
  }

  Future<void> _scanForRoom(bool forceBuildingRescan) async {
    var _scanResults = await _scanHelper.scanBuildingAndRoom(
        resetBuilding: forceBuildingRescan);
    setState(() {
      _building = _scanResults.building;
      _room = _scanResults.room;
      _questions = _scanResults.questions;
    });
  }

  Future<void> _getActiveQuestions() async {
    RoomModel room;

    APIResponse<RoomModel> apiResponseRoom =
        await _bluetooth.getRoomFromBuilding(_building, _token);
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
      _subtitle = _loadingState
          ? "Room: scanning..."
          : _room == null
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
        title: InkWell(
          onTap: () => _setupState(),
          onLongPress: () => _setupState(forceBuildingRescan: true),
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
              _loadingState
                  ? CircularProgressIndicator(
                      value: null,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Container(),
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
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Container(
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
                          child: _questions != null && _questions.isNotEmpty
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
                                        itemBuilder: (_, index) => ListButton(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    FeedbackWidget(
                                                        token: _token,
                                                        question:
                                                            _questions[index],
                                                        room: _room)),
                                          ),
                                          child: Text(
                                            _questions[index].value,
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
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
                  child: _token != null
                      ? ViewAnsweredQuestionsWidget(
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
      ),
    );
  }
}
