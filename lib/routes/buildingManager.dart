import 'dart:async';

import 'package:climify/models/api_response.dart';
import 'package:climify/models/beacon.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/models/questionModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/signalMap.dart';
import 'package:climify/models/userModel.dart';
import 'package:climify/routes/dialogues/addBeacon.dart';
import 'package:climify/routes/dialogues/addRoom.dart';
import 'package:climify/routes/dialogues/roomMenu.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/customDialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:climify/routes/registeredUserRoute/buildingList.dart';

import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/routes/dialogues/addBuilding.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/customDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'dialogues/scanRoom.dart';
import 'dialogues/beaconMenu.dart';
import 'dialogues/addQuestion.dart';
import 'dialogues/questionMenu.dart';

class BuildingManager extends StatefulWidget {
  @override
  _BuildingManagerState createState() => _BuildingManagerState();
}

class _BuildingManagerState extends State<BuildingManager> {
  BluetoothServices _bluetooth = BluetoothServices();
  RestService _restService = RestService();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<State> _dialogKey = GlobalKey<State>();
  BuildingModel _building = BuildingModel('', '', []);
  List<FeedbackQuestion> _questions = [];
  TextEditingController _newRoomNameController = TextEditingController();
  List<Beacon> _beacons = [];
  List<Tuple2<String, String>> _beaconList = [];
  String _token = "";
  bool _scanningSignalMap = false;
  int _signalMapScans = 0;
  // SignalMap _signalMap;
  String _currentRoom = "";
  bool _gettingRoom = false;
  String _currentlyConfirming = "";
  int _visibleIndex = 0;
  String _title = "Manage rooms";
  bool _gettingUserId = false;
  bool _makinguseradmin = false;
  final myController = TextEditingController();
  final _questionNameController = TextEditingController();
  final _questionAnswerOptionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setBuildingState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    _newRoomNameController.dispose();
    super.dispose();
  }

  void _setBuildingState() async {
    await Future.delayed(Duration.zero);
    setState(() {
      _token = Provider.of<GlobalState>(context).globalState['token'];
      _building = Provider.of<GlobalState>(context).globalState['building'];
    });
    APIResponse<List<Beacon>> apiResponseBeacons =
        await _restService.getBeaconsOfBuilding(_token, _building);
    if (!apiResponseBeacons.error) {
      setState(() {
        _beacons = apiResponseBeacons.data;
      });
      print("beacons of the deep: $_beacons");
    } else {
      print(apiResponseBeacons.errorMessage);
    }
    for(int i = 0; i < _building.rooms.length; i++){
       
    APIResponse<List<FeedbackQuestion>> apiResponseBuilding =
        await _restService.getActiveQuestionsByRoom(_building.rooms[i].id, _token);
    if (apiResponseBuilding.error == false) {
      List<FeedbackQuestion> question = apiResponseBuilding.data;
      setState(() {
        for(int j = 0; j < question.length; j++){
          _questions.add(question[j]);
        }
      });
    }
    }
    _updateBuilding();
  }

  Future<void> _updateBuilding() async {
    APIResponse<BuildingModel> apiResponseBuilding =
        await _restService.getBuilding(_token, _building.id);
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
        await _restService.getBeaconsOfBuilding(_token, _building);
    if (apiResponseBeacons.error == false) {
      List<Beacon> beacon = apiResponseBeacons.data;
      setState(() {
        _beacons = beacon;
      });
    }
    return;
  }

  // Future<void> _updateQuestions() async {
  //   for(int i = 0; i < _building.rooms.length; i++){
       
  //   APIResponse<List<FeedbackQuestion>> apiResponseBuilding =
  //       await _restService.getActiveQuestionsByRoom(_building.rooms[i].id, _token);
  //   if (apiResponseBuilding.error == false) {
  //     List<FeedbackQuestion> question = apiResponseBuilding.data;
  //     setState(() {
  //       for(int j = 0; j < question.length; j++){
  //         _questions.add(question[j]);
  //       }
  //     });
  //   }
  //   }
  //   return;
  // }

  void _updateBuildingAndAddScan() async {
    await _updateBuilding();
    _addScans(_building.rooms.last);
  }

  void _addQuestion() async {
    await showDialogModified<bool>(
      barrierColor: Colors.black12,
      context: context,
      builder: (context) {
        return AddQuestion(
          token: _token,
          textEditingController: _questionNameController,
          textEditingController2: _questionAnswerOptionsController,
          building: _building,
          scaffoldKey: _scaffoldKey,
        ).dialog;
      },
    ).then((value) {
      setState(() {
        _questionNameController.text = "";
        _questionAnswerOptionsController.text = "";
      });
      if (value ?? false) {
        _updateBuilding();
      }
    });
  }

  void _addRoom() async {
    await showDialogModified<bool>(
      barrierColor: Colors.black12,
      context: context,
      builder: (context) {
        return AddRoom(
          token: _token,
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
      // Map<String, List<int>> beacons = {};
      // beacons.addEntries(
      //     _beacons.map((b) => MapEntry<String, List<int>>(b.id, [])));
      // _signalMap = SignalMap(_building.id);
    });
    if (!await _bluetooth.isOn) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", _scaffoldKey);
      return;
    }
    await showDialogModified(
      barrierColor: Colors.black12,
      context: context,
      builder: (context) {
        return ScanRoom(
          room: room,
          token: _token,
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
      builder: (context) {
        return RoomMenu(
          room: room,
          token: _token,
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
      builder: (context) {
        return BeaconMenu(
          beacon: beacon,
          token: _token,
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
      builder: (context) {
        return QuestionMenu(
          question: question,
          token: _token,
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
      _updateBuilding();
    });
  }

  void _getRoom() async {
    setState(() {
      _gettingRoom = true;
    });
    RoomModel room;
    APIResponse<RoomModel> apiResponse =
        await _bluetooth.getRoomFromBuilding(_building, _token);
    if (apiResponse.error) {
      SnackBarError.showErrorSnackBar(apiResponse.errorMessage, _scaffoldKey);
    } else {
      room = apiResponse.data;
    }
    setState(() {
      _currentRoom = room?.name ?? "unknown";
      _gettingRoom = false;
    });
  }

  void _getUserIdFromEmailFunc(String _email) async {
    print("user email" + _email);
    setState(() {
      _gettingUserId = true;
    });
    String userId;
    APIResponse<String> apiResponse =
        await _restService.getUserIdFromEmail(_token, _email);
    if (apiResponse.error) {
      SnackBarError.showErrorSnackBar(apiResponse.errorMessage, _scaffoldKey);
    } else {
      userId = apiResponse.data;
    }
    setState(() {
      _gettingUserId = false;
    });
    if (userId != null) {
      _makeUserAdmin(userId, _email);
    } else {
      SnackBarError.showErrorSnackBar(
          "No user found with email: $_email", _scaffoldKey);
    }
  }

  void _makeUserAdmin(String _userId, String _email) async {
    setState(() {
      _makinguseradmin = true;
    });
    UserModel userAdminData;
    APIResponse<UserModel> apiResponse =
        await _restService.makeUserAdmin(_token, _userId, _building);
    if (apiResponse.error) {
      SnackBarError.showErrorSnackBar(apiResponse.errorMessage, _scaffoldKey);
    } else {
      SnackBarError.showErrorSnackBar(
          _email + " is now admin of building: " + _building.name,
          _scaffoldKey);
      userAdminData = apiResponse.data;
    }
    setState(() {
      _makinguseradmin = false;
    });
  }

  void _addBeacon() async {
    if (!await _bluetooth.isOn) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", _scaffoldKey);
      return;
    }
    if (await _bluetooth.isOn == false) return;
    List<Tuple2<String, String>> beaconList = [];
    List<ScanResult> scanResults = await _bluetooth.scanForDevices(4000);
    scanResults.forEach((result) {
      setState(() {});
      String beaconName = _bluetooth.getBeaconName(result);
      // List<String> serviceUuids = result.advertisementData.serviceUuids;
      // String beaconId = serviceUuids.isNotEmpty ? serviceUuids[0] : "";
      RegExp regex = RegExp(r'^[a-zA-Z0-9]{4,6}$');
      if (beaconName != "" && regex.hasMatch(beaconName)) {
        String beaconId = result.advertisementData.serviceData.keys.first;
        Tuple2<String, String> item =
            new Tuple2<String, String>(beaconName, beaconId);
        beaconList.add(item);
        print('beaconId' + beaconId);
      }
    });
    setState(() {
      _beaconList = beaconList;
    });
    if (beaconList.isEmpty){
      SnackBarError.showErrorSnackBar("No beacons found", _scaffoldKey);
      return;
    }
    await showDialogModified<bool>(
      barrierColor: Colors.black12,
      context: context,
      builder: (context) {
        return AddBeacon(
          token: _token,
          beaconList: _beaconList,
          // textEditingController: myControllerAddBeaconName,
          // textEditingController2: myControllerAddBeaconUUID,
          building: _building,
          scaffoldKey: _scaffoldKey,
        ).dialog;
      },
    ).then((value) {
      setState(() {
        // myControllerAddBeaconName.text = "";
        // myControllerAddBeaconUUID.text = "";
      });
      if (value ?? false) {
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
                      itemBuilder: (_, index) => InkWell(
                        onTap: () => _roomMenu(_building.rooms[index]),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(),
                            ),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 8,
                                ),
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
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _visibleIndex == 1,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _questions.map((question) {
                          return InkWell(
                            onTap: () => _questionMenu(question),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(),
                                ),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      question.value,
                                      style: TextStyle(
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _visibleIndex == 2,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _beacons.map((beacon) {
                          return InkWell(
                            onTap: () => _beaconMenu(beacon),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(),
                                ),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      beacon.name,
                                      style: TextStyle(
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _visibleIndex == 3,
                child: Container(
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
              child: Icon(
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
                  case 2:
                    return print("Impossible case as the button is hidden");
                  default:
                    return print("default case");
                }
              },
            )
          : Container(),
    );
  }
}
