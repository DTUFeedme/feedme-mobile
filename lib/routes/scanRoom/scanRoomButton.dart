import 'package:flutter/material.dart';

class ScanRoomButton extends StatelessWidget {
  final Function() onPressed;
  final double progress;
  final String text;
  final double size;
  final Color valueColor;
  final Color backgroundColor;
  final Color buttonColor;

  const ScanRoomButton({
    Key key,
    this.onPressed,
    this.progress,
    this.text,
    this.size,
    this.valueColor,
    this.backgroundColor,
    this.buttonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size),
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: InkWell(
          customBorder: CircleBorder(),
          onTap: () => onPressed(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: size - size / 8 - 4,
                width: size - size / 8 - 4,
                child: CircularProgressIndicator(
                  value: progress,
                  valueColor: AlwaysStoppedAnimation<Color>(valueColor),
                  strokeWidth: size / 8,
                  backgroundColor: backgroundColor,
                ),
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: size / 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
