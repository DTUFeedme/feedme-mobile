import 'package:climify/widgets/listButton.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class ScannedDevices extends StatelessWidget {
  final List<Tuple2<String, int>> _beacons;
  final List<String> _blacklist;
  final String Function(int) _getSignalStrengthString;
  final void Function(String) _toggleBlacklistBeacon;

  const ScannedDevices(
    this._beacons,
    this._blacklist,
    this._getSignalStrengthString,
    this._toggleBlacklistBeacon, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        itemCount: _beacons.length,
        itemBuilder: (_, index) {
          bool _blacklisted = _blacklist.contains(_beacons[index].item1);
          TextStyle beaconTextStyle = TextStyle(
            fontSize: 24,
            color: _blacklisted ? Colors.red : Colors.black,
          );
          return ListButton(
            onTap: () => _toggleBlacklistBeacon(_beacons[index].item1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _beacons[index].item1,
                  style: beaconTextStyle,
                ),
                Text(
                  "Signal: " +
                      (_blacklisted
                          ? "Ignored"
                          : _getSignalStrengthString(_beacons[index].item2)),
                  style: beaconTextStyle,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
