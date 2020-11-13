import 'dart:async';
import 'dart:math';

import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/signalMap.dart';
import 'package:climify/services/rest_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:tuple/tuple.dart';

class BluetoothServices {
  BluetoothServices() {
    flutterBlue.isScanning.listen((event) {
      _scanning = event;
    });
  }

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  bool _gettingRoom = false;
  bool _scanning = false;

  Future<void> stopScan() async {
    await flutterBlue.stopScan();
  }

  Future<void> startScan() async {
    await flutterBlue.startScan();
  }

  Future<SignalMap> addStreamReadingsToSignalMap(
    SignalMap signalMap,
    int timeoutms, {
    List<String> blacklist = const [],
  }) async {
    Stream<List<ScanResult>> scanResultStream =
        await scanForDevicesStream(2000);
    scanResultStream.listen((List<ScanResult> scanResultList) {
      scanResultList.forEach((ScanResult scanResult) {
        String beaconName = getBeaconName(scanResult);
        signalMap.addBeaconReading(
          beaconName,
          getRSSI(scanResult),
          blacklist: blacklist,
        );
      });
    });
    await Future.delayed(Duration(milliseconds: timeoutms));
    return signalMap;
  }

  Future<Stream<List<ScanResult>>> scanForDevicesStream(int timeoutms) async {
    if (await flutterBlue.isOn == false || _scanning) {
      return Stream.empty();
    }
    try {
      flutterBlue
          .startScan(timeout: Duration(milliseconds: timeoutms))
          .then((_) => flutterBlue.stopScan());
    } catch (e) {
      print(e);
      return Stream.empty();
    }
    return flutterBlue.scanResults;
  }

  Future<Stream<SignalMap>> continousScanStream({blacklist = const []}) async {
    if (await flutterBlue.isOn == false || _scanning) {
      return Stream.empty();
    }

    try {
      flutterBlue.startScan(scanMode: ScanMode.lowPower);
      List<ScanResult> results = [];
      var sub = flutterBlue.scanResults.listen(
        (event) {
          results = event;
        },
      );
      Stream<SignalMap> stream =
          Stream.periodic(Duration(milliseconds: 2650), (x) {
        SignalMap signalMap = SignalMap();
        List<ScanResult> currentResults = results;
        results = [];
        sub.cancel();
        sub = flutterBlue.scanResults.listen(
          (event) {
            results = event;
          },
        );
        currentResults.forEach((element) {
          signalMap.addBeaconReading(getBeaconName(element), getRSSI(element));
        });
        return signalMap;
      });
      return stream;
    } catch (e) {
      print(e);
      return Stream.empty();
    }
  }

  Future<APIResponse<RoomModel>> getRoomFromScan({
    List<ScanResult> scanResults,
  }) async {
    RestService restService = RestService();
    // SignalMap signalMap = SignalMap(buildingId: building.id);
    SignalMap signalMap = SignalMap();

    if (_gettingRoom)
      return APIResponse<RoomModel>(
        error: true,
        errorMessage: "Already getting room",
      );

    _gettingRoom = true;

    if (!await isOn) {
      return APIResponse<RoomModel>(
        error: true,
        errorMessage: "Bluetooth is not on",
      );
    }

    if (scanResults == null) {
      signalMap = await addStreamReadingsToSignalMap(signalMap, 2000);
    }

    APIResponse<RoomModel> apiResponseRoom =
        await restService.getRoomFromSignalMap(signalMap);
    if (apiResponseRoom.error == false) {
      RoomModel room = apiResponseRoom.data;
      _gettingRoom = false;
      return APIResponse<RoomModel>(data: room);
    } else {
      _gettingRoom = false;
      return APIResponse<RoomModel>(
          error: true, errorMessage: "Failed to assess room based on readings");
    }
  }

  Stream<List<Tuple2<String, int>>> getNearbyBeaconData() {
    try {
      // FlutterBlue does not properly close streams, so this timeout will have to match the await
      // duration found in the buildingManager.dart function _updateBeacons
      Stream<List<Tuple2<String, int>>> stream;
      flutterBlue
          .startScan(timeout: Duration(milliseconds: 3750))
          .then((_) => flutterBlue.stopScan());
      stream = flutterBlue.scanResults.transform(StreamTransformer<
          List<ScanResult>, List<Tuple2<String, int>>>.fromHandlers(
        handleData: (data, sink) {
          try {
            List<Tuple2<String, int>> resultingList = [];
            data.forEach((scanResult) {
              String name = getBeaconName(scanResult) ?? "";
              if (name != null && name.isNotEmpty) {
                resultingList.add(Tuple2(name, getRSSI(scanResult)));
              }
            });
            sink.add(resultingList);
          } catch (e) {
            sink.addError(e);
          }
        },
      ));
      return stream;
    } catch (e) {
      return null;
    }
  }

  Future<bool> get isOn async => await flutterBlue.isOn;

  String getBeaconName(ScanResult scanResult) {
    RegExp regex = RegExp("[a-zA-Z0-9]");
    try {
      String name = "";
      String firstKey = scanResult.advertisementData.serviceData.keys.first;
      for (int i = 0; i < 4; i++) {
        String character = String.fromCharCode(
            scanResult.advertisementData.serviceData[firstKey][i]);
        if (!regex.hasMatch(character)) return "";
        name = name + character;
      }
      return name;
    } catch (e) {
      return "";
    }
  }

  int getRSSI(ScanResult scanResult) => scanResult.rssi;
}
