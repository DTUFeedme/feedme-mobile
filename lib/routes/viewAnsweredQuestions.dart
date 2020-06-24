import 'package:climify/models/api_response.dart';
import 'package:climify/models/questionAndFeedback.dart';
import 'package:climify/routes/viewFeedback.dart';
//import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/widgets/dateFilterButton.dart';
import 'package:climify/widgets/listButton.dart';
import 'package:flutter/material.dart';

import 'package:climify/services/rest_service.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class ViewAnsweredQuestionsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String token;
  final String user;

  const ViewAnsweredQuestionsWidget({
    Key key,
    @required this.scaffoldKey,
    this.token,
    this.user,
  }) : super(key: key);

  @override
  ViewAnsweredQuestionsWidgetState createState() =>
      ViewAnsweredQuestionsWidgetState();
}

class ViewAnsweredQuestionsWidgetState
    extends State<ViewAnsweredQuestionsWidget> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  String _token;
  RestService _restService = RestService();
  List<QuestionAndFeedback> _feedbackList = <QuestionAndFeedback>[];
  List<QuestionAndFeedback> _tempFeedbackList = <QuestionAndFeedback>[];
  String _t = "week";
  String _user = "";

  @override
  void initState() {
    super.initState();
    _scaffoldKey = widget.scaffoldKey;
    _token = widget.token;
    _user = widget.user;
    _getFeedback();
  }

  Future<void> _getFeedback() async {
    await Future.delayed(Duration.zero);
    _tempFeedbackList = [];
    APIResponse<List<QuestionAndFeedback>> response =
        await _restService.getFeedback(_token, _user, _t);
    if (response.error) return;
    response.data = response.data.reversed.toList();
    for (int i = 0; i < response.data.length; i++) {
      if (_tempFeedbackList.length == 0) {
        _tempFeedbackList.add(response.data[i]);
      } else {
        for (int j = 0; j < _tempFeedbackList.length; j++) {
          if (_tempFeedbackList[j].question.id ==
              response.data[i].question.id) {
            break;
          } else if (j == (_tempFeedbackList.length - 1)) {
            _tempFeedbackList.add(response.data[i]);
          }
        }
      }
    }
    setState(() {
      _feedbackList = response.data;
      _tempFeedbackList = _tempFeedbackList;
    });
  }

  void _focusFeedback(QuestionAndFeedback feedback) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ViewFeedbackWidget(
                scaffoldKey: _scaffoldKey,
                feedback: feedback,
                feedbackList: _feedbackList,
                user: _user,
              )),
    );
  }

  void setT(String t) {
    setState(() {
      _t = t;
    });
    _getFeedback();
  }

  String getDate(QuestionAndFeedback feedback) {
    DateTime date = DateTime.parse(feedback.updatedAt);
    date = date.toLocal();
    final format = DateFormat('HH:mm, dd-MM-yyyy');
    return format.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RefreshIndicator(
        onRefresh: () => _getFeedback(),
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DateFilterButton(
                    value: "hour",
                    selected: _t == "hour",
                    setT: setT,
                  ),
                  DateFilterButton(
                    value: "day",
                    selected: _t == "day",
                    setT: setT,
                  ),
                  DateFilterButton(
                    value: "week",
                    selected: _t == "week",
                    setT: setT,
                  ),
                  DateFilterButton(
                    value: "month",
                    selected: _t == "month",
                    setT: setT,
                  ),
                  DateFilterButton(
                    value: "year",
                    selected: _t == "year",
                    setT: setT,
                  ),
                ],
              ),
            ),
            Container(
              child: Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  itemCount: _tempFeedbackList.length,
                  itemBuilder: (_, index) => ListButton(
                    onTap: () => _focusFeedback(_tempFeedbackList[index]),
                    child: Text(
                      (_tempFeedbackList[index].question.value +
                          "\n"
                              "Last answered: " +
                          getDate(
                            _tempFeedbackList[index],
                          )),
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget _buildingRow(QuestionAndFeedback feedback, int index) {
  //   return Container(
  //     decoration: BoxDecoration(
  //         border: Border(
  //       bottom: BorderSide(),
  //     )),
  //     child: Material(
  //       child: InkWell(
  //         onTap: () => _focusFeedback(feedback),
  //         child: Container(
  //           padding: EdgeInsets.symmetric(vertical: 12),
  //           child: Text(
  //             feedback.question.value +
  //                 "\n"
  //                     "Last answered: " +
  //                 getDate(feedback),
  //             style: TextStyle(
  //               fontSize: 18,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
