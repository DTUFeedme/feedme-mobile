import 'package:flutter/material.dart';

class SubmitButton extends StatefulWidget {
  final bool enabled;
  final Future<void> Function() onPressed;
  final String text;
  final double textSize;

  const SubmitButton({
    this.enabled = true,
    @required this.onPressed,
    this.text = "Submit",
    this.textSize = 16,
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: widget.textSize,
                ),
              ),
            ),
            Visibility(
              visible: waitingForResponse,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            // waitingForResponse ? LinearProgressIndicator() : Container(),
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
