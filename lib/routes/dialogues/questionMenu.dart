import 'package:climify/models/api_response.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/submitButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuestionMenu {
  final BuildContext context;
  final FeedbackQuestion question;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(String) setCurrentlyConfirming;
  final String Function() getCurrentlyConfirming;
  StatefulBuilder questionMenuDialog;

  RestService _restService;

  QuestionMenu(
    this.context, {
    @required this.question,
    @required this.scaffoldKey,
    @required this.setCurrentlyConfirming,
    @required this.getCurrentlyConfirming,
  }) {
    _restService = RestService();
    questionMenuDialog = StatefulBuilder(
      builder: (context, setState) {
        Future<void> _makeQuestionInactive() async {
          APIResponse<String> deleteResponse =
              await _restService.patchQuestionInactive(question.id, false);
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
                ? SubmitButton(
                    text: "Confirm",
                    onPressed: () async {
                      await _makeQuestionActive();
                      Navigator.of(context).pop();
                      return;
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
                ? SubmitButton(
                    text: "Confirm",
                    onPressed: () async {
                      await _makeQuestionInactive();
                      Navigator.of(context).pop();
                      return;
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
