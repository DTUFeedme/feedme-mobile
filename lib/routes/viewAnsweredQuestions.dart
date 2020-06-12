import 'package:climify/models/api_response.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/models/questionAndFeedback.dart';
import 'package:climify/routes/viewFeedback.dart';
//import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/styles/textStyles.dart';
import 'package:climify/widgets/roundedBox.dart';
import 'package:flutter/material.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/roomModel.dart';

import 'package:climify/services/rest_service.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class ViewAnsweredQuestionsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String token;

  const ViewAnsweredQuestionsWidget({
    Key key,
    @required this.scaffoldKey, this.token,
  }) : super(key: key);

  @override
  ViewAnsweredQuestionsWidgetState createState() => ViewAnsweredQuestionsWidgetState();
}

class ViewAnsweredQuestionsWidgetState extends State<ViewAnsweredQuestionsWidget> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  String _token;
  RestService _restService = RestService();
  List<QuestionAndFeedback> _feedbackList = <QuestionAndFeedback>[];
  String _t = "week";
  
  @override
  void initState() {
    super.initState();
    _scaffoldKey = widget.scaffoldKey;
    _token = widget.token;
    _getFeedback();
  }

  Future<void> _getFeedback() async {
    await Future.delayed(Duration.zero);
    //String token = Provider.of<GlobalState>(context).globalState['token'];
    APIResponse<List<QuestionAndFeedback>> response = 
      await _restService.getFeedback(_token, "me", _t);
    if (response.error) return;
    setState(() {
      _feedbackList = response.data;
    });
  }

  void _focusFeedback(QuestionAndFeedback feedback) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => 
        ViewFeedbackWidget(
          scaffoldKey: _scaffoldKey, 
          feedback: feedback,
        )
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: RefreshIndicator(
        onRefresh: () => _getFeedback(),
        child: Container(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            itemCount: _feedbackList.length,
            itemBuilder: (_, index) => _buildingRow(_feedbackList[index]),
          ),
        ),
      ),
    );
  }


  Widget _buildingRow(QuestionAndFeedback feedback) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(),
        )
      ),
      child: Material(
        child: InkWell(
          onTap: () => _focusFeedback(feedback),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                feedback.question.value,
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}