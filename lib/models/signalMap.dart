class SignalMap {
  List<Map<String, dynamic>> beacons;
  String buildingId;

  SignalMap(
    this.buildingId,
  ) {
    beacons = [];
  }

  void addBeaconReading(String beaconId, int signalStrength) {
    if (beacons
        .where(
            (element) => element['beaconId'].toString() == beaconId.toString())
        .isNotEmpty) {
      beacons
          .firstWhere((element) => element['beaconId'] == beaconId)['signals']
          .add(signalStrength);
    } else {
      beacons.add({
        "beaconId": beaconId,
        "signals": [signalStrength]
      });
    }
  }
}
