import 'package:climify/models/api_response.dart';
import 'package:climify/models/beacon.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:climify/routes/registeredUserRoute/buildingList.dart';

class AddBeacon {
  String token;
  BuildingModel building;
  List<Tuple2<String, String>> beaconList;
  GlobalKey<ScaffoldState> scaffoldKey;
  StatefulBuilder addBeaconDialog;

  RestService _restService = RestService();

  AddBeacon({
    this.token,
    this.beaconList,
    this.building,
    this.scaffoldKey,
  }) {
    addBeaconDialog = StatefulBuilder(
      builder: (context, setState) {
        void _submitBeacon(Tuple2<String, String> selection) async {
          APIResponse<bool> apiResponse = await _restService.addBeacon(
            token,
            Tuple2(selection.item1,selection.item2),
            building,
          );
          if (apiResponse.error == false) {
            SnackBarError.showErrorSnackBar(
                //${apiResponse.data.name}
                "Beacon added", scaffoldKey);
            Navigator.of(context).pop(true);
            print('uuid' + selection.item2);
          } else {
            SnackBarError.showErrorSnackBar(
                apiResponse.errorMessage, scaffoldKey);
            Navigator.of(context).pop(false);
            print('uuid' + selection.item2);
          }
        }
        
        Tuple2<String, String> beaconListFirst = beaconList[0];
        bool submitEnabled = false;

        if (beaconListFirst != null) {
          submitEnabled = true;
        }

        return SimpleDialog(
          title: Text("Add Beacon"),
          children: <Widget>[
          DropdownButton<Tuple2<String, String>>(
              items: beaconList.map((item) {
                return new DropdownMenuItem<Tuple2<String, String>>(
                  //child: new Text(item['item_name']),
                  child: Text(item.item1 + " " + item.item2),
                  //value: item['id'].toString(),
                  value: item,
                );
              }).toList(),
              onChanged: (Tuple2<String, String> newVal) {
                setState(() {
                  beaconListFirst = newVal;
                });
              },
              value: beaconListFirst,
            ),
            RaisedButton(
              color: submitEnabled ? Colors.green : Colors.red,
              child: Text("Submit"),
              onPressed: () => submitEnabled ? _submitBeacon(beaconListFirst) : null,
            ),
          ],
        );
      },
    );
  }

  StatefulBuilder get dialog => addBeaconDialog;
}
