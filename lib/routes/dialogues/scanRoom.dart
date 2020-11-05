import 'dart:async';

import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/signalMap.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/progressButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScanRoom {
  final BuildContext context;
  final RoomModel room;
  final BuildingModel building;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(bool) setScanning;
  final bool Function() getScanning;
  final Function(bool) setStopping;
  final bool Function() getStopping;
  final Function(double) setProgress;
  final double Function() getProgress;
  final Function incrementScans;
  final int Function() getNumberOfScans;
  final List<String> blacklist;
  StatefulBuilder scanRoomDialog;

  RestService _restService;
  GlobalKey<State> _dialogKey = GlobalKey<State>();
  BluetoothServices _bluetooth;

  ScanRoom(
    this.context, {
    @required this.room,
    @required this.building,
    @required this.scaffoldKey,
    @required this.setScanning,
    @required this.getScanning,
    @required this.setStopping,
    @required this.getStopping,
    @required this.setProgress,
    @required this.getProgress,
    @required this.incrementScans,
    @required this.getNumberOfScans,
    @required this.blacklist,
  }) {
    _restService = RestService();
    _bluetooth = BluetoothServices();
    scanRoomDialog = StatefulBuilder(
      key: _dialogKey,
      builder: (context, setState) {
        final int _scanMilliseconds = 3000;
        bool _dialogMounted() => _dialogKey?.currentState?.mounted ?? false;
        Timer _scanTimer;

        Future<void> _scan() async {
          if (!_dialogMounted()) {
            return;
          }

          if (await _bluetooth.isOn == false) {
            SnackBarError.showErrorSnackBar("Bluetooth is not on", scaffoldKey);
            setScanning(false);
            setState(() {});
            return;
          }

          // SignalMap signalMap =
          //     SignalMap.withInitBeacons(beacons, buildingId: building.id);
          SignalMap signalMap = SignalMap();
          int beaconsScanned = 0;
          // List<ScanResult> scanResults = await _bluetooth.scanForDevices(3000);

          if (!_dialogMounted()) {
            return;
          }

          setProgress(0);
          setState(() {});

          if (_scanTimer != null) {
            _scanTimer.cancel();
          }
          _scanTimer = Timer.periodic(
              Duration(milliseconds: _scanMilliseconds ~/ 9), (timer) {
            double progress = getProgress() ?? 0;
            if (_dialogMounted() && progress < 0.99) {
              setProgress(progress + 1 / 9);
              setState(() {});
            } else {
              setProgress(0);
              timer.cancel();
              if (_dialogMounted()) {
                setState(() {});
              }
            }
          });
          signalMap = await _bluetooth.addStreamReadingsToSignalMap(
            signalMap,
            _scanMilliseconds,
            blacklist: blacklist,
          );

          beaconsScanned = signalMap.beacons.length;

          if (beaconsScanned > 0) {
            APIResponse<String> apiResponse =
                await _restService.postSignalMap(signalMap, room.id);
            if (!apiResponse.error) {
              incrementScans();
              print(signalMap.avgBeaconSignals);
            } else {
              SnackBarError.showErrorSnackBar(
                  apiResponse.errorMessage, scaffoldKey);
            }
          } else {
            SnackBarError.showErrorSnackBar("No beacons scanned", scaffoldKey);
          }
        }

        void _toggleScan() async {
          if (!_dialogMounted()) {
            return;
          }
          if (getStopping()) {
            return;
          }
          if (getScanning()) {
            setStopping(true);
            setState(() {});
          } else {
            setScanning(true);
            setState(() {});
            while (_dialogMounted() && !getStopping()) {
              await _scan();
              if (_dialogMounted() && !getStopping()) {
                await Future.delayed(
                    Duration(milliseconds: _scanMilliseconds ~/ 2));
              } else {
                break;
              }
            }
            if (!_dialogMounted()) {
              return;
            }
            setStopping(false);
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
          title: Text("Scanning: ${room.name}"),
          children: <Widget>[
            Text(
              "Add bluetooth location data from the bluetooth beacons by scanning the current room",
            ),
            ProgressButton(
              text: getScanning()
                  ? getStopping()
                      ? "Stopping scan..."
                      : "Stop scanning room"
                  : "Start scanning room",
              onPressed: () async => _toggleScan(),
              showBar: getScanning(),
              progress: getProgress(),
            ),
            Text(
              "Scans completed: ${getNumberOfScans()}",
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
