import 'package:flutter/material.dart';

class ExtendableWindow extends StatefulWidget {
  final Widget header;
  final Widget body;
  final bool extendable;

  const ExtendableWindow({
    @required this.header,
    @required this.body,
    this.extendable = true,
    Key key,
  }) : super(key: key);

  @override
  _ExtendableWindowState createState() => _ExtendableWindowState();
}

class _ExtendableWindowState extends State<ExtendableWindow>
    with TickerProviderStateMixin {
  AnimationController _expandController;
  Animation<double> _animation;
  bool _expanded;

  @override
  void initState() {
    _expanded = false;
    _prepareAnimations();
    super.initState();
  }

  void _prepareAnimations() {
    _expandController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _toggleExpand() {
    if (_expanded) {
      _expandController.reverse();
    } else {
      _expandController.forward();
    }
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {
          if (widget.extendable || _expanded == true) _toggleExpand();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            widget.header,
            SizeTransition(
              axisAlignment: 1.0,
              sizeFactor: _animation,
              child: widget.body,
            ),
          ],
        ),
      ),
    );
  }
}
