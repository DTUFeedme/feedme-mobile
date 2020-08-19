class SignalMap {
  List<Map<String, dynamic>> beacons;
  String buildingId;

  SignalMap(
    this.buildingId,
  ) {
    beacons = [];
  }

  void addBeaconReading(String uuid, int signalStrength) {
    if (beacons
        .where(
            (element) => element['uuid'].toString() == uuid.toString())
        .isNotEmpty) {
      beacons
          .firstWhere((element) => element['uuid'] == uuid)['signals']
          .add(signalStrength);
    } else {
      beacons.add({
        "uuid": uuid,
        "signals": [signalStrength]
      });
    }
  }
}
