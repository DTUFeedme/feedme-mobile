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
  final QuestionAndFeedback feedback;
  final List<QuestionAndFeedback> feedbackList;

  const ViewFeedbackWidget({
    Key key,
    @required this.scaffoldKey, this.feedback, this.feedbackList,
  }) : super(key: key);

  @override
  ViewFeedbackWidgetState createState() => ViewFeedbackWidgetState();
}

class ViewFeedbackWidgetState extends State<ViewFeedbackWidget> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  QuestionAndFeedback _feedback;
  List<QuestionAndFeedback> _feedbackList;
  String _token;
  
  @override
  void initState() {
    super.initState();
    _scaffoldKey = widget.scaffoldKey;
    _feedback = widget.feedback;
    _feedbackList = widget.feedbackList;
    _setupState();

  }

  void _setupState() async {
    await Future.delayed(Duration.zero);
    setState(() {
      _token = Provider.of<GlobalState>(context).globalState['token'];
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Info about answer")
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              child: Text(
                "Hej"
              ),
            ),
          ],
        ),
      ),
    );
  }
}