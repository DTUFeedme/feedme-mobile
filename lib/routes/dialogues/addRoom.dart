import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddRoom {
  final BuildContext context;
  final String token;
  final TextEditingController textEditingController;
  final BuildingModel building;
  final GlobalKey<ScaffoldState> scaffoldKey;
  StatefulBuilder addRoomDialog;

  RestService _restService;

  AddRoom(
    this.context,{
    this.token,
    this.textEditingController,
    this.building,
    this.scaffoldKey,
  }) {
    _restService = RestService(context);
    addRoomDialog = StatefulBuilder(
      builder: (context, setState) {
        void _submitRoom() async {
          APIResponse<RoomModel> apiResponse = await _restService.addRoom(
            token,
            textEditingController.text.trim(),
            building,
          );
          if (apiResponse.error == false) {
            SnackBarError.showErrorSnackBar(
                "Room ${apiResponse.data.name} added", scaffoldKey);
            Navigator.of(context).pop(true);
          } else {
            SnackBarError.showErrorSnackBar(
                apiResponse.errorMessage, scaffoldKey);
            Navigator.of(context).pop(false);
          }
        }

        bool submitEnabled = textEditingController.text.trim() != "";

        return SimpleDialog(
          title: Text("Add Room"),
          children: <Widget>[
            Text(
              "Room Name",
            ),
            TextField(
              controller: textEditingController,
              onChanged: (value) => setState(() {}),
            ),
            RaisedButton(
              color: submitEnabled ? Colors.green : Colors.red,
              child: Text("Submit"),
              onPressed: () => submitEnabled ? _submitRoom() : null,
            ),
          ],
        );
      },
    );
  }

  StatefulBuilder get dialog => addRoomDialog;
}
