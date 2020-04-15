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
  //final String room;
  //final Function(FeedbackQuestion question) returnFeedback;

  const FeedbackWidget({
    Key key,
    @required this.question,
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
    if (_chosenOption != null && (widget.question != null)) {
      final restService = RestService();

      APIResponse<bool> status = await restService.putFeedback(widget.question.answerOptions[_chosenOption].sId);

      if (status.data == true) {
        print("Answer has been added");
      } else {
        print(status.errorMessage);
      }

      //widget.returnFeedback(widget.question);
      Navigator.pop(context);

      //Seb, skal den her stadig være der?
      //widget.returnFeedback(widget.question);
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
        appBar: AppBar(
        title: Text('Answer the question'),
        ),
        body: Container(
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
              children: widget.question.answerOptions
                  .asMap()
                  .map(
                    (int i, dynamic option) {
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
                                  option.answer,
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
      ),
    );
  }
}
