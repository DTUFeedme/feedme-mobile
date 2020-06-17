import 'package:climify/models/api_response.dart';
import 'package:climify/models/beacon.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/listButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:climify/routes/userRoutes/buildingList.dart';

class AddBeacon {
  String token;
  BuildingModel building;
  List<Tuple2<String, String>> beaconList;
  List<Beacon> alreadyExistingBeacons;
  GlobalKey<ScaffoldState> scaffoldKey;
  StatefulBuilder addBeaconDialog;
  TextEditingController editingController;
  RestService _restService = RestService();

  AddBeacon({
    this.token,
    this.beaconList,
    this.alreadyExistingBeacons,
    this.building,
    this.scaffoldKey,
  }) {
    List<bool> list = [];
    for (int i = 0; i < beaconList.length; i++) {
      list.add(false);
    }
    addBeaconDialog = StatefulBuilder(
      builder: (context, setState) {
        APIResponse<bool> apiResponse;
        void _submitBeacon() async {
          for (int i = 0; i < beaconList.length; i++) {
            if (list[i] == true) {
              apiResponse = await _restService.addBeacon(
                token,
                Tuple2(beaconList[i].item1, beaconList[i].item2),
                building,
              );
            }
          }
          if (apiResponse.error == false) {
            SnackBarError.showErrorSnackBar("Beacon added", scaffoldKey);
            Navigator.of(context).pop(true);
          } else {
            SnackBarError.showErrorSnackBar(
                apiResponse.errorMessage, scaffoldKey);
            Navigator.of(context).pop(false);
          }
        }

        bool submitEnabled = list.contains(true) ? true : false;

        void updateSelectedBeaconListRemove(int index) async {
          setState(() {
            list[index] = false;
          });
        }

        void updateSelectedBeaconList(int index) async {
          setState(() {
            list[index] = !list[index];
          });
        }

        //return CircularProgressIndicator();
        return SimpleDialog(
          title: Text("Add Beacon"),
          children: <Widget>[
            Container(
              height: 300,
              width: double.maxFinite,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: beaconList.length,
                  itemBuilder: (_, int index) {
                    print(beaconList[index]);
                    return InkWell(
                      onTap: () {
                        updateSelectedBeaconList(index);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        color: list[index] == true
                            ? Colors.grey[300]
                            : (alreadyExistingBeacons.any((beacon) =>
                                    beacon.name == beaconList[index].item1)
                                ? Colors.brown[200]
                                : Colors.white),
                        child: ListTile(
                          title: Text(beaconList[index].item1),
                        ),
                      ),
                    );
                  }),
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
