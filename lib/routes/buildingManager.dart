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
  BuildingModel _building = BuildingModel('', '', []);
  TextEditingController _newRoomNameController = TextEditingController();
  List<Beacon> _beacons = [];
  String _token = "";
  bool _scanningSignalMap = false;
  int _signalMapScans = 0;
  SignalMap _signalMap;
  String _currentRoom = "";
  bool _gettingRoom = false;

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
    setState(() {
      _scanningSignalMap = false;
      _signalMapScans = 0;
      Map<String, List<int>> beacons = {};
      beacons.addEntries(
          _beacons.map((b) => MapEntry<String, List<int>>(b.id, [])));
      _signalMap = SignalMap(_building.id);
    });
    if (!await _bluetooth.isOn) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", _scaffoldKey);
      return;
    }
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void _scan() async {
              if (!mounted) return;
              if (await _bluetooth.isOn == false) return;

              setState(() {
                _scanningSignalMap = true;
              });
              SignalMap tempSignalMap = _signalMap;
              int beaconsScanned = 0;
              List<ScanResult> scanResults =
                  await _bluetooth.scanForDevices(4000);
              scanResults.forEach((result) {
                String beaconName = _bluetooth.getBeaconName(result);
                if (_beacons
                    .where((element) => element.name == beaconName)
                    .isNotEmpty) {
                  String beaconId = _beacons
                      .firstWhere((element) => element.name == beaconName)
                      .id;
                  tempSignalMap.addBeaconReading(
                      beaconId, _bluetooth.getRSSI(result));
                  beaconsScanned++;
                }
              });
              if (beaconsScanned > 0) {
                setState(() {
                  _signalMap = tempSignalMap;
                  _signalMapScans++;
                });
              } else {
                SnackBarError.showErrorSnackBar(
                    "No beacons scanned", _scaffoldKey);
              }
              setState(() {
                _scanningSignalMap = false;
              });
            }

            void _submitRoom() async {
              APIResponse<RoomModel> apiResponseAddRoom =
                  await _restService.addRoom(
                _token,
                _newRoomNameController.text.trim(),
                _building,
              );
              if (apiResponseAddRoom.error == false) {
                RoomModel room = apiResponseAddRoom.data;
                APIResponse<String> apiResponseSignalMap = await _restService
                    .addSignalMap(_token, _signalMap, room.id);
                if (apiResponseSignalMap.error == false) {
                  SnackBarError.showErrorSnackBar(
                      "Room \"${_newRoomNameController.text}\" added",
                      _scaffoldKey);
                } else {
                  SnackBarError.showErrorSnackBar(
                      apiResponseSignalMap.errorMessage, _scaffoldKey);
                }
              } else {
                SnackBarError.showErrorSnackBar(
                    apiResponseAddRoom.errorMessage, _scaffoldKey);
              }
              Navigator.of(context).pop(context);
            }

            bool submitEnabled =
                (_newRoomNameController.text != "" && _signalMapScans >= 10);

            return SimpleDialog(
              title: Text("Add Room"),
              children: <Widget>[
                Text(
                  "Room Name",
                ),
                TextField(
                  controller: _newRoomNameController,
                ),
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
                  "Scans completed: $_signalMapScans",
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
    ).then((value) => _updateBuilding());
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
    BluetoothServices bluetoothServices = BluetoothServices();
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
                return Container(
                  child: Text(
                    room.name,
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
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
