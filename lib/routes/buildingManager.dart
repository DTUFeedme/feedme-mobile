import 'dart:async';

import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/routes/buildingManagerComponents/blacklistedDevices.dart';
import 'package:climify/routes/buildingManagerComponents/scannedDevices.dart';
import 'package:climify/routes/dialogues/addRoom.dart';
import 'package:climify/routes/dialogues/roomMenu.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/customDialog.dart';
import 'package:climify/widgets/emptyListText.dart';
import 'package:climify/widgets/listButton.dart';
import 'package:climify/widgets/submitButton.dart';
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
  final _adminController = TextEditingController();
  final _questionNameController = TextEditingController();
  final _questionAnswerOptionsController = TextEditingController();
  List<TextEditingController> controllerList = [];
  bool _scanningBeacons = false;
  List<String> _blacklist = [];
  bool _blacklistingBeacon = false;

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
    _adminController.dispose();
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
      _gettingBeacons = true;
    });
    _questions = [];
    _updateQuestions();
    await _updateBuilding();
    await _getBlacklist();
    setState(() {
      _gettingBeacons = false;
    });
  }

  Future<void> _getBlacklist() async {
    APIResponse<List<String>> apiResponseBlacklist =
        await _restService.getBeaconBlacklist(_building.id);
    if (apiResponseBlacklist.error == false) {
      setState(() {
        _blacklist = apiResponseBlacklist.data;
      });
    } else {
      print(apiResponseBlacklist.errorMessage);
    }
    print("blacklist: $_blacklist");
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
          blacklist: _blacklist,
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

  Future<void> _makeUserAdmin(String _email) async {
    if (_email.isEmpty) {
      SnackBarError.showErrorSnackBar("No email provided", _scaffoldKey);
      return;
    }

    APIResponse<bool> apiResponse =
        await _restService.patchUserAdmin(_email, _building);
    if (!apiResponse.error) {
      SnackBarError.showErrorSnackBar(
          "$_email made admin of ${_building.name}", _scaffoldKey);
      _adminController.clear();
    } else {
      // We should either have the server messages more user friendly or custom tailor these responses
      // This is a bad mix of both, and should not be used
      // I am doing this because there is no way to tell if the server finds a user with the email or not
      if (apiResponse.errorMessage.contains('already')) {
        SnackBarError.showErrorSnackBar(apiResponse.errorMessage, _scaffoldKey);
      } else {
        SnackBarError.showErrorSnackBar("No user found with email: $_email", _scaffoldKey);
      }
    }
    return;
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

  void _toggleBlacklistBeacon(String beaconName) async {
    if (_blacklistingBeacon) {
      return;
    }
    setState(() {
      _blacklistingBeacon = true;
    });
    bool blackListed = _blacklist.contains(beaconName);
    APIResponse<bool> apiResponse;
    if (blackListed) {
      apiResponse = await _restService.patchRemoveBlacklistBeacon(
          _building.id, beaconName);
    } else {
      apiResponse =
          await _restService.patchAddBlacklistBeacon(_building.id, beaconName);
    }
    if (apiResponse.error == false) {
      if (blackListed) {
        setState(() {
          _blacklist.remove(beaconName);
        });
      } else {
        setState(() {
          _blacklist.add(beaconName);
        });
      }
    } else {
      print("error:");
      print(apiResponse.errorMessage);
    }
    setState(() {
      _blacklistingBeacon = false;
    });
    return;
  }

  void _changeWindow(int index) {
    setState(() {
      //_setSubtitle();
      switch (index) {
        case 0:
          _title = "Managing rooms";
          break;
        case 1:
          _title = "Manage questions";
          break;
        case 2:
          if (_visibleIndex != 2) {
            // this runs _updateBeacons through the refreshindicator
            // this method shows the indicator the first time for UX
            _refreshBeaconKey?.currentState?.show();
          }
          _title = "View nearby beacons";
          break;
        case 3:
          _title = "Make user admin";
          break;
        default:
      }
      _visibleIndex = index;
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
                    child: _building.rooms.isNotEmpty
                        ? ListView.builder(
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
                          )
                        : EmptyListText(
                            text: 'There are no rooms in this building yet',
                          ),
                  ),
                ),
              ),
              Visibility(
                visible: _visibleIndex == 1,
                child: RefreshIndicator(
                  onRefresh: () => _updateQuestions(),
                  child: Container(
                    child: _questionsRealList.isNotEmpty
                        ? ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            itemCount: _questionsRealList.length,
                            itemBuilder: (_, index) => ListButton(
                              onTap: () =>
                                  _questionMenu(_questionsRealList[index]),
                              child: Text(
                                _questionsRealList[index].value,
                                style: TextStyle(
                                  color: (_questionsRealList.any((question) =>
                                          _questionsRealList[index].isActive ==
                                          false)
                                      ? Colors.red[800]
                                      : Colors.green[800]),
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          )
                        : EmptyListText(
                            text: 'There are no questions yet',
                          ),
                  ),
                ),
              ),
              Visibility(
                maintainState: true,
                visible: _visibleIndex == 2,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: RefreshIndicator(
                        key: _refreshBeaconKey,
                        onRefresh: _updateBeacons,
                        child: _beacons.isNotEmpty
                            ? ScannedDevices(
                                _beacons,
                                _blacklist,
                                _getSignalStrengthString,
                                _toggleBlacklistBeacon,
                              )
                            : EmptyListText(
                                text: 'No beacons scanned',
                              ),
                      ),
                    ),
                    _blacklist.isNotEmpty
                        ? Expanded(
                            flex: 1,
                            child: Text(
                              "Blacklisted beacons",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Container(),
                    _blacklist.isNotEmpty
                        ? Expanded(
                            flex: 3,
                            child: BlacklistedDevices(
                              _beacons,
                              _blacklist,
                              _toggleBlacklistBeacon,
                            ),
                          )
                        : Container(),
                  ],
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
                        controller: _adminController,
                        decoration:
                            InputDecoration(labelText: 'Enter user email'),
                      ),
                      // RaisedButton(
                      //   onPressed: () =>
                      //       _getUserIdFromEmailFunc(myController.text),
                      //   child: Text(
                      //       'Make user admin for building: ' + _building.name),
                      // ),
                      SubmitButton(
                        text: 'Make user admin for building: ' + _building.name,
                        onPressed: () => _makeUserAdmin(_adminController.text),
                      ),
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
                    if (_building.rooms.isNotEmpty) {
                      return _addQuestion();
                    } else {
                      SnackBarError.showErrorSnackBar(
                        "A building must have rooms before adding questions",
                        _scaffoldKey,
                      );
                    }
                    return null;
                  default:
                    return print("default case");
                }
              },
            )
          : Container(),
    );
  }
}
