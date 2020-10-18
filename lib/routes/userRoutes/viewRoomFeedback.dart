import 'package:climify/models/answerOption.dart';
import 'package:climify/models/questionStatistics.dart';
import 'package:climify/widgets/dateFilterButton.dart';
import 'package:climify/widgets/emptyListText.dart';
import 'package:climify/widgets/extendableWindowBase.dart';
import 'package:climify/widgets/listButton.dart';
import 'package:flutter/material.dart';

class ViewRoomFeedback extends StatelessWidget {
  final Function(String) refreshQuestions;
  final String dateFilter;
  final List<QuestionStatisticsModel> questions;

  const ViewRoomFeedback({
    Key key,
    this.refreshQuestions,
    this.dateFilter = "week",
    this.questions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height / 10,
            ),
            child: Row(
              children: <Widget>[
                DateFilterButton(
                  setT: refreshQuestions,
                  value: "hour",
                  selected: dateFilter == "hour",
                ),
                DateFilterButton(
                  setT: refreshQuestions,
                  value: "day",
                  selected: dateFilter == "day",
                ),
                DateFilterButton(
                  setT: refreshQuestions,
                  value: "week",
                  selected: dateFilter == "week",
                ),
                DateFilterButton(
                  setT: refreshQuestions,
                  value: "month",
                  selected: dateFilter == "month",
                ),
                DateFilterButton(
                  setT: refreshQuestions,
                  value: "year",
                  selected: dateFilter == "year",
                ),
              ],
            ),
          ),
          Expanded(
            child: questions.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    itemCount: questions.length,
                    itemBuilder: (_, index) => _statisticsRow(questions[index]),
                  )
                : EmptyListText(
                    text: 'This room has no questions',
                  ),
          ),
        ],
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

    var _extendableWindowKey = GlobalKey<ExtendableWindowState>();
    return ListButton(
      onTap: () => _extendableWindowKey.currentState.toggleExpand(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 8,
        ),
        child: ExtendableWindow(
          key: _extendableWindowKey,
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
