class SignalMap {
  List<Map<String, dynamic>> beacons;
  String buildingId;

  SignalMap({this.buildingId}) {
    beacons = [];
  }

  void addBeaconReading(String name, int signalStrength) {
    if (beacons
        .where((element) => element['name'].toString() == name.toString())
        .isNotEmpty) {
      beacons
          .firstWhere((element) => element['name'] == name)['signals']
          .add(signalStrength);
    } else {
      beacons.add({
        "name": name,
        "signals": [signalStrength]
      });
    }
  }
}
