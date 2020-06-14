import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/models/questionStatistics.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/routes/dialogues/addBuilding.dart';
import 'package:climify/routes/registeredUserRoute/buildingList.dart';
import 'package:climify/routes/registeredUserRoute/viewRoomFeedback.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/customDialog.dart';
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
  BuildingModel _building;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<BuildingListState> _buildingListKey =
      GlobalKey<BuildingListState>();
  GlobalKey<BuildingListState> _feedbackListKey =
      GlobalKey<BuildingListState>();
  BluetoothServices _bluetooth = BluetoothServices();
  RestService _restService = RestService();
  String _token;
  List<QuestionStatisticsModel> _roomQuestionStatistics = [];
  TextEditingController _buildingNameTextController = TextEditingController();
  List<FeedbackQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _setupState();
  }

  Future<void> _setupState() async {
    if (_loadingState) return;

    await Future.delayed(Duration.zero);
    setState(() {
      _loadingState = true;
      _token = Provider.of<GlobalState>(context).globalState['token'];
    });
    if (!await _bluetooth.isOn) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", _scaffoldKey);
    }
    await Future.delayed(Duration(milliseconds: 1000));
    if (_building == null) await _getBuildingScan();
    if (_building != null) await _getAndSetRoom();
    if (_room != null) _getAndSetRoomFeedbackStats();
    setState(() {
      _loadingState = false;
    });
    _setSubtitle();
    _getActiveQuestions();
  }

  Future<void> _getBuildingScan() async {
    APIResponse<String> idResponse =
        await _bluetooth.getBuildingIdFromScan(_token);
    if (!idResponse.error) {
      APIResponse<BuildingModel> buildingResponse =
          await _restService.getBuilding(_token, idResponse.data);
      if (!buildingResponse.error) {
        setState(() {
          _building = buildingResponse.data;
        });
      } else {
        SnackBarError.showErrorSnackBar(
            "Failed getting building", _scaffoldKey);
      }
    } else {
      SnackBarError.showErrorSnackBar("Failed getting building", _scaffoldKey);
    }
    return;
  }

  Future<void> _getAndSetRoom() async {
    RoomModel room;
    APIResponse<RoomModel> apiResponse =
        await _bluetooth.getRoomFromBuilding(_building, _token);
    if (!apiResponse.error) {
      room = apiResponse.data;
      setState(() {
        _room = room;
      });
    } else {
      SnackBarError.showErrorSnackBar(apiResponse.errorMessage, _scaffoldKey);
    }
    return;
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
      _room = room;
      _questions = apiResponseQuestions.data;
    });
    print(_questions);
  }

  Future<void> _getAndSetRoomFeedbackStats() async {
    List<FeedbackQuestion> questionsOfRoom = [];
    setState(() {
      _roomQuestionStatistics = [];
    });
    APIResponse<List<FeedbackQuestion>> apiResponseQuestionsOfRoom =
        await _restService.getActiveQuestionsByRoom(_room.id, _token);
    if (!apiResponseQuestionsOfRoom.error) {
      questionsOfRoom = apiResponseQuestionsOfRoom.data;
      List<QuestionStatisticsModel> roomQuestionStatistics = [];

      questionsOfRoom.forEach((q) async {
        APIResponse<QuestionStatisticsModel> apiResponseQuestionStatistics =
            await _restService.getQuestionStatistics(_token, q);
        if (!apiResponseQuestionStatistics.error) {
          roomQuestionStatistics.add(apiResponseQuestionStatistics.data);
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
                  //child: Text("Give feedback here"),
                  child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: _questions.isNotEmpty
                          ? /*Text(
                                _questions[0].value,
                            )*/
                            Container(
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
                                      //return Text("Hej");
                                      return ListTile(
                                        title: Text(_questions[index].value),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => FeedbackWidget (token: _token, question: _questions[index], room: _room)
                                            ),
                                          );
                                        },
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
                visible: _visibleIndex == 1,
                child: Container(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      if (_room != null) await _getAndSetRoomFeedbackStats();
                      await Future.delayed(Duration(milliseconds: 125));
                      _changeWindow(1);
                      return;
                    },
                    child: ViewRoomFeedback(
                      questions: _roomQuestionStatistics,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _visibleIndex == 2,
                child: Container(
                  //child: Text("View your feedback here"),
                    child: ViewAnsweredQuestionsWidget(
                      scaffoldKey: _scaffoldKey,
                      key: _buildingListKey, 
                  ),
                ),
              ),
              Visibility(
                maintainState: true,
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
