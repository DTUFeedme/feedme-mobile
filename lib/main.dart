import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/routes/enterRoomNumber.dart';
import 'package:climify/routes/feedback.dart';
import 'package:climify/test/testQuestion.dart';
import 'package:flutter/material.dart';

import 'package:async/async.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Climify Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Climify Feedback Tech Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _room = "";
  String _testText = "";

  void _changeRoom(String room) {
    setState(() {
      _room = room;
    });
  }

  void _setTestText(String text) async {
    setState(() {
      _testText = text;
    });
  }

  void _receiveFeedback(FeedbackQuestion question, int option) {
    _setTestText(
        "Answered: ${question.options[option]}. Room number is $_room");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Container(),
              flex: 1,
            ),
            Flexible(
              child: EnterRoomNumber(
                onTextInput: _changeRoom,
              ),
              flex: 3,
            ),
            Flexible(
              child: FeedbackWidget(
                question: testQuestion,
                room: _room,
                returnFeedback: _receiveFeedback,
              ),
              flex: 10,
            ),
            Flexible(
              child: InkWell(
                onLongPress: () => _setTestText(""),
                child: Container(
                  child: Text(
                    _testText,
                  ),
                ),
              ),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }
}
