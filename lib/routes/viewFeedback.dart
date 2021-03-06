import 'package:climify/models/questionAndFeedback.dart';
//import 'package:climify/models/feedbackQuestion.dart';
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class ViewFeedbackWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final QuestionAndFeedback feedback;
  final List<QuestionAndFeedback> feedbackList;
  final String user;

  const ViewFeedbackWidget({
    Key key,
    @required this.scaffoldKey,
    this.feedback,
    this.feedbackList,
    this.user,
  }) : super(key: key);

  @override
  ViewFeedbackWidgetState createState() => ViewFeedbackWidgetState();
}

class ViewFeedbackWidgetState extends State<ViewFeedbackWidget> {
  QuestionAndFeedback _feedback;
  List<QuestionAndFeedback> _feedbackList;
  String _user;

  @override
  void initState() {
    super.initState();
    _feedback = widget.feedback;
    _feedbackList = <QuestionAndFeedback>[];
    _user = widget.user;
    _setupState();
  }

  void _setupState() async {
    await Future.delayed(Duration.zero);
    setState(() {
      _feedbackList = widget.feedbackList
          .where((element) => element.question.id == _feedback.question.id)
          .toList();
    });
  }

  String getDate(QuestionAndFeedback feedback) {
    DateTime date = DateTime.parse(feedback.updatedAt);
    date = date.toLocal();
    final format = DateFormat('HH:mm, dd-MM-yyyy');
    return format.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Info about answer")),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Text(
                _feedback.question.value,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              child: Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  itemCount: _feedbackList.length,
                  itemBuilder: (_, index) =>
                      _buildingRow(_feedbackList[index], index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildingRow(QuestionAndFeedback feedback, int index) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(),
      )),
      child: Material(
        child: InkWell(
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: _user == "me"
                  ? Container(
                      child: Text(
                        "Answered " +
                            feedback.answer.value.toString() +
                            "\n"
                                "Date: " +
                            getDate(feedback),
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    )
                  : Container(
                      child: Text("Hallo"),
                    )),
        ),
      ),
    );
  }
}
