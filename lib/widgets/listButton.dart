import 'package:flutter/material.dart';

class ListButton extends StatelessWidget {
  final void Function() onTap;
  final Widget child;

  const ListButton({
    Key key,
    this.onTap,
    this.child,
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
          child: Container(
            decoration: BoxDecoration(
                // border: Border(
                //   bottom: BorderSide(),
                // ),
                ),
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
