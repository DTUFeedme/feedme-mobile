import 'package:climify/models/api_response.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuestionMenu {
  final BuildContext context;
  final FeedbackQuestion question;
  final String token;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(String) setCurrentlyConfirming;
  final String Function() getCurrentlyConfirming;
  StatefulBuilder questionMenuDialog;

  RestService _restService;

  QuestionMenu(
    this.context, {
    @required this.question,
    @required this.token,
    @required this.scaffoldKey,
    @required this.setCurrentlyConfirming,
    @required this.getCurrentlyConfirming,
  }) {
    _restService = RestService(context);
    questionMenuDialog = StatefulBuilder(
      builder: (context, setState) {
        Future<void> _makeQuestionInactive() async {
          APIResponse<String> deleteResponse = await _restService
              .patchQuestionInactive(question.id, false);
          if (!deleteResponse.error) {
            SnackBarError.showErrorSnackBar(
                "Question ${question.value} set inactive", scaffoldKey);
          } else {
            SnackBarError.showErrorSnackBar(
                deleteResponse.errorMessage, scaffoldKey);
          }
          return;
        }

        Future<void> _makeQuestionActive() async {
          APIResponse<String> activeResponse =
              await _restService.patchQuestionInactive(question.id, true);
          if (!activeResponse.error) {
            SnackBarError.showErrorSnackBar(
                "Question ${question.value} set active", scaffoldKey);
          } else {
            SnackBarError.showErrorSnackBar(
                activeResponse.errorMessage, scaffoldKey);
          }
          return;
        }

        return SimpleDialog(
          title: Text("${question.value}"),
          children: <Widget>[
            getCurrentlyConfirming() == "activequestion"
                ? RaisedButton(
                    color: Colors.red,
                    child: Text("Confirm"),
                    onPressed: () async {
                      await _makeQuestionActive();
                      Navigator.of(context).pop();
                    },
                  )
                : RaisedButton(
                    child: Text("Make question active"),
                    onPressed: () {
                      setCurrentlyConfirming("activequestion");
                      setState(() {});
                    },
                  ),
            getCurrentlyConfirming() == "inactivequestion"
                ? RaisedButton(
                    color: Colors.red,
                    child: Text("Confirm"),
                    onPressed: () async {
                      await _makeQuestionInactive();
                      Navigator.of(context).pop();
                    },
                  )
                : RaisedButton(
                    child: Text("Make question inactive"),
                    onPressed: () {
                      setCurrentlyConfirming("inactivequestion");
                      setState(() {});
                    },
                  ),
            RaisedButton(
              child: Text("Exit"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  StatefulBuilder get dialog => questionMenuDialog;
}
