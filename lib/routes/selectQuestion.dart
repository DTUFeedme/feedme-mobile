import 'package:climify/models/answerOption.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:flutter/material.dart';

import 'answerQuestion.dart';
import 'feedback.dart';

class SelectQuestion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<FeedbackQuestion> questionList = ModalRoute.of(context).settings.arguments;

      final answerOptionList = <AnswerOption>[];
      for (var e in questionList) {
        final answerOption1 = AnswerOption(
          timesAnswered: 1,
          sId: "5e8c5239b2b3782eb8727ea3",
          answer: "Too hot",
          iV: 0
        );
        final answerOption2 = AnswerOption(
          timesAnswered: 0,
          sId: "5e8c5239b2b3782eb8727ea4",
          answer: "Fine",
          iV: 0
        );
        final answerOption3 = AnswerOption(
          timesAnswered: 3,
          sId: "5e8c5239b2b3782eb8727ea5",
          answer: "Too cold",
          iV: 0
        );
        answerOptionList.add(answerOption1);
        answerOptionList.add(answerOption2);
        answerOptionList.add(answerOption3);
        e.answerOptions = answerOptionList;
      }

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose question to answer'),
      ),
      body: ListView.builder(
        itemCount: questionList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(questionList[index].question),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedbackWidget (question: questionList[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}