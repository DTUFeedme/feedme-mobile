import 'dart:async';

import 'package:climify/models/api_response.dart';
import 'package:climify/models/beacon.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/routes/dialogues/addBeacon.dart';
import 'package:climify/routes/dialogues/addRoom.dart';
import 'package:climify/routes/dialogues/roomMenu.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/customDialog.dart';
import 'package:climify/widgets/listButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'dialogues/scanRoom.dart';
import 'dialogues/beaconMenu.dart';
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
  //GlobalKey<State> _dialogKey = GlobalKey<State>();
  BuildingModel _building = BuildingModel('', '', []);
  List<FeedbackQuestion> _questionsRealList = [];
  List<FeedbackQuestion> _questions = [];
  TextEditingController _newRoomNameController = TextEditingController();
  List<Beacon> _beacons = [];
  List<String> _beaconList = [];
  bool _scanningSignalMap = false;
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
    APIResponse<List<Beacon>> apiResponseBeacons =
        await _restService.getBeaconsOfBuilding(_building);
    if (!apiResponseBeacons.error) {
      setState(() {
        _beacons = apiResponseBeacons.data;
      });
      print("beacons of the deep: $_beacons");
    } else {
      print(apiResponseBeacons.errorMessage);
    }
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

  Future<void> _updateBeacon() async {
    APIResponse<List<Beacon>> apiResponseBeacons =
        await _restService.getBeaconsOfBuilding(_building);
    if (apiResponseBeacons.error == false) {
      List<Beacon> beacon = apiResponseBeacons.data;
      setState(() {
        _beacons = beacon;
      });
    }
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
          beacons: _beacons,
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

  void _beaconMenu(Beacon beacon) async {
    await showDialogModified(
      barrierColor: Colors.black12,
      context: context,
      builder: (_) {
        return BeaconMenu(
          context,
          beacon: beacon,
          building: _building,
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
      });
      _updateBeacon();
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

  void _addBeacon() async {
    if (_scanningBeacons) {
      return;
    }
    if (!await _bluetooth.isOn) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", _scaffoldKey);
      return;
    }
    if (await _bluetooth.isOn == false) return;
    List<String> beaconList = [];
    setState(() {
      _scanningBeacons = true;
    });
    List<ScanResult> scanResults = await _bluetooth.scanForDevices(2500);
    setState(() {
      _scanningBeacons = false;
    });
    scanResults.forEach((result) {
      setState(() {});
      String beaconName = _bluetooth.getBeaconName(result);
      // List<String> serviceUuids = result.advertisementData.serviceUuids;
      // String beaconId = serviceUuids.isNotEmpty ? serviceUuids[0] : "";
      RegExp regex = RegExp(r'^[a-zA-Z0-9]{4,6}$');
      if (beaconName != "" && regex.hasMatch(beaconName)) {
        beaconList.add(beaconName);
        print('beacon name' + beaconName);
      }
    });
    setState(() {
      _beaconList = beaconList;
    });
    if (beaconList.isEmpty) {
      SnackBarError.showErrorSnackBar("No beacons found", _scaffoldKey);
      return;
    }
    int addedBeacons = 0;
    void Function(int) setBeaconsAdded = (b) {
      addedBeacons = b;
    };
    await showDialogModified(
      barrierColor: Colors.black12,
      context: context,
      builder: (_) {
        return AddBeacon(
          context,
          beaconList: _beaconList,
          alreadyExistingBeacons: _beacons,
          building: _building,
          scaffoldKey: _scaffoldKey,
          setBeaconsAdded: setBeaconsAdded,
        ).dialog;
      },
    ).then((_) {
      if (addedBeacons == 0) {
        SnackBarError.showErrorSnackBar("No beacons were added", _scaffoldKey);
      } else {
        if (addedBeacons == 1) {
          SnackBarError.showErrorSnackBar("1 beacon was added", _scaffoldKey);
        } else {
          SnackBarError.showErrorSnackBar(
              "$addedBeacons beacons were added", _scaffoldKey);
        }
        _updateBeacon();
      }
    });
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
          _title = "Manage beacons";
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
              Visibility(
                visible: _visibleIndex == 2,
                child: RefreshIndicator(
                  onRefresh: () => _updateBeacon(),
                  child: Container(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      itemCount: _beacons.length,
                      itemBuilder: (_, index) => ListButton(
                        onTap: () => _beaconMenu(_beacons[index]),
                        child: Text(
                          _beacons[index].name,
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
      floatingActionButton: _visibleIndex != 3
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
                  case 2:
                    return _addBeacon();
                  default:
                    return print("default case");
                }
              },
            )
          : Container(),
    );
  }
}
