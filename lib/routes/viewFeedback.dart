import 'package:climify/models/api_response.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/models/questionAndFeedback.dart';
//import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/styles/textStyles.dart';
import 'package:climify/widgets/roundedBox.dart';
import 'package:flutter/material.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/roomModel.dart';

import 'package:climify/services/rest_service.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class ViewFeedbackWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ViewFeedbackWidget({
    Key key,
    @required this.scaffoldKey,
  }) : super(key: key);

  @override
  _ViewFeedbackWidgetState createState() => _ViewFeedbackWidgetState();
}

class _ViewFeedbackWidgetState extends State<ViewFeedbackWidget> {
  final RestService restService = RestService();
  final String _token = "";
  List<QuestionAndFeedback> _feedbackList = <QuestionAndFeedback>[];
   String _t = "week";
  
  @override
  void initState() {
    super.initState();
    _scaffoldKey = widget.scaffoldKey;
    _getFeedback();
  }

  Future<void> _getFeedback() async {
    String token = Provider.of<GlobalState>(context).globalState['token'];
    APIResponse<List<QuestionAndFeedback>> response = await restService.getFeedback(token, "me", _t);
    if (response.error) {

    }
    List<QuestionAndFeedback> qF = response.data;
        setState(() {
      _feedbackList = qF;
    });
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
            itemCount: _feedbackList.lenght,
            itemBuilder: (_, index) => __buildingRow(_feedbackList[index]),
          ),
        ),
      ),
    );
  }


  Widget _buildingRow(feedback) {
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