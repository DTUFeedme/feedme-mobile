import 'package:flutter/material.dart';

class EmptyListText extends StatelessWidget {
  final String text;

  const EmptyListText({
    this.text,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          color: Colors.black54,
        ),
      ),
    );
  }
}
