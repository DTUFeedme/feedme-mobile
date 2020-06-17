import 'package:climify/models/answerOption.dart';
import 'package:climify/models/questionStatistics.dart';
import 'package:climify/widgets/extendableWindowBase.dart';
import 'package:climify/widgets/listButton.dart';
import 'package:flutter/material.dart';

class ViewRoomFeedback extends StatelessWidget {
  final List<QuestionStatisticsModel> questions;

  const ViewRoomFeedback({
    Key key,
    this.questions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        itemCount: questions.length,
        itemBuilder: (_, index) => _statisticsRow(questions[index]),
      ),
    );
  }

  Widget _statisticsRow(QuestionStatisticsModel qStats) {
    Map<String, int> timesAnsweredMap = {};
    qStats.answers.forEach((feedbackAnswer) {
      timesAnsweredMap[feedbackAnswer.value] = feedbackAnswer.timesAnswered;
    });

    int _getTimesAnswered(
      AnswerOption answerOption,
    ) {
      if (timesAnsweredMap.containsKey(answerOption.value)) {
        return timesAnsweredMap[answerOption.value];
      } else {
        return 0;
      }
    }

    var _hey = GlobalKey<ExtendableWindowState>();
    return ListButton(
      onTap: () => _hey.currentState.toggleExpand(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 8,
        ),
        child: ExtendableWindow(
          key: _hey,
          extendable: false,
          header: Container(
            child: Text(
              qStats.question.value,
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          body: Column(
            children: qStats.question.answerOptions
                .map(
                  (answerOption) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(answerOption.value),
                      Text("${_getTimesAnswered(
                        answerOption,
                      )}"),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
