import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class AddBeacon {
  String token;
  TextEditingController textEditingController;
  TextEditingController textEditingController2;
  BuildingModel building;
  GlobalKey<ScaffoldState> scaffoldKey;
  StatefulBuilder addBeaconDialog;

  RestService _restService = RestService();

  AddBeacon({
    this.token,
    this.textEditingController,
    this.textEditingController2,
    this.building,
    this.scaffoldKey,
  }) {
    addBeaconDialog = StatefulBuilder(
      builder: (context, setState) {
        void _submitBeacon() async {
          APIResponse<bool> apiResponse = await _restService.addBeacon(
            token,
            Tuple2(textEditingController.text.trim(),textEditingController2.text.trim()),
            building,
          );
          if (apiResponse.error == false) {
            SnackBarError.showErrorSnackBar(
                //${apiResponse.data.name}
                "Beacon added", scaffoldKey);
            Navigator.of(context).pop(true);
          } else {
            SnackBarError.showErrorSnackBar(
                apiResponse.errorMessage, scaffoldKey);
            Navigator.of(context).pop(false);
          }
        }

        bool submitEnabled = (textEditingController.text.trim() != "")
        && (textEditingController2.text.trim() != "");

        return SimpleDialog(
          title: Text("Add Beacon"),
          children: <Widget>[
            TextFormField(
              controller: textEditingController,
              decoration: InputDecoration(labelText: 'Enter beacon name'),
              onChanged: (value) => setState(() {}),
            ),
            TextFormField(
              controller: textEditingController2,
              decoration: InputDecoration(labelText: 'Enter uuid'),
              onChanged: (value) => setState(() {}),
            ),
            RaisedButton(
              color: submitEnabled ? Colors.green : Colors.red,
              child: Text("Submit"),
              onPressed: () => submitEnabled ? _submitBeacon() : null,
            ),
          ],
        );
      },
    );
  }

  StatefulBuilder get dialog => addBeaconDialog;
}
