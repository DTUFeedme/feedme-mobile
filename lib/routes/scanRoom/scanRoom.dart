import 'dart:async';

import 'package:climify/models/api_response.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/signalMap.dart';
import 'package:climify/routes/scanRoom/scanRoomButton.dart';
import 'package:climify/services/bluetoothBeacons.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/services/updateLocation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

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
  bool _exitLock = false;
  double _progress = 0.0;
  int _numberOfScans = 0;
  RoomModel _room;
  List<String> _blacklist;
  StreamSubscription _streamSubscription;
  Stream<SignalMap> _signalMapStream;
  UpdateLocation _updateLocation;

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
    Wakelock.enable();
    _updateLocation = Provider.of<UpdateLocation>(context, listen: false);
    _updateLocation.enableBackgroundScans(b: false);
  }

  Future<void> setupSignalMapStream() async {
    _signalMapStream = await _bluetooth.scanForSignalMaps(_scanMilliseconds,
        blacklist: _blacklist);
    _streamSubscription = _signalMapStream.listen((signalMap) async {
      if (_stopping) {
        _setProgress(0);
        _setScanning(false);
        _setStopping(false);
      }
      if (_scanning) {
        if (signalMap.beacons.length > 0) {
          APIResponse<String> apiResponse =
              await _restService.postSignalMap(signalMap, _room.id);
          if (!apiResponse.error) {
            _incrementScans();
          }
        }
      }
    });
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
    if (_exitLock) {
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

  Future<void> _finishScanning() async {
    if (!_scanning) {
      setState(() {
        _exitLock = true;
      });
      await _bluetooth.dispose();
      _streamSubscription.cancel();
      _updateLocation.enableBackgroundScans(b: true);
      Wakelock.disable();
      return;
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
            await _finishScanning();
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
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
