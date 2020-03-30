import 'package:climify/styles/textStyles.dart';
import 'package:flutter/material.dart';

class EnterRoomNumber extends StatelessWidget {
  final Function(String) onTextInput;
  EnterRoomNumber({Key key, this.onTextInput}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "Enter Room Number",
            style: TextStyles.titleStyle,
          ),
          TextField(
            autocorrect: false,
            style: TextStyles.bodyStyle,
            onChanged: (String text) => onTextInput(text),
          ),
        ],
      ),
    );
  }
}
