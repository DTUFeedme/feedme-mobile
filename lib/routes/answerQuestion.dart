import 'package:climify/models/feedbackQuestion.dart';
import 'package:flutter/material.dart';

class AnswerQuestion extends StatelessWidget {
  // Declare a field that holds the Todo.
  final FeedbackQuestion question;

  // In the constructor, require a Todo.
  AnswerQuestion({Key key, @required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(question.question),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(question.question),
      ),
    );
  }
}