import 'package:climify/models/beacon.dart';

class SignalMap {
  List<Map<String, dynamic>> beacons;
  String buildingId;
  bool rigidBeaconNames;

  SignalMap({this.buildingId, this.beacons, this.rigidBeaconNames = false});

  factory SignalMap.withInitBeacons(
    List<Beacon> beaconNames, {
    String buildingId,
  }) {
    List<Map<String, dynamic>> signalMapBeacons = [];
    beaconNames.forEach((b) {
      signalMapBeacons.add({
        'name': b.name,
        'signals': [],
      });
    });
    return SignalMap(
        buildingId: buildingId,
        beacons: signalMapBeacons,
        rigidBeaconNames: true);
  }

  void addBeaconReading(String name, int signalStrength) {
    if (beacons == null) beacons = [];
    Map<String, dynamic> first = beacons.firstWhere(
        (element) => element.containsValue(name),
        orElse: () => null);
    if (first != null) {
      first['signals'].add(signalStrength);
    } else if (!rigidBeaconNames && name.isNotEmpty) {
      beacons.add({
        'name': name,
        'signals': [signalStrength],
      });
    }
    print("current beacons: $beacons");
    // if (name != "") {
    //   print("adding $name with RSSI: $signalStrength to map");
    //   beacons.add({
    //     "name": name,
    //     "signals": [signalStrength]
    //   });
    // }
  }
}
