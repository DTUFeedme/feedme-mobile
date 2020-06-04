import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/models/questionStatistics.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/routes/registeredUserRoute/buildingsList.dart';
import 'package:climify/routes/registeredUserRoute/viewRoomFeedback.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  BluetoothServices _bluetooth = BluetoothServices();
  RestService _restService = RestService();
  String _token;
  List<QuestionStatisticsModel> _roomQuestionStatistics = [];

  @override
  void initState() {
    super.initState();
    _setupState();
  }

  void _setupState() async {
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

  Future<void> _getAndSetRoomFeedbackStats() async {
    List<FeedbackQuestion> questionsOfRoom = [];
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
                  child: Text("Give feedback here"),
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
                  child: Text("View your feedback here"),
                ),
              ),
              Visibility(
                maintainState: true,
                visible: _visibleIndex == 3,
                child: Container(
                  child: BuildingsList(
                    scaffoldKey: _scaffoldKey,
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
    );
  }
}
