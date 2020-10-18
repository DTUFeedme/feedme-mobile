import 'package:flutter/material.dart';

class SubmitButton extends StatefulWidget {
  final bool enabled;
  final Future<void> Function() onPressed;
  final String text;

  const SubmitButton({
    this.enabled = true,
    @required this.onPressed,
    this.text = "Submit",
    Key key,
  }) : super(key: key);

  @override
  _SubmitButtonState createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  bool waitingForResponse = false;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        color: widget.enabled ? Colors.lightBlue : Colors.redAccent,
        focusColor: Colors.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(widget.text),
            ),
            waitingForResponse ? LinearProgressIndicator() : Container(),
          ],
        ),
        onPressed: () async {
          if (widget.enabled && !waitingForResponse) {
            setState(() {
              waitingForResponse = true;
            });
            await widget.onPressed();
            setState(() {
              waitingForResponse = false;
            });
          }
        });
  }
}
