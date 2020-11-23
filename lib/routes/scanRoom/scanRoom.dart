import 'dart:async';

import 'package:climify/models/api_response.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/signalMap.dart';
import 'package:climify/routes/scanRoom/scanRoomButton.dart';
import 'package:climify/services/bluetoothBeacons.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
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
  RoomModel _room;
  List<String> _blacklist;
  StreamSubscription _sub;
  Stream<SignalMap> _signalMapStream;

  final int _scanMilliseconds = 1250;
  final RestService _restService = RestService();
  final BluetoothServices _bluetooth = BluetoothServices();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _room = widget.arguments['room'];
    _blacklist = widget.arguments['blacklist'];
    setupSignalMapStream();
  }

  Future<void> setupSignalMapStream() async {
    _signalMapStream = await _bluetooth.scanForSignalMaps(_scanMilliseconds,
        blacklist: _blacklist);
    _signalMapStream.listen((signalMap) async {
      if (_stopping) {
        await _bluetooth.stopScanning();
        _setProgress(0);
        _setScanning(false);
        _setStopping(false);
      }
      if (_scanning) {
        if (signalMap.beacons.length > 0) {
          APIResponse<String> apiResponse =
              await _restService.postSignalMap(signalMap, _room.id);
          print(signalMap.avgBeaconSignals);
          if (!apiResponse.error) {
            _incrementScans();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    if (_sub != null) {
      _sub.cancel();
    }
    _bluetooth.dispose();
    super.dispose();
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

  Future<void> _startScan() async {
    if (!mounted) {
      return;
    }
    _setScanning(true);
    _setProgress(null);
    await _bluetooth.startScanner();
    return;
  }

  Future<void> _stopScan() async {
    if (!mounted) {
      return;
    }
    _setStopping(true);
    return;
  }

  // Future<void> _scan() async {
  //   if (!mounted) {
  //     return;
  //   }

  //   // if (await _bluetooth.isOn == false) {
  //   //   SnackBarError.showErrorSnackBar("Bluetooth is not on", scaffoldKey);
  //   //   _setScanning(false);
  //   //   setState(() {});
  //   //   return;
  //   // }

  //   // SignalMap signalMap =
  //   //     SignalMap.withInitBeacons(beacons, buildingId: building.id);
  //   SignalMap signalMap = SignalMap();
  //   int beaconsScanned = 0;
  //   // List<ScanResult> scanResults = await _bluetooth.scanForDevices(3000);

  //   if (!mounted) {
  //     return;
  //   }

  //   _setProgress(0);
  //   setState(() {});

  //   _stopTimer();
  //   _scanTimer =
  //       Timer.periodic(Duration(milliseconds: _scanMilliseconds ~/ 9), (timer) {
  //     double progress = _progress ?? 0;
  //     if (mounted && progress < 0.99) {
  //       _setProgress(progress + 1 / 9);
  //     }
  //   });
  //   signalMap = await _bluetooth.addStreamReadingsToSignalMap(
  //     signalMap,
  //     _scanMilliseconds,
  //     blacklist: _blacklist,
  //   );

  //   beaconsScanned = signalMap.beacons.length;

  //   if (beaconsScanned > 0) {
  //     APIResponse<String> apiResponse =
  //         await _restService.postSignalMap(signalMap, _room.id);
  //     if (!apiResponse.error) {
  //       _incrementScans();
  //       print(signalMap.avgBeaconSignals);
  //     } else {
  //       SnackBarError.showErrorSnackBar(apiResponse.errorMessage, scaffoldKey);
  //     }
  //   } else {
  //     SnackBarError.showErrorSnackBar("No beacons scanned", scaffoldKey);
  //   }
  //   _stopTimer();
  // }

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
        await _startScan();
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
                onPressed: () async => _scanning ? _stopScan() : _startScan(),
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
