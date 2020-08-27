class SignalMap {
  List<Map<String, dynamic>> beacons;

  SignalMap() {
    beacons = [];
  }

  void addBeaconReading(String name, int signalStrength) {
    if (name != null && name.isNotEmpty) {
      beacons.add({
        'name': name,
        'signals': [signalStrength],
      });
    }
  }
}
