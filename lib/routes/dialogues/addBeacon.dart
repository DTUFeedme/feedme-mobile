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
  TextEditingController editingController;
  RestService _restService = RestService();

  AddBeacon({
    this.token,
    this.beaconList,
    this.building,
    this.scaffoldKey,
  }) {
    addBeaconDialog = StatefulBuilder(
      builder: (context, setState) {
        List<bool> list = [];
        for (int i = 0; i < beaconList.length; i++){
          list.add(false);
        } 
        void _submitBeacon() async {
          for(int i = 0; i < beaconList.length; i++){
            if(list[i] == true){
            APIResponse<bool> apiResponse = await _restService.addBeacon(
            token,
            Tuple2(beaconList[i].item1,beaconList[i].item2),
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
          }
        }
        
        bool submitEnabled = false;

        // bool isSelected = false;
        // Set<Tuple2<String, String>> selectedSet = Set();

        void updateSelectedBeaconListRemove(int index) async {
          setState(() {
            list[index] = false;
          });
        }
        void updateSelectedBeaconListAdd(int index) async {
          setState(() {
            list[index] = true;
          });
        }
        
        //return CircularProgressIndicator();

        
        return SimpleDialog(
          title: Text("Add Beacon"),
          children: <Widget>[
              Container(
                width: double.maxFinite,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: beaconList.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                          onLongPress: () {
                                //beaconList.any((item) => item.isSelected)
                                if (list[index] == true) {
                                //setState(() {
                                  //beaconList[index].isSelected = !beaconList[index].isSelected;
                                  updateSelectedBeaconListRemove(index);
                                  //list[index] = false;
                                //});
                            }
                          },
                          onTap: () {
                                //setState(() {
                                      //beaconList[index].isSelected = true;
                                      updateSelectedBeaconListAdd(index);
                                      //list[index] = true;
                                //});
                            },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            color: //list[index].isSelected ? 
                                    list[index] == true ? 
                                      Colors.grey[400] : Colors.white,
                            child: ListTile(
                                    title: Text(beaconList[index].item1),
                                  ),
                            ),
                  );
                }
              ),
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
