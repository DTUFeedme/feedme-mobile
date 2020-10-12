import 'package:climify/models/api_response.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/questionStatistics.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/routes/dialogues/addBuilding.dart';
import 'package:climify/routes/userRoutes/buildingList.dart';
import 'package:climify/routes/userRoutes/viewRoomFeedback.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/send_receive_location.dart';
import 'package:climify/services/sharedPreferences.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/customDialog.dart';
import 'package:climify/widgets/listButton.dart';
import 'package:climify/widgets/questionList.dart';
import 'package:climify/widgets/scanAppBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../feedback.dart';
import '../viewAnsweredQuestions.dart';

class RegisteredUserScreen extends StatefulWidget {
  @override
  _RegisteredUserScreenState createState() => _RegisteredUserScreenState();
}

class _RegisteredUserScreenState extends State<RegisteredUserScreen> {
  int _visibleIndex = 0;
  String _title = "Provide feedback";
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<BuildingListState> _buildingListKey =
      GlobalKey<BuildingListState>();
  BluetoothServices _bluetooth;
  RestService _restService;
  String _t;
  List<QuestionStatisticsModel> _roomQuestionStatistics = [];
  TextEditingController _buildingNameTextController = TextEditingController();
  Future<void> _gettingRoom = Future.delayed(Duration.zero);

  @override
  void initState() {
    super.initState();
    _restService = RestService();
    _bluetooth = BluetoothServices();
    _setupState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _setupState({
    bool forceBuildingRescan = false,
  }) async {
    UpdateLocation updateLocation =
        Provider.of<UpdateLocation>(context, listen: false);
    bool _loadingState = updateLocation.scanning;
    if (_loadingState) return;

    await Future.delayed(Duration.zero);
    setState(() {
      _loadingState = true;
    });
    if (!await _bluetooth.isOn) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", _scaffoldKey);
    }
    _getAndSetRoom();
  }

  Future<void> _getAndSetRoom() async {
    UpdateLocation updateLocation =
        Provider.of<UpdateLocation>(context, listen: false);
    if (updateLocation.scanning) {
      return;
    }

    if (!await _bluetooth.isOn) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", _scaffoldKey);
      return;
    }

    await updateLocation.sendReceiveLocation();
    _getActiveQuestions();
  }

  Future<void> _getActiveQuestions() async {
    UpdateLocation updateLocation =
        Provider.of<UpdateLocation>(context, listen: false);
    await updateLocation.updateQuestions();
    return;
  }

  Future<void> _getAndSetRoomFeedbackStats(String t) async {
    UpdateLocation updateLocation =
        Provider.of<UpdateLocation>(context, listen: false);
    List<FeedbackQuestion> questionsOfRoom = [];
    setState(() {
      _roomQuestionStatistics = [];
      _t = t;
    });
    RoomModel _room = updateLocation.room;
    // APIResponse<List<FeedbackQuestion>> apiResponseQuestionsOfRoom =
    //     await _restService.getActiveQuestionsByRoom(_room.id, _token, t: _t);
    if (_room == null) return;
    APIResponse<List<FeedbackQuestion>> apiResponseQuestionsOfRoom =
        await _restService.getActiveQuestionsByRoom(_room.id, _t);
    if (!apiResponseQuestionsOfRoom.error) {
      questionsOfRoom = apiResponseQuestionsOfRoom.data;
      List<QuestionStatisticsModel> roomQuestionStatistics = [];
      questionsOfRoom.forEach((q) async {
        APIResponse<QuestionStatisticsModel> apiResponseQuestionStatistics =
            await _restService.getQuestionStatistics(q, _t);
        if (!apiResponseQuestionStatistics.error) {
          roomQuestionStatistics.add(apiResponseQuestionStatistics.data);
          roomQuestionStatistics.sort((q1, q2) =>
              Comparable.compare(q1.question.value, q2.question.value));
          setState(() {
            _roomQuestionStatistics = roomQuestionStatistics;
          });
        }
      });

      return;
    }
  }

  void _changeWindow(int index) {
    setState(() {
      _visibleIndex = index;
      switch (index) {
        case 0:
          _title = "Give feedback";
          break;
        case 1:
          _title = "View room feedback";
          break;
        case 2:
          _title = "View your feedback";
          break;
        case 3:
          _title = "Administrate buildings";
          break;
        default:
      }
    });
  }

  void _addBuilding() async {
    await showDialogModified<bool>(
      barrierColor: Colors.black12,
      context: context,
      builder: (_) {
        return AddBuilding(
          context,
          textEditingController: _buildingNameTextController,
          scaffoldKey: _scaffoldKey,
        ).dialog;
      },
    ).then((value) {
      setState(() {
        _buildingNameTextController.text = "";
      });
      if (value ?? false) {
        _buildingListKey.currentState.getBuildings();
      }
    });
  }

  DateTime currentBackPressTime;

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(milliseconds: 1500)) {
      currentBackPressTime = now;
      SnackBarError.showErrorSnackBar(
          "Log out by pressing the back button again", _scaffoldKey,
          duration: Duration(milliseconds: 1500));
      return Future.value(false);
    }
    SharedPrefsHelper _sharedPrefsHelper = SharedPrefsHelper();
    await _sharedPrefsHelper.setManualLogout(true);
    Navigator.of(context).pushReplacementNamed('login');
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: scanAppBar(_getAndSetRoom, _title),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Center(
          child: Container(
            child: Stack(
              children: [
                Visibility(
                  visible: _visibleIndex == 0,
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: QuestionList(
                            getActiveQuestions: _getActiveQuestions,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: _visibleIndex == 1,
                  child: Container(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        UpdateLocation updateLocation =
                            Provider.of<UpdateLocation>(context, listen: false);
                        if (updateLocation.room != null)
                          await _getAndSetRoomFeedbackStats("week");
                        await Future.delayed(Duration(milliseconds: 125));
                        _changeWindow(1);
                        return;
                      },
                      child: ViewRoomFeedback(
                        questions: _roomQuestionStatistics,
                        dateFilter: _t,
                        refreshQuestions: _getAndSetRoomFeedbackStats,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _visibleIndex == 2,
                  child: Container(
                    child: ViewAnsweredQuestionsWidget(
                      scaffoldKey: _scaffoldKey,
                      user: "me",
                    ),
                  ),
                ),
                Visibility(
                  // maintainState: true,
                  visible: _visibleIndex == 3,
                  child: Container(
                    child: BuildingList(
                      scaffoldKey: _scaffoldKey,
                      key: _buildingListKey,
                      gettingRoom: _gettingRoom,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            title: Text("Give feedback"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.room),
            title: Text("See room feedback"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            title: Text("See your feedback"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Manage buildings"),
          ),
        ],
        onTap: (int index) => _changeWindow(index),
        currentIndex: _visibleIndex,
      ),
      floatingActionButton: _visibleIndex == 3
          ? FloatingActionButton(
              child: Icon(
                Icons.add,
              ),
              onPressed: () => _addBuilding(),
            )
          : Container(),
    );
  }
}
