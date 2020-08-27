import 'dart:async';

import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/routes/dialogues/addRoom.dart';
import 'package:climify/routes/dialogues/roomMenu.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/customDialog.dart';
import 'package:climify/widgets/listButton.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'dialogues/scanRoom.dart';
import 'dialogues/addQuestion.dart';
import 'dialogues/questionMenu.dart';

class BuildingManager extends StatefulWidget {
  @override
  _BuildingManagerState createState() => _BuildingManagerState();
}

class _BuildingManagerState extends State<BuildingManager> {
  BluetoothServices _bluetooth;
  RestService _restService;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<RefreshIndicatorState> _refreshBeaconKey =
      GlobalKey<RefreshIndicatorState>();
  //GlobalKey<State> _dialogKey = GlobalKey<State>();
  BuildingModel _building = BuildingModel('', '', []);
  List<FeedbackQuestion> _questionsRealList = [];
  List<FeedbackQuestion> _questions = [];
  TextEditingController _newRoomNameController = TextEditingController();
  List<Tuple2<String, int>> _beacons = [];
  bool _scanningSignalMap = false;
  bool _gettingBeacons = false;
  int _signalMapScans = 0;
  // SignalMap _signalMap;
  String _currentlyConfirming = "";
  int _visibleIndex = 0;
  String _title = "Manage rooms";
  final myController = TextEditingController();
  final _questionNameController = TextEditingController();
  final _questionAnswerOptionsController = TextEditingController();
  List<TextEditingController> controllerList = [];
  bool _scanningBeacons = false;

  @override
  void initState() {
    super.initState();
    _bluetooth = BluetoothServices();
    _restService = RestService();
    _setBuildingState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    _newRoomNameController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _setBuildingState() async {
    await Future.delayed(Duration.zero);
    BuildingModel argBuilding = ModalRoute.of(context).settings.arguments;
    setState(() {
      _building = argBuilding;
    });
    _questions = [];
    _updateQuestions();
    _updateBuilding();
  }

  Future<void> _updateBuilding() async {
    APIResponse<BuildingModel> apiResponseBuilding =
        await _restService.getBuilding(_building.id);
    if (apiResponseBuilding.error == false) {
      BuildingModel building = apiResponseBuilding.data;
      setState(() {
        _building = building;
      });
    }
    return;
  }

  Future<void> _updateBeacons() async {
    if (_gettingBeacons) return;

    setState(() {
      _gettingBeacons = true;
      _beacons = [];
    });

    _bluetooth.getNearbyBeaconData().listen((event) {
      setState(() {
        _beacons = event;
      });
    });

    // FlutterBlue does not properly close streams, so this duration will have to match the timeout
    // found in the bluetooth.dart function getNearbyBeaconData
    await Future.delayed(Duration(milliseconds: 3750));

    setState(() {
      _gettingBeacons = false;
    });
    return;
  }

  Future<void> _updateQuestions() async {
    _questions = [];
    for (int i = 0; i < _building.rooms.length; i++) {
      APIResponse<List<FeedbackQuestion>> apiResponseBuilding =
          await _restService.getAllQuestionsByRoom(_building.rooms[i].id);
      if (apiResponseBuilding.error == false) {
        setState(() {
          List<FeedbackQuestion> question = apiResponseBuilding.data;
          for (int j = 0; j < question.length; j++) {
            if (!_questions.any((item) => item.id == question[j].id)) {
              _questions.add(question[j]);
            }
          }
          _questionsRealList = _questions;
          //_questionsRealList = question;
          controllerList = [];
        });
      }
    }
    return;
  }

  void _updateBuildingAndAddScan() async {
    await _updateBuilding();
    _addScans(_building.rooms.last);
  }

  void _addQuestion() async {
    await showDialogModified(
      barrierColor: Colors.black12,
      context: context,
      builder: (_) {
        return AddQuestion(
          context,
          textEditingController: _questionNameController,
          controllerList: controllerList,
          building: _building,
          scaffoldKey: _scaffoldKey,
        ).dialog;
      },
    ).then((value) {
      setState(() {
        _questionNameController.text = "";
        _questionAnswerOptionsController.text = "";
        controllerList = [];
      });
      //if (value ?? false) {
      _updateQuestions();
      //}
    });
  }

  void _addRoom() async {
    await showDialogModified<bool>(
      barrierColor: Colors.black12,
      context: context,
      builder: (_) {
        return AddRoom(
          context,
          textEditingController: _newRoomNameController,
          building: _building,
          scaffoldKey: _scaffoldKey,
        ).dialog;
      },
    ).then((value) {
      setState(() {
        _newRoomNameController.text = "";
      });
      if (value ?? false) {
        _updateBuildingAndAddScan();
      }
    });
  }

  void _addScans(RoomModel room) async {
    setState(() {
      _scanningSignalMap = false;
      _signalMapScans = 0;
    });
    if (!await _bluetooth.isOn) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", _scaffoldKey);
      return;
    }
    await showDialogModified(
      barrierColor: Colors.black12,
      context: context,
      builder: (_) {
        return ScanRoom(
          context,
          room: room,
          building: _building,
          scaffoldKey: _scaffoldKey,
          setScanning: (b) => setState(() {
            _scanningSignalMap = b;
          }),
          incrementScans: () => setState(() {
            _signalMapScans++;
          }),
          getScanning: () => _scanningSignalMap,
          getNumberOfScans: () => _signalMapScans,
        ).dialog;
      },
    );
  }

  void _roomMenu(RoomModel room) async {
    await showDialogModified(
      barrierColor: Colors.black12,
      context: context,
      builder: (_) {
        return RoomMenu(
          context,
          room: room,
          building: _building,
          scaffoldKey: _scaffoldKey,
          addScans: _addScans,
          setCurrentlyConfirming: (s) => setState(() {
            _currentlyConfirming = s;
          }),
          getCurrentlyConfirming: () => _currentlyConfirming,
        ).dialog;
      },
    ).then((value) {
      setState(() {
        _currentlyConfirming = "";
      });
      _updateBuilding();
    });
  }

  void _questionMenu(FeedbackQuestion question) async {
    await showDialogModified(
      barrierColor: Colors.black12,
      context: context,
      builder: (_) {
        return QuestionMenu(
          context,
          question: question,
          scaffoldKey: _scaffoldKey,
          setCurrentlyConfirming: (s) => setState(() {
            _currentlyConfirming = s;
          }),
          getCurrentlyConfirming: () => _currentlyConfirming,
        ).dialog;
      },
    ).then((value) {
      setState(() {
        _currentlyConfirming = "";
        controllerList = [];
      });
      _updateQuestions();
    });
  }

  void _getUserIdFromEmailFunc(String _email) async {
    setState(() {});
    String userId;
    APIResponse<String> apiResponse =
        await _restService.getUserIdFromEmail(_email);
    if (apiResponse.error) {
      SnackBarError.showErrorSnackBar(apiResponse.errorMessage, _scaffoldKey);
    } else {
      userId = apiResponse.data;
    }
    setState(() {});
    if (userId != null) {
      _makeUserAdmin(userId, _email);
    } else {
      SnackBarError.showErrorSnackBar(
          "No user found with email: $_email", _scaffoldKey);
    }
  }

  void _makeUserAdmin(String _userId, String _email) async {
    APIResponse<bool> apiResponse =
        await _restService.patchUserAdmin(_userId, _building);
    if (apiResponse.error) {
      SnackBarError.showErrorSnackBar(apiResponse.errorMessage, _scaffoldKey);
    } else {
      SnackBarError.showErrorSnackBar(
          _email + " is now admin of building: " + _building.name,
          _scaffoldKey);
    }
  }

  String _getSignalStrengthString(int rssi) {
    if (rssi >= -79) {
      return "Strong";
    } else if (rssi >= -88) {
      return "Normal";
    } else {
      return "Poor";
    }
  }

  void _changeWindow(int index) {
    setState(() {
      _visibleIndex = index;
      //_setSubtitle();
      switch (index) {
        case 0:
          _title = "Managing rooms";
          break;
        case 1:
          _title = "Manage questions";
          break;
        case 2:
          // this runs _updateBeacons through the refreshindicator
          // this method shows the indicator the first time for UX
          _refreshBeaconKey?.currentState?.show();
          _title = "View nearby beacons";
          break;
        case 3:
          _title = "Make user admin";
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _title,
            ),
            Text(
              "Building: ${_building.name}",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            title: Text("Manage building"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_comment),
            title: Text("Manage questions"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth),
            title: Text("Manage beacons"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervisor_account),
            title: Text("Make user admin"),
          ),
        ],
        onTap: (int index) => _changeWindow(index),
        currentIndex: _visibleIndex,
      ),
      body: Center(
        child: Container(
          child: Stack(
            children: [
              Visibility(
                visible: _visibleIndex == 0,
                child: RefreshIndicator(
                  onRefresh: () => _updateBuilding(),
                  child: Container(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      itemCount: _building.rooms.length,
                      itemBuilder: (_, index) => ListButton(
                        onTap: () => _roomMenu(_building.rooms[index]),
                        child: Text(
                          _building.rooms[index].name,
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _visibleIndex == 1,
                child: RefreshIndicator(
                  onRefresh: () => _updateQuestions(),
                  child: Container(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      itemCount: _questionsRealList.length,
                      itemBuilder: (_, index) => ListButton(
                        onTap: () => _questionMenu(_questionsRealList[index]),
                        child: Text(
                          _questionsRealList[index].value,
                          style: TextStyle(
                            color: (_questionsRealList.any((question) =>
                                    _questionsRealList[index].isActive == false)
                                ? Colors.red[800]
                                : Colors.green[800]),
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Visibility(
              //   visible: _visibleIndex == 2,
              //   child: RefreshIndicator(
              //     onRefresh: () => _updateBeacons(),
              //     child: Container(
              //       child: ListView.builder(
              //         padding: EdgeInsets.symmetric(
              //           horizontal: 8,
              //           vertical: 4,
              //         ),
              //         itemCount: _beacons.length,
              //         itemBuilder: (_, index) => ListButton(
              //           onTap: () => _beaconMenu(_beacons[index]),
              //           child: Text(
              //             _beacons[index].name,
              //             style: TextStyle(
              //               fontSize: 24,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              Visibility(
                maintainState: true,
                visible: _visibleIndex == 2,
                child: RefreshIndicator(
                  key: _refreshBeaconKey,
                  onRefresh: _updateBeacons,
                  child: Container(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      itemCount: _beacons.length,
                      itemBuilder: (_, index) => ListButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              _beacons[index].item1,
                              style: TextStyle(
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              "Signal: ${_getSignalStrengthString(_beacons[index].item2)}",
                              style: TextStyle(
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _visibleIndex == 3,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: myController,
                        decoration:
                            InputDecoration(labelText: 'Enter user email'),
                      ),
                      RaisedButton(
                          onPressed: () =>
                              _getUserIdFromEmailFunc(myController.text),
                          child: Text('Make user admin for building: ' +
                              _building.name))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _visibleIndex != 3 && _visibleIndex != 2
          ? FloatingActionButton(
              child: _scanningBeacons
                  ? CircularProgressIndicator(
                      value: null,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Icon(
                      Icons.add,
                    ),
              onPressed: () {
                switch (_visibleIndex) {
                  case 0:
                    return _addRoom();
                  case 1:
                    return _addQuestion();
                  default:
                    return print("default case");
                }
              },
            )
          : Container(),
    );
  }
}
