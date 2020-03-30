import 'package:flutter/material.dart';

class RoundedBox extends StatelessWidget {
  final Widget child;
  final BoxDecoration decoration;
  final Function() onTap;
  RoundedBox({Key key, @required this.child, this.decoration, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: Container(
        decoration: decoration.copyWith(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(),
        ),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: child,
      ),
    );
  }
}
