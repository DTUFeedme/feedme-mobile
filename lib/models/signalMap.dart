class SignalMap {
  List<Map<String, dynamic>> beacons;

  SignalMap() {
    beacons = [];
  }

  void addBeaconReading(
    String name,
    int signalStrength, {
    List<String> blacklist = const [],
  }) {
    if (name != null && name.isNotEmpty && !blacklist.contains(name)) {
      beacons.add({
        'name': name,
        'signals': [signalStrength],
      });
    }
  }
}
