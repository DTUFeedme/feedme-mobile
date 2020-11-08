import 'dart:async';

import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/signalMap.dart';
import 'package:climify/routes/scanRoom/scanRoomButton.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/progressButton.dart';
import 'package:flutter/material.dart';

class ScanRoomFlow extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const ScanRoomFlow({
    Key key,
    @required this.arguments,
  }) : super(key: key);

  @override
  _ScanRoomFlowState createState() => _ScanRoomFlowState();
}

class _ScanRoomFlowState extends State<ScanRoomFlow> {
  bool _scanning = false;
  bool _stopping = false;
  double _progress = 0.0;
  int _numberOfScans = 0;
  Timer _scanTimer;
  RoomModel _room;
  List<String> _blacklist;

  final int _scanMilliseconds = 3000;
  final RestService _restService = RestService();
  final BluetoothServices _bluetooth = BluetoothServices();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _room = widget.arguments['room'];
    _blacklist = widget.arguments['blacklist'];
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _setStopping(bool b) {
    setState(() {
      _stopping = b;
    });
  }

  void _setScanning(bool b) {
    setState(() {
      _scanning = b;
    });
  }

  void _setProgress(double d) {
    setState(() {
      _progress = d;
    });
  }

  void _incrementScans() {
    setState(() {
      _numberOfScans = _numberOfScans + 1;
    });
  }

  void _stopTimer() {
    _setProgress(0);
    if (_scanTimer != null) {
      _scanTimer.cancel();
    }
  }

  Future<void> _scan() async {
    if (!mounted) {
      return;
    }

    if (await _bluetooth.isOn == false) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", scaffoldKey);
      _setScanning(false);
      setState(() {});
      return;
    }

    // SignalMap signalMap =
    //     SignalMap.withInitBeacons(beacons, buildingId: building.id);
    SignalMap signalMap = SignalMap();
    int beaconsScanned = 0;
    // List<ScanResult> scanResults = await _bluetooth.scanForDevices(3000);

    if (!mounted) {
      return;
    }

    _setProgress(0);
    setState(() {});

    _stopTimer();
    _scanTimer =
        Timer.periodic(Duration(milliseconds: _scanMilliseconds ~/ 9), (timer) {
      double progress = _progress ?? 0;
      if (mounted && progress < 0.99) {
        _setProgress(progress + 1 / 9);
      }
    });
    signalMap = await _bluetooth.addStreamReadingsToSignalMap(
      signalMap,
      _scanMilliseconds,
      blacklist: _blacklist,
    );

    beaconsScanned = signalMap.beacons.length;

    if (beaconsScanned > 0) {
      APIResponse<String> apiResponse =
          await _restService.postSignalMap(signalMap, _room.id);
      if (!apiResponse.error) {
        _incrementScans();
        print(signalMap.avgBeaconSignals);
      } else {
        SnackBarError.showErrorSnackBar(apiResponse.errorMessage, scaffoldKey);
      }
    } else {
      SnackBarError.showErrorSnackBar("No beacons scanned", scaffoldKey);
    }
    _stopTimer();
  }

  Future<void> _toggleScan() async {
    if (!mounted) {
      return;
    }
    if (_stopping) {
      return;
    }
    if (_scanning) {
      _setStopping(true);
      return;
    } else {
      _setScanning(true);
      while (mounted && !_stopping) {
        await _scan();
        if (mounted && !_stopping) {
          await Future.delayed(Duration(milliseconds: _scanMilliseconds ~/ 2));
        } else {
          break;
        }
      }
      if (!mounted) {
        return;
      }
      _setStopping(false);
      _setScanning(false);
      SnackBarError.hideSnackBar(scaffoldKey);
    }
    return;
  }

  void _finishScanning() async {
    if (!_scanning) {
      Navigator.of(context).pop();
    }
  }

  String get scanButtonText => _scanning
      ? _stopping
          ? "Stopping"
          : "Stop"
      : "Start";

  String get exitButtonText => _scanning
      ? _stopping
          ? "Waiting for scan to stop"
          : "Stop scan to exit"
      : "Exit";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Scanning room: ${_room.name}"),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (_scanning && !_stopping) {
            await _toggleScan();
            SnackBarError.showErrorSnackBar("Stopping scan", scaffoldKey);
            return false;
          } else if (_scanning) {
            return false;
          } else {
            return true;
          }
        },
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Text(
                  "Press the button to start scanning",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
              ScanRoomButton(
                text: scanButtonText,
                progress: _progress,
                onPressed: () async => _toggleScan(),
                size: 128,
              ),
              Text(
                "Total successful scans: $_numberOfScans",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              // Text(
              //   _scanning
              //       ? _stopping
              //           ? "Stopping scan..."
              //           : "Stop scanning room"
              //       : "Start scanning room",
              // ),
              ButtonTheme(
                minWidth: MediaQuery.of(context).size.width / 5 * 4,
                child: RaisedButton(
                  color: !_scanning ? Colors.green : Colors.red,
                  child: Text(exitButtonText),
                  onPressed: () => _scanning ? null : _finishScanning(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
