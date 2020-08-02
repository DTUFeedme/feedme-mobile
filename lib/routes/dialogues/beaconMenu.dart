import 'package:climify/models/api_response.dart';
import 'package:climify/models/beacon.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BeaconMenu {
  final BuildContext context;
  final Beacon beacon;
  final String token;
  final BuildingModel building;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(String) setCurrentlyConfirming;
  final String Function() getCurrentlyConfirming;
  StatefulBuilder beaconMenuDialog;

  RestService _restService;

  BeaconMenu(
    this.context, {
    @required this.beacon,
    @required this.token,
    @required this.building,
    @required this.scaffoldKey,
    @required this.setCurrentlyConfirming,
    @required this.getCurrentlyConfirming,
  }) {
    _restService = RestService(context);
    beaconMenuDialog = StatefulBuilder(
      builder: (context, setState) {
        Future<void> _deleteBeacon() async {
          APIResponse<String> deleteResponse =
              await _restService.deleteBeacon(beacon.id);
          if (!deleteResponse.error) {
            SnackBarError.showErrorSnackBar(
                "Beacon ${beacon.name} deleted from  ${building.name}",
                scaffoldKey);
          } else {
            SnackBarError.showErrorSnackBar(
                deleteResponse.errorMessage, scaffoldKey);
          }
          return;
        }

        return SimpleDialog(
          title: Text("${beacon.name}"),
          children: <Widget>[
            getCurrentlyConfirming() == "deletebeacon"
                ? RaisedButton(
                    color: Colors.red,
                    child: Text("Confirm"),
                    onPressed: () async {
                      await _deleteBeacon();
                      Navigator.of(context).pop();
                    },
                  )
                : RaisedButton(
                    child: Text("Delete beacon"),
                    onPressed: () {
                      setCurrentlyConfirming("deletebeacon");
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

  StatefulBuilder get dialog => beaconMenuDialog;
}
