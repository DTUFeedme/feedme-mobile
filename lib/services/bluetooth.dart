import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';

class BluetoothServices {
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  // Future<Stream<List<ScanResult>>> scanForDevices() async {
  //   Future<void> _delayedStopScan() async {
  //     await Future.delayed(Duration(seconds: 3));
  //     flutterBlue.stopScan();
  //   }

  //   try {
  //     flutterBlue.startScan(timeout: Duration(seconds: 3));
  //     _delayedStopScan();
  //     return flutterBlue.scanResults;
  //   } catch (e) {
  //     print(e);
  //     return Stream.empty();
  //   }
  // }

  Future<List<ScanResult>> scanForDevices(int timeoutms) async {
    List<ScanResult> finalResults = [];
    flutterBlue.startScan(timeout: Duration(milliseconds: timeoutms));

    flutterBlue.scanResults.listen((results) {
      results.forEach((element) {
        if (!finalResults.contains(element)) {
          finalResults.add(element);
        }
      });
    });

    flutterBlue.stopScan();
    await Future.delayed(Duration(seconds: timeoutms));
    return finalResults;
  }

  Future<bool> get isOn async => await flutterBlue.isOn;

  String getBeaconName(ScanResult scanResult) {
    try {
      String name = "";
      String firstKey = scanResult.advertisementData.serviceData.keys.first;
      for (int i = 0; i < 4; i++) {
        String character = String.fromCharCode(
            scanResult.advertisementData.serviceData[firstKey][i]);
        name = name + character;
      }
      return name;
    } catch (e) {
      return "";
    }
  }

  int getRSSI(ScanResult scanResult) => scanResult.rssi;

  String getBeaconID(ScanResult scanResult) {
    DeviceIdentifier deviceIdentifier = scanResult.device.id;
    return deviceIdentifier.toString();
  }
}
