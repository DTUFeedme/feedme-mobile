import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:climify/models/api_response.dart';
import 'package:climify/models/beaconModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/signalMap.dart';
import 'package:climify/services/rest_service.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothServices {
  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();
  final List<BeaconModel> beacons = [];

  Future<void> dispose() async {
    await BeaconsPlugin.stopMonitoring;
    await beaconEventsController.close();
    return;
  }

  Future<void> startScanner() async {
    BeaconsPlugin.listenToBeacons(beaconEventsController);
    // if you need to monitor also major and minor use the original version and not this fork
    // BeaconsPlugin.addRegion("kontakt", "01022022-f88f-0000-00ae-9605fd9bb620")
    //     .then((result) {
    //   print(result);
    // });

    //Send 'true' to run in background [OPTIONAL]
    await BeaconsPlugin.runInBackground(true);

    //IMPORTANT: Start monitoring once scanner is setup & ready (only for Android)
    if (Platform.isAndroid) {
      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        if (call.method == 'scannerReady') {
          await BeaconsPlugin.startMonitoring;
        }
      });
    } else if (Platform.isIOS) {
      await BeaconsPlugin.startMonitoring;
    }
    return;
  }

  Future<Stream<List<BeaconModel>>> scanForBeacons() async {
    await startScanner();
    BeaconsPlugin.startMonitoring;
    beacons.clear();

    Stream<List<BeaconModel>> transformedStream =
        beaconEventsController.stream.transform(StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        try {
          Map<String, dynamic> beaconJson = json.decode(data);
          BeaconModel newBeacon = BeaconModel(
              "${beaconJson['major']} - ${beaconJson['minor']}",
              int.parse(beaconJson['rssi']));
          int foundIndex =
              beacons.indexWhere((element) => element.name == newBeacon.name);
          if (foundIndex != -1) {
            beacons[foundIndex] = newBeacon;
          } else {
            beacons.add(newBeacon);
          }
          sink.add(beacons);
        } catch (e) {
          sink.addError(e);
        }
      },
      handleDone: (sink) => sink.close(),
      handleError: (error, stackTrace, sink) => sink.addError(error),
    ));
    return transformedStream;
  }

  Future<Stream<SignalMap>> scanForSignalMaps(int intervalMS, {List<String> blacklist = const []}) async {
    Stream<List<BeaconModel>> beaconStream = await scanForBeacons();
    SignalMap signalMap = SignalMap();
    beaconStream.listen(
      (data) {
        data.forEach((element) {
          signalMap.addBeaconReading(element.name, element.rssi, blacklist: blacklist);
        });
      },
    );
    return Stream.periodic(Duration(milliseconds: intervalMS), (_) {
      SignalMap currentSignalMap = signalMap;
      signalMap = SignalMap();
      return currentSignalMap;
    });
  }

  Future<void> stopScanning() async {
    await BeaconsPlugin.stopMonitoring;
    return;
  }

  Future<void> resumeScanning() async {
    await BeaconsPlugin.startMonitoring;
    return;
  }

  Future<APIResponse<RoomModel>> getRoomFromScan() async {
    final int ms = 1250;
    RestService restService = RestService();
    SignalMap signalMap = SignalMap();

    Stream<SignalMap> signalMapStream = await scanForSignalMaps(ms);
    await Future.delayed(Duration(milliseconds: (ms * 1.1).round()));
    signalMap = await signalMapStream.firstWhere((element) => element != null,
        orElse: () => SignalMap());
    await BeaconsPlugin.stopMonitoring;

    APIResponse<RoomModel> apiResponseRoom =
        await restService.getRoomFromSignalMap(signalMap);
    if (apiResponseRoom.error == false) {
      RoomModel room = apiResponseRoom.data;
      return APIResponse<RoomModel>(data: room);
    } else {
      return APIResponse<RoomModel>(
          error: true, errorMessage: "Failed to assess room based on readings");
    }
  }
}
