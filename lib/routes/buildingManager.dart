import 'dart:async';

import 'package:climify/models/api_response.dart';
import 'package:climify/models/beacon.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/signalMap.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

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
  TextEditingController _newRoomNameController = TextEditingController();
  List<Beacon> _beacons = [];
  String _token = "";
  bool _scanningSignalMap = false;
  int _signalMapScans = 0;
  // SignalMap _signalMap;
  String _currentRoom = "";
  bool _gettingRoom = false;
  String _currentlyConfirming = "";

  @override
  void initState() {
    super.initState();
    _setBuildingState();
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
    } else {
      print(apiResponseBeacons.errorMessage);
    }
    _updateBuilding();
  }

  void _updateBuilding() async {
    APIResponse<BuildingModel> apiResponseBuilding =
        await _restService.getBuilding(_token, _building.id);
    if (apiResponseBuilding.error == false) {
      BuildingModel building = apiResponseBuilding.data;
      setState(() {
        _building = building;
      });
    }
  }

  void _addRoom() async {
    if (!await _bluetooth.isOn) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", _scaffoldKey);
      return;
    }
    await showDialog<bool>(
      barrierColor: Colors.black12,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void _submitRoom() async {
              APIResponse<RoomModel> apiResponse = await _restService.addRoom(
                _token,
                _newRoomNameController.text.trim(),
                _building,
              );
              if (apiResponse.error == false) {
                SnackBarError.showErrorSnackBar(
                    "Room ${apiResponse.data.name} added", _scaffoldKey);
                Navigator.of(context).pop(true);
              } else {
                SnackBarError.showErrorSnackBar(
                    apiResponse.errorMessage, _scaffoldKey);
                Navigator.of(context).pop(false);
              }
            }

            bool submitEnabled = _newRoomNameController.text.trim() != "";

            return SimpleDialog(
              title: Text("Add Room"),
              children: <Widget>[
                Text(
                  "Room Name",
                ),
                TextField(
                  controller: _newRoomNameController,
                  onChanged: (value) => setState(() {}),
                ),
                RaisedButton(
                  color: submitEnabled ? Colors.green : Colors.red,
                  child: Text("Submit"),
                  onPressed: () => submitEnabled ? _submitRoom() : null,
                ),
              ],
            );
          },
        );
      },
    ).then((value) {
      setState(() {
        _newRoomNameController.text = "";
      });
      _updateBuilding();
    });
  }

  void _addScans(RoomModel room) async {
    setState(() {
      _scanningSignalMap = false;
      _signalMapScans = 0;
      Map<String, List<int>> beacons = {};
      beacons.addEntries(
          _beacons.map((b) => MapEntry<String, List<int>>(b.id, [])));
      // _signalMap = SignalMap(_building.id);
    });
    if (!await _bluetooth.isOn) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", _scaffoldKey);
      return;
    }
    await showDialog(
      barrierColor: Colors.black12,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          key: _dialogKey,
          builder: (context, setState) {
            bool _dialogMounted() => _dialogKey?.currentState?.mounted ?? false;

            void _scan() async {
              if (!_dialogMounted()) {
                return;
              }

              if (await _bluetooth.isOn == false) {
                SnackBarError.showErrorSnackBar(
                    "Bluetooth is not on", _scaffoldKey);
                setState(() {
                  _scanningSignalMap = false;
                });
                return;
              }

              setState(() {
                _scanningSignalMap = true;
              });

              SignalMap signalMap = SignalMap(_building.id);
              int beaconsScanned = 0;
              List<ScanResult> scanResults =
                  await _bluetooth.scanForDevices(3000);

              if (!_dialogMounted()) {
                return;
              }

              scanResults.forEach((result) {
                String beaconName = _bluetooth.getBeaconName(result);
                if (_beacons
                    .where((element) => element.name == beaconName)
                    .isNotEmpty) {
                  String beaconId = _beacons
                      .firstWhere((element) => element.name == beaconName)
                      .id;
                  signalMap.addBeaconReading(
                      beaconId, _bluetooth.getRSSI(result));
                  beaconsScanned++;
                }
              });

              if (beaconsScanned > 0) {
                APIResponse<String> apiResponse =
                    await _restService.addSignalMap(_token, signalMap, room.id);
                if (!apiResponse.error) {
                  setState(() {
                    _signalMapScans++;
                  });
                  SnackBarError.showErrorSnackBar(
                      "Added scan to ${room.name}", _scaffoldKey);
                } else {
                  SnackBarError.showErrorSnackBar(
                      apiResponse.errorMessage, _scaffoldKey);
                }
              } else {
                SnackBarError.showErrorSnackBar(
                    "No beacons scanned", _scaffoldKey);
              }

              if (_dialogMounted()) {
                setState(() {
                  _scanningSignalMap = false;
                });
              }
            }

            void _finishScanning() async {
              if (!_scanningSignalMap) {
                if (_signalMapScans > 0)
                  SnackBarError.showErrorSnackBar(
                      "$_signalMapScans scans added to ${room.name}",
                      _scaffoldKey);
                Navigator.of(context).pop();
              }
            }

            return SimpleDialog(
              title: Text("Scan Room"),
              children: <Widget>[
                Text(
                  "Add bluetooth location data from the bluetooth beacons",
                ),
                Row(
                  children: <Widget>[
                    RaisedButton(
                      child: Text(
                        _scanningSignalMap
                            ? "Adding location data"
                            : "Add location data",
                      ),
                      onPressed: () =>
                          _scanningSignalMap ? print("already") : _scan(),
                    ),
                    _scanningSignalMap
                        ? CircularProgressIndicator(
                            value: null,
                          )
                        : Container(),
                  ],
                ),
                Text(
                  "Additional scans completed: $_signalMapScans",
                ),
                RaisedButton(
                  color: !_scanningSignalMap ? Colors.green : Colors.red,
                  child: Text("Finish scanning"),
                  onPressed: () =>
                      !_scanningSignalMap ? _finishScanning() : null,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _roomMenu(RoomModel room) async {
    Future<void> _deleteRoom() async {
      APIResponse<String> deleteResponse =
          await _restService.deleteRoom(_token, room.id);
      if (!deleteResponse.error) {
        SnackBarError.showErrorSnackBar(
            "Room ${room.name} deleted", _scaffoldKey);
      } else {
        SnackBarError.showErrorSnackBar(
            deleteResponse.errorMessage, _scaffoldKey);
      }
      return;
    }

    void _deleteScans() async {
      APIResponse<String> deleteResponse =
          await _restService.deleteSignalMapsOfRoom(_token, room.id);
      if (!deleteResponse.error) {
        SnackBarError.showErrorSnackBar(
            "Scans of ${room.name} deleted", _scaffoldKey);
      } else {
        SnackBarError.showErrorSnackBar(
            deleteResponse.errorMessage, _scaffoldKey);
      }
    }

    await showDialog(
      barrierColor: Colors.black12,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              title: Text("${room.name}"),
              children: <Widget>[
                RaisedButton(
                  child: Text("Add Scans"),
                  onPressed: () {
                    setState(() {
                      _currentlyConfirming = "";
                    });
                    _addScans(room);
                  },
                ),
                _currentlyConfirming == "scans"
                    ? RaisedButton(
                        color: Colors.red,
                        child: Text("Confirm"),
                        onPressed: () {
                          _deleteScans();
                          setState(() {
                            _currentlyConfirming = "";
                          });
                        },
                      )
                    : RaisedButton(
                        child: Text("Delete Scans"),
                        onPressed: () {
                          setState(() {
                            _currentlyConfirming = "scans";
                          });
                        },
                      ),
                _currentlyConfirming == "delete"
                    ? RaisedButton(
                        color: Colors.red,
                        child: Text("Confirm"),
                        onPressed: () async {
                          await _deleteRoom();
                          Navigator.of(context).pop();
                        },
                      )
                    : RaisedButton(
                        child: Text("Delete Room"),
                        onPressed: () {
                          setState(() {
                            _currentlyConfirming = "delete";
                          });
                        },
                      ),
                RaisedButton(
                  child: Text("Exit"),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            );
          },
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Managing ${_building.name}",
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _building.rooms.map((room) {
                return InkWell(
                  onTap: () => _roomMenu(room),
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
                            room.name,
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
            Row(
              children: <Widget>[
                RaisedButton(
                  child: Text("Where am I?"),
                  onPressed: () => _getRoom(),
                ),
                _gettingRoom
                    ? CircularProgressIndicator(
                        value: null,
                      )
                    : Container(),
              ],
            ),
            Text(
              "Current Room: $_currentRoom",
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
        ),
        onPressed: () => _addRoom(),
      ),
    );
  }
}
