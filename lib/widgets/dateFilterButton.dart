import 'package:climify/styles/textStyles.dart';
import 'package:climify/widgets/roundedBox.dart';
import 'package:flutter/material.dart';

class DateFilterButton extends StatelessWidget {
  final Function(String) setT;
  final String value;
  final bool selected;

  const DateFilterButton({
    Key key,
    this.setT,
    this.value,
    this.selected,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width / 6,
      ),
      margin: EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 6,
      ),
      child: RoundedBox(
        onTap: () => setT(value),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.transparent,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 6,
          ),
          child: Center(
            child: Text(
              '${value[0].toUpperCase()}${value.substring(1)}',
              style: TextStyles.bodyStyle,
            ),
          ),
        ),
      ),
    );
  }
}
