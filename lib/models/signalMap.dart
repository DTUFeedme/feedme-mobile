class SignalMap {
  List<Map<String, dynamic>> beacons;
  String buildingId;

  SignalMap({
    this.buildingId,
    // this.beacons,
  }) {
    beacons = [];
  }

  // Old functionality when buildings had beacons attached
  // factory SignalMap.withInitBeacons(
  //   List<Beacon> beaconNames, {
  //   String buildingId,
  // }) {
  //   List<Map<String, dynamic>> signalMapBeacons = [];
  //   beaconNames.forEach((b) {
  //     signalMapBeacons.add({
  //       'name': b.name,
  //       'signals': [],
  //     });
  //   });
  //   return SignalMap(
  //     buildingId: buildingId,
  //     beacons: signalMapBeacons,
  //   );
  // }

  void addBeaconReading(String name, int signalStrength) {
    if (name.isNotEmpty) {
      beacons.add({
        'name': name,
        'signals': [signalStrength],
      });
    }
  }
}
