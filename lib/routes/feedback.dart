import 'package:climify/models/api_response.dart';
//import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/styles/textStyles.dart';
import 'package:climify/widgets/roundedBox.dart';
import 'package:flutter/material.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/roomModel.dart';

import 'package:climify/services/rest_service.dart';

class FeedbackWidget extends StatefulWidget {
  final FeedbackQuestion question;
  final RoomModel room;

  const FeedbackWidget({
    Key key,
    this.question,
    this.room,
  }) : super(key: key);

  @override
  _FeedbackWidgetState createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  int _chosenOption;
  RestService _restService;

  @override
  void initState() {
    super.initState();
    _restService = RestService(context);
  }

  void _setChosenOption(int option) {
    setState(() {
      _chosenOption = option;
    });
  }

  void _sendFeedback() async {
    if (_chosenOption != null && (widget.question != null)) {
      APIResponse<bool> status = await _restService.postFeedback(
        widget.question,
        _chosenOption,
        widget.room,
      );

      if (status.data == true) {
        print("Answer has been added");
      } else {
        print(status.errorMessage);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                widget.question.value,
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
                                  option.value,
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
