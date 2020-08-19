import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoomMenu {
  final BuildContext context;
  final RoomModel room;
  final BuildingModel building;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(RoomModel) addScans;
  final Function(String) setCurrentlyConfirming;
  final String Function() getCurrentlyConfirming;
  StatefulBuilder roomMenuDialog;

  RestService _restService;

  Future<void> _deleteRoom() async {
    APIResponse<String> deleteResponse = await _restService.deleteRoom(room.id);
    if (!deleteResponse.error) {
      SnackBarError.showErrorSnackBar("Room ${room.name} deleted", scaffoldKey);
    } else {
      SnackBarError.showErrorSnackBar(deleteResponse.errorMessage, scaffoldKey);
    }
    return;
  }

  void _deleteScans() async {
    APIResponse<String> deleteResponse =
        await _restService.deleteSignalMapsOfRoom(room.id);
    if (!deleteResponse.error) {
      SnackBarError.showErrorSnackBar(
          "Scans of ${room.name} deleted", scaffoldKey);
    } else {
      SnackBarError.showErrorSnackBar(deleteResponse.errorMessage, scaffoldKey);
    }
  }

  RoomMenu(
    this.context, {
    @required this.room,
    @required this.building,
    @required this.scaffoldKey,
    @required this.addScans,
    @required this.setCurrentlyConfirming,
    @required this.getCurrentlyConfirming,
  }) {
    _restService = RestService(context);
    roomMenuDialog = StatefulBuilder(
      builder: (context, setState) {
        return SimpleDialog(
          title: Text("${room.name}"),
          children: <Widget>[
            RaisedButton(
              child: Text("Add Scans"),
              onPressed: () {
                setCurrentlyConfirming("");
                setState(() => {});
                addScans(room);
              },
            ),
            getCurrentlyConfirming() == "scans"
                ? RaisedButton(
                    color: Colors.red,
                    child: Text("Confirm"),
                    onPressed: () {
                      _deleteScans();
                      setCurrentlyConfirming("");
                      setState(() {});
                    },
                  )
                : RaisedButton(
                    child: Text("Delete Scans"),
                    onPressed: () {
                      setCurrentlyConfirming("scans");
                      setState(() {});
                    },
                  ),
            getCurrentlyConfirming() == "delete"
                ? RaisedButton(
                    color: Colors.red,
                    child: Text("Confirm"),
                    onPressed: () async {
                      await _deleteRoom();
                      Navigator.of(context).pop();
                    },
                  )
                : RaisedButton(
                    child: Text("Delete Room"),
                    onPressed: () {
                      setCurrentlyConfirming("delete");
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

  StatefulBuilder get dialog => roomMenuDialog;
}
