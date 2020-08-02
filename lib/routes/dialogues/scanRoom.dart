import 'package:climify/models/api_response.dart';
import 'package:climify/models/beacon.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/signalMap.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ScanRoom {
  final BuildContext context;
  final RoomModel room;
  final String token;
  final BuildingModel building;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(bool) setScanning;
  final Function incrementScans;
  final bool Function() getScanning;
  final int Function() getNumberOfScans;
  final List<Beacon> beacons;
  StatefulBuilder scanRoomDialog;

  RestService _restService;
  GlobalKey<State> _dialogKey = GlobalKey<State>();
  BluetoothServices _bluetooth;

  ScanRoom(
    this.context, {
    @required this.room,
    @required this.token,
    @required this.building,
    @required this.scaffoldKey,
    @required this.setScanning,
    @required this.incrementScans,
    @required this.getScanning,
    @required this.getNumberOfScans,
    @required this.beacons,
  }) {
    _restService = RestService(context);
    _bluetooth = BluetoothServices(context);
    scanRoomDialog = StatefulBuilder(
      key: _dialogKey,
      builder: (context, setState) {
        bool _dialogMounted() => _dialogKey?.currentState?.mounted ?? false;

        void _scan() async {
          if (!_dialogMounted()) {
            return;
          }

          if (await _bluetooth.isOn == false) {
            SnackBarError.showErrorSnackBar("Bluetooth is not on", scaffoldKey);
            setScanning(false);
            return;
          }

          setScanning(true);
          setState(() {});

          SignalMap signalMap = SignalMap(building.id);
          int beaconsScanned = 0;
          List<ScanResult> scanResults = await _bluetooth.scanForDevices(3000);

          if (!_dialogMounted()) {
            return;
          }

          scanResults.forEach((result) {
            String beaconName = _bluetooth.getBeaconName(result);
            if (beacons
                .where((element) => element.name == beaconName)
                .isNotEmpty) {
              String beaconId = beacons
                  .firstWhere((element) => element.name == beaconName)
                  .id;
              signalMap.addBeaconReading(beaconId, _bluetooth.getRSSI(result));
              beaconsScanned++;
            }
          });

          if (beaconsScanned > 0) {
            APIResponse<String> apiResponse =
                await _restService.postSignalMap(signalMap, room.id);
            if (!apiResponse.error) {
              incrementScans();
              SnackBarError.showErrorSnackBar(
                  "Added scan to ${room.name}", scaffoldKey);
            } else {
              SnackBarError.showErrorSnackBar(
                  apiResponse.errorMessage, scaffoldKey);
            }
          } else {
            SnackBarError.showErrorSnackBar("No beacons scanned", scaffoldKey);
          }

          if (_dialogMounted()) {
            setScanning(false);
            setState(() {});
          }
        }

        void _finishScanning() async {
          if (!getScanning()) {
            if (getNumberOfScans() > 0)
              SnackBarError.showErrorSnackBar(
                  "${getNumberOfScans()} scans added to ${room.name}",
                  scaffoldKey);
            Navigator.of(context).pop();
          }
        }

        return SimpleDialog(
          title: Text("Scan ${room.name}"),
          children: <Widget>[
            Text(
              "Add bluetooth location data from the bluetooth beacons",
            ),
            Row(
              children: <Widget>[
                RaisedButton(
                  child: Text(
                    getScanning()
                        ? "Adding location data"
                        : "Add location data",
                  ),
                  onPressed: () => getScanning() ? print("already") : _scan(),
                ),
                getScanning()
                    ? CircularProgressIndicator(
                        value: null,
                      )
                    : Container(),
              ],
            ),
            Text(
              "Additional scans completed: ${getNumberOfScans()}",
            ),
            RaisedButton(
              color: !getScanning() ? Colors.green : Colors.red,
              child: Text("Finish scanning"),
              onPressed: () => !getScanning() ? _finishScanning() : null,
            ),
          ],
        );
      },
    );
  }

  StatefulBuilder get dialog => scanRoomDialog;
}
