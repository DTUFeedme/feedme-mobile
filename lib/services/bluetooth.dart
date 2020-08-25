import 'dart:async';

import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/signalMap.dart';
import 'package:climify/services/rest_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:tuple/tuple.dart';

class BluetoothServices {
  BluetoothServices();

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  bool _gettingRoom = false;

  Future<List<ScanResult>> scanForDevices(int timeoutms) async {
    if (await flutterBlue.isOn == false) {
      return [];
    }
    List<ScanResult> finalResults = [];
    try {
      flutterBlue.startScan(
          timeout: Duration(milliseconds: timeoutms));

      flutterBlue.scanResults
          .distinct((e1, e2) => listEquals(e1, e2))
          .listen((scanResult) {
        finalResults = scanResult;
      });

      flutterBlue.stopScan();
    } catch (e) {
      print(e);
    }
    await Future.delayed(Duration(milliseconds: timeoutms));
    print("final results:");
    finalResults.forEach((element) {
      if (getBeaconName(element) != null) {
        print(getBeaconName(element));
        print("serviceUuids: " +
            (element.advertisementData.serviceUuids).toString());
      }
    });
    return finalResults;
  }

  // Future<APIResponse<Tuple2<BuildingModel, RoomModel>>>
  //     getBuildingAndRoomFromScan() async {
  //   if (!await isOn) {
  //     return APIResponse<Tuple2<BuildingModel, RoomModel>>(
  //         error: true, errorMessage: "Bluetooth is not on");
  //   }

  //   RestService restService = RestService(context);
  //   SignalMap signalMap = SignalMap();

  //   List<ScanResult> scanResults = await scanForDevices(2000);
  //   scanResults.forEach((result) {
  //     String beaconName = getBeaconName(result);
  //     if (beaconName.isNotEmpty)
  //       signalMap.addBeaconReading(beaconName, getRSSI(result));
  //   });

  //   APIResponse<RoomModel> roomResponse =
  //       await restService.getRoomFromSignalMap(signalMap);

  //   if (!roomResponse.error) {
  //     APIResponse<BuildingModel> buildingResponse =
  //         await restService.getBuilding(roomResponse.data.building);
  //     if (!buildingResponse.error){
  //       return APIResponse<Tuple2<BuildingModel, RoomModel>>(
  //           data: Tuple2(buildingResponse.data, roomResponse.data));
  //     }else {
  //       return APIResponse<Tuple2<BuildingModel, RoomModel>>(
  //           error: true, errorMessage: buildingResponse.errorMessage);
  //     }
  //   } else {
  //     return APIResponse<Tuple2<BuildingModel, RoomModel>>(
  //         error: true, errorMessage: roomResponse.errorMessage);
  //   }
  // }

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
      scanResults = await scanForDevices(2000);
    }
    scanResults.forEach((result) {
      String beaconName = getBeaconName(result);
      signalMap.addBeaconReading(beaconName, getRSSI(result));
    });

    APIResponse<RoomModel> apiResponseRoom =
        await restService.getRoomFromSignalMap(signalMap);
    if (apiResponseRoom.error == false) {
      RoomModel room = apiResponseRoom.data;
      _gettingRoom = false;
      return APIResponse<RoomModel>(data: room);
    } else {
      _gettingRoom = false;
      // return APIResponse<RoomModel>(
      //     error: true, errorMessage: "Failed to assess room based on readings");
      return APIResponse<RoomModel>(
          error: true, errorMessage: apiResponseRoom.errorMessage);
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
