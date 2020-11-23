import 'package:climify/widgets/listButton.dart';
import 'package:flutter/material.dart';

class BlacklistedDevices extends StatelessWidget {
  final List<String> _blacklist;
  final void Function(String) _toggleBlacklistBeacon;

  const BlacklistedDevices(
    this._blacklist,
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
        itemCount: _blacklist.length,
        itemBuilder: (_, index) {
          TextStyle textStyle = TextStyle(
            fontSize: 24,
          );
          return ListButton(
            onTap: () => _toggleBlacklistBeacon(_blacklist[index]),
            child: Text(
              _blacklist[index],
              style: textStyle,
            ),
          );
        },
      ),
    );
  }
}
