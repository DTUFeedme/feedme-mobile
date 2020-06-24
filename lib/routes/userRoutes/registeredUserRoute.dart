import 'package:climify/models/api_response.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/models/questionStatistics.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/routes/dialogues/addBuilding.dart';
import 'package:climify/routes/userRoutes/buildingList.dart';
import 'package:climify/routes/userRoutes/scanHelper.dart';
import 'package:climify/routes/userRoutes/viewRoomFeedback.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/customDialog.dart';
import 'package:climify/widgets/listButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../feedback.dart';
import '../viewAnsweredQuestions.dart';

class RegisteredUserScreen extends StatefulWidget {
  @override
  _RegisteredUserScreenState createState() => _RegisteredUserScreenState();
}

class _RegisteredUserScreenState extends State<RegisteredUserScreen> {
  bool _loadingState = false;
  int _visibleIndex = 0;
  String _title = "Provide feedback";
  String _subtitle = "Room: scanning...";
  RoomModel _room;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<BuildingListState> _buildingListKey =
      GlobalKey<BuildingListState>();
  BluetoothServices _bluetooth = BluetoothServices();
  RestService _restService = RestService();
  String _token;
  String _t;
  List<QuestionStatisticsModel> _roomQuestionStatistics = [];
  TextEditingController _buildingNameTextController = TextEditingController();
  List<FeedbackQuestion> _questions = [];
  ScanHelper _scanHelper;

  @override
  void initState() {
    super.initState();
    _setupState();
  }

  Future<void> _setupState({
    bool forceBuildingRescan = false,
  }) async {
    if (_loadingState) return;

    await Future.delayed(Duration.zero);
    setState(() {
      _loadingState = true;
      _token = Provider.of<GlobalState>(context).globalState['token'];
    });
    _setSubtitle();
    if (!await _bluetooth.isOn) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", _scaffoldKey);
    }
    _scanHelper = ScanHelper(
      _scaffoldKey,
      _token,
    );
    // await Future.delayed(Duration(milliseconds: 500));
    await _scanForRoom(forceBuildingRescan);
    if (_room != null) _getAndSetRoomFeedbackStats("week");
    setState(() {
      _loadingState = false;
    });
    _setSubtitle();
  }

  Future<void> _scanForRoom(bool forceBuildingRescan) async {
    var _scanResults = await _scanHelper.scanBuildingAndRoom(
        resetBuilding: forceBuildingRescan);
    if (!mounted) return;
    setState(() {
      _room = _scanResults.room;
      _questions = _scanResults.questions;
    });
  }

  Future<void> _getActiveQuestions() async {
    List<FeedbackQuestion> questions = await _scanHelper.getActiveQuestions();
    setState(() {
      _questions = questions;
    });
    return;
  }

  Future<void> _getAndSetRoomFeedbackStats(String t) async {
    List<FeedbackQuestion> questionsOfRoom = [];
    setState(() {
      _roomQuestionStatistics = [];
      _t = t;
    });
    APIResponse<List<FeedbackQuestion>> apiResponseQuestionsOfRoom =
        await _restService.getActiveQuestionsByRoom(_room.id, _token, t: _t);
    if (!apiResponseQuestionsOfRoom.error) {
      questionsOfRoom = apiResponseQuestionsOfRoom.data;
      List<QuestionStatisticsModel> roomQuestionStatistics = [];
      questionsOfRoom.forEach((q) async {
        APIResponse<QuestionStatisticsModel> apiResponseQuestionStatistics =
            await _restService.getQuestionStatistics(_token, q, t: _t);
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
      builder: (context) {
        return AddBuilding(
          token: _token,
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
      body: Center(
        child: Container(
          child: Stack(
            children: [
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
                                        itemBuilder: (context, index) =>
                                            ListButton(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FeedbackWidget(
                                                      token: _token,
                                                      question:
                                                          _questions[index],
                                                      room: _room),
                                            ),
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
                visible: _visibleIndex == 1,
                child: Container(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      if (_room != null)
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
                    token: _token,
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
                  ),
                ),
              ),
            ],
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
