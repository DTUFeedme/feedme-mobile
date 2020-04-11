import 'dart:developer';

import 'package:climify/models/answerOption.dart';
import 'package:climify/models/api_response.dart';
//import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/styles/textStyles.dart';
import 'package:climify/widgets/roundedBox.dart';
import 'package:flutter/material.dart';
import 'package:climify/models/feedbackQuestion.dart';

import 'package:climify/services/rest_service.dart';

class FeedbackWidget extends StatefulWidget {
  final FeedbackQuestion question;
  final String room;
  final Function(FeedbackQuestion question, int option) returnFeedback;

  const FeedbackWidget({
    Key key,
    @required this.question,
    @required this.room,
    @required this.returnFeedback,
  }) : super(key: key);

  @override
  _FeedbackWidgetState createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  int _chosenOption;

  void _setChosenOption(int option) {
    setState(() {
      _chosenOption = option;
    });
  }

  void _sendFeedback() async {
    print("hej");
    if (_chosenOption != null && (widget.room != "" || widget.room == null)) {
      final restService = RestService();

      APIResponse<FeedbackQuestion> question = await restService.getQuestionByRoom(widget.room);
      APIResponse<List<AnswerOption>> answerOptionList;
      APIResponse<bool> status;

      if (question.error != true) {
        answerOptionList = await restService.getAnswerOptionsByRoom(question.data.sId);
      } else {
        print(question.errorMessage);
      }

      if (answerOptionList.error != true) {
        status = await restService.putFeedback(answerOptionList.data[_chosenOption].sId);
      } 

      if (status.data == true) {
        print("Answer has been added");
      } else {
        print(status.errorMessage);
      }

      //Seb, skal den her stadig være der?
      widget.returnFeedback(widget.question, _chosenOption);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            child: Text(
              widget.question.question,
              style: TextStyles.titleStyle,
            ),
            margin: EdgeInsets.only(bottom: 8),
          ),
          Column(
            //Det kan være det skal laves om her
            children: widget.question.answerOptions
                .asMap()
                .map(
                  (int i, String option) {
                    return MapEntry(
                      i,
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 40,
                        ),
                        child: RoundedBox(
                          onTap: () => _setChosenOption(i),
                          decoration: BoxDecoration(
                            color: i == _chosenOption
                                ? Colors.grey
                                : Colors.transparent,
                          ),
                          child: Container(
                            child: Center(
                              child: Text(
                                option,
                                style: TextStyles.optionStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
                .values
                .toList(),
          ),
          Container(
            margin: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 96,
            ),
            child: RoundedBox(
              onTap: _sendFeedback,
              decoration: BoxDecoration(
                color: _chosenOption == null ? Colors.blue : Colors.lightBlue,
              ),
              child: Center(
                child: Text(
                  "Send feedback",
                  style: TextStyles.bodyStyle.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
