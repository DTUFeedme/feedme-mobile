import 'package:flutter/material.dart';

class ListButton extends StatelessWidget {
  final void Function() onTap;
  final void Function() onLongPress;
  final Widget child;
  final Color color;

  const ListButton({
    Key key,
    this.onTap,
    this.onLongPress,
    this.child,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Material(
        elevation: 3,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            color: color,
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
