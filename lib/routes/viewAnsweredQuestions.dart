import 'package:climify/models/api_response.dart';
import 'package:climify/models/questionAndFeedback.dart';
import 'package:climify/routes/viewFeedback.dart';
//import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/widgets/dateFilterButton.dart';
import 'package:climify/widgets/emptyListText.dart';
import 'package:climify/widgets/listButton.dart';
import 'package:flutter/material.dart';

import 'package:climify/services/rest_service.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class ViewAnsweredQuestionsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String user;
  final String t;
  final Function(String) setT;

  const ViewAnsweredQuestionsWidget({
    Key key,
    @required this.scaffoldKey,
    this.user,
    this.t = 'week',
    @required this.setT,
  }) : super(key: key);

  @override
  ViewAnsweredQuestionsWidgetState createState() =>
      ViewAnsweredQuestionsWidgetState();
}

class ViewAnsweredQuestionsWidgetState
    extends State<ViewAnsweredQuestionsWidget> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  RestService _restService;
  List<QuestionAndFeedback> _feedbackList = <QuestionAndFeedback>[];
  List<QuestionAndFeedback> _tempFeedbackList = <QuestionAndFeedback>[];
  String _t;
  String _user = "";

  @override
  void initState() {
    super.initState();
    _restService = RestService();
    _scaffoldKey = widget.scaffoldKey;
    _user = widget.user;
    _t = widget.t;
    _getFeedback();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _getFeedback() async {
    await Future.delayed(Duration.zero);
    APIResponse<List<QuestionAndFeedback>> response =
        await _restService.getFeedback(_user, _t);
    if (response.error) return;

    response.data = response.data.reversed.toList();

    void _addToList(QuestionAndFeedback qf) {
      // if (qf.answer != null && qf.question != null) {
      _tempFeedbackList.add(qf);
      // }
    }

    _tempFeedbackList = [];
    for (int i = 0; i < response.data.length; i++) {
      if (_tempFeedbackList.length == 0) {
        _addToList(response.data[i]);
      } else {
        for (int j = 0; j < _tempFeedbackList.length; j++) {
          if (_tempFeedbackList[j].question.id ==
              response.data[i].question.id) {
            break;
          } else if (j == (_tempFeedbackList.length - 1)) {
            _addToList(response.data[i]);
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
    widget.setT(t);
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
        onRefresh: () {
          return _getFeedback();
        },
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
            _tempFeedbackList.isNotEmpty
                ? Container(
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
                : Expanded(
                    child: EmptyListText(
                      text:
                          'You have not provided any feedback within the last $_t',
                    ),
                  ),
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
