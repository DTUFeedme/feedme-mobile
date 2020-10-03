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
      int index = beacons.indexWhere((element) => element['name'] == name);
      if (index >= 0) {
        beacons[index]['signals'].add(signalStrength);
      } else {
        beacons.add({
          "name": name,
          "signals": [signalStrength],
        });
      }
    }
  }
}
