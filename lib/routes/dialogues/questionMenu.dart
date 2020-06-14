import 'package:climify/models/api_response.dart';
import 'package:climify/models/beacon.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/questionModel.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuestionMenu {
  Question question;
  String token;
  GlobalKey<ScaffoldState> scaffoldKey;
  Function(String) setCurrentlyConfirming;
  String Function() getCurrentlyConfirming;
  StatefulBuilder questionMenuDialog;

  RestService _restService = RestService();

  // Future<void> _deleteQuestion() async {
  //   APIResponse<String> deleteResponse =
  //       await _restService.deleteBeacon(token, beacon.id, building);
  //   if (!deleteResponse.error) {
  //     SnackBarError.showErrorSnackBar("Question ${question.value} set inactive", scaffoldKey);
  //   } else {
  //     SnackBarError.showErrorSnackBar(deleteResponse.errorMessage, scaffoldKey);
  //   }
  //   return;
  // }

  QuestionMenu({
    this.question,
    this.token,
    this.scaffoldKey,
    //this.addScans,
    this.setCurrentlyConfirming,
    this.getCurrentlyConfirming,
  }) {
    questionMenuDialog = StatefulBuilder(
      builder: (context, setState) {
        return SimpleDialog(
          title: Text("${question.value}"),
          children: <Widget>[
            getCurrentlyConfirming() == "inactivequestion"
                ? RaisedButton(
                    color: Colors.red,
                    child: Text("Confirm"),
                    onPressed: () async {
                      //await _deleteQuestion();
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