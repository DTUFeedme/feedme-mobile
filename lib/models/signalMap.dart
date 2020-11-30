class SignalMap {
  List<Map<String, dynamic>> beacons;

  SignalMap() {
    beacons = [];
  }

  List<Map<String, dynamic>> get avgBeaconSignals {
    List<Map<String, dynamic>> avgBeaconSignals = beacons.map((beacon) {
      List<int> signals = beacon["signals"];
      int total =
          signals.fold(0, (previousValue, element) => previousValue + element);
      int len = signals.length;
      return {
        "name": beacon["name"],
        "signal": total ~/ len,
      };
    }).toList();
    return avgBeaconSignals;
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
