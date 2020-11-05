import 'package:flutter/material.dart';

class ProgressButton extends StatefulWidget {
  final bool enabled;
  final bool showBar;
  final double progress;
  final Future<void> Function() onPressed;
  final String text;
  final double textSize;

  const ProgressButton({
    this.enabled = true,
    this.showBar = false,
    this.progress,
    @required this.onPressed,
    this.text = "Submit",
    this.textSize = 16,
    Key key,
  }) : super(key: key);

  @override
  _ProgressButtonState createState() => _ProgressButtonState();
}

class _ProgressButtonState extends State<ProgressButton> {
  bool waitingForResponse = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

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
              visible: widget.showBar,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: LinearProgressIndicator(
                value: widget.progress,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            // waitingForResponse ? LinearProgressIndicator() : Container(),
          ],
        ),
        onPressed: () async {
          if (widget.enabled && !waitingForResponse) {
            widget.onPressed();
          }
        });
  }
}
