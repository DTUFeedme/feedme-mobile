import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddBuilding {
  final BuildContext context;
  final TextEditingController textEditingController;
  final GlobalKey<ScaffoldState> scaffoldKey;
  StatefulBuilder addBuildingDialog;

  RestService _restService;

  AddBuilding(
    this.context, {
    this.textEditingController,
    this.scaffoldKey,
  }) {
    _restService = RestService();
    addBuildingDialog = StatefulBuilder(
      builder: (context, setState) {
        void _submitBuilding() async {
          APIResponse<BuildingModel> apiResponse =
              await _restService.postBuilding(
            textEditingController.text.trim(),
          );
          if (apiResponse.error == false) {
            SnackBarError.showErrorSnackBar(
                "Building ${apiResponse.data.name} added", scaffoldKey);
            Navigator.of(context).pop(true);
          } else {
            SnackBarError.showErrorSnackBar(
                apiResponse.errorMessage, scaffoldKey);
            Navigator.of(context).pop(false);
          }
        }

        bool submitEnabled = textEditingController.text.trim() != "";

        return SimpleDialog(
          title: Text("Add Building"),
          children: <Widget>[
            Text(
              "Building Name",
            ),
            TextField(
              controller: textEditingController,
              onChanged: (value) => setState(() {}),
            ),
            RaisedButton(
              color: submitEnabled ? Colors.green : Colors.red,
              child: Text("Submit"),
              onPressed: () => submitEnabled ? _submitBuilding() : null,
            ),
          ],
        );
      },
    );
  }

  StatefulBuilder get dialog => addBuildingDialog;
}
