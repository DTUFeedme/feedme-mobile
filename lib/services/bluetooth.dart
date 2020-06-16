import 'dart:async';

import 'package:climify/models/api_response.dart';
import 'package:climify/models/beacon.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/signalMap.dart';
import 'package:climify/services/rest_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothServices {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  bool _gettingRoom = false;

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
    if (await flutterBlue.isOn == false) {
      return [];
    }
    List<ScanResult> finalResults = [];
    flutterBlue.startScan(timeout: Duration(milliseconds: timeoutms));

    // flutterBlue.scanResults.listen((results) {
    //   results.forEach((element) {
    //     if (!finalResults.contains(element)) {
    //       finalResults.add(element);
    //     }
    //   });
    // });

    flutterBlue.scanResults
        .distinct((e1, e2) => listEquals(e1, e2))
        .listen((scanResult) {
      finalResults = scanResult;
    });

    flutterBlue.stopScan();
    await Future.delayed(Duration(milliseconds: timeoutms));
    return finalResults;
  }

  Future<APIResponse<String>> getBuildingIdFromScan(
    String token,
  ) async {
    if (!await isOn) {
      return APIResponse<String>(
          error: true, errorMessage: "Bluetooth is not on");
    }

    RestService restService = RestService();
    APIResponse<List<Beacon>> allBeaconsResponse =
        await restService.getAllBeacons(token);
    if (!allBeaconsResponse.error) {
      List<Beacon> allBeacons = allBeaconsResponse.data;
      Map<String, int> scannedBuildings = {};
      List<ScanResult> scanResults = await scanForDevices(2000);
      scanResults.forEach((result) {
        String beaconName = getBeaconName(result);
        if (allBeacons
            .where((element) => element.name == beaconName)
            .isNotEmpty) {
          String beaconBuilding = allBeacons
              .firstWhere((element) => element.name == beaconName)
              .building
              .id;
          scannedBuildings[beaconBuilding] =
              scannedBuildings[beaconBuilding] == null
                  ? 1
                  : scannedBuildings[beaconBuilding] + 1;
        }
      });
      String buildingIdMostScans = "";
      int highestVal = 0;
      scannedBuildings.forEach((key, value) {
        if (value > highestVal) {
          buildingIdMostScans = key;
          highestVal = value;
        }
      });
      if (buildingIdMostScans != "") {
        return APIResponse<String>(data: buildingIdMostScans);
      } else {
        return APIResponse<String>(
            error: true, errorMessage: "Failed getting building based on scan");
      }
    } else {
      return APIResponse<String>(
          error: true, errorMessage: "Failed getting beacons from database");
    }
  }

  Future<APIResponse<RoomModel>> getRoomFromBuilding(
    BuildingModel building,
    String token,
  ) async {
    RestService restService = RestService();
    SignalMap signalMap = SignalMap(building.id);
    List<Beacon> beacons = [];

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

    APIResponse<List<Beacon>> apiResponseBeacons =
        await restService.getBeaconsOfBuilding(token, building);
    if (!apiResponseBeacons.error) {
      beacons = apiResponseBeacons.data;
    } else {
      return APIResponse<RoomModel>(
        error: true,
        errorMessage: "Couldn't get beacons of building",
      );
    }

    // print("beacons: $beacons");

    // List<ScanResult> scanResults = [];
    // scanForDevices(2200).then((results) => scanResults.addAll(results));
    // await Future.delayed(Duration(milliseconds: 250));
    // scanForDevices(2000).then((results) => scanResults.addAll(results));
    // await Future.delayed(Duration(milliseconds: 250));
    // scanForDevices(1900).then((results) => scanResults.addAll(results));
    // await Future.delayed(Duration(milliseconds: 2000));

    List<ScanResult> scanResults = await scanForDevices(2200);

    scanResults.forEach((result) {
      String beaconName = getBeaconName(result);
      if (beacons.where((element) => element.name == beaconName).isNotEmpty) {
        String beaconId =
            beacons.firstWhere((element) => element.name == beaconName).id;
        signalMap.addBeaconReading(beaconId, getRSSI(result));
      }
    });

    APIResponse<RoomModel> apiResponseRoom =
        await restService.getRoomFromSignalMap(token, signalMap);
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
