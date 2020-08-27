import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/questionModel.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddQuestion {
  final BuildContext context;
  final TextEditingController textEditingController;
  final List<TextEditingController> controllerList;
  final BuildingModel building;
  final GlobalKey<ScaffoldState> scaffoldKey;
  StatefulBuilder addQuestionDialog;

  RestService _restService;

  AddQuestion(
    this.context, {
    this.textEditingController,
    this.controllerList,
    this.building,
    this.scaffoldKey,
  }) {
    _restService = RestService();
    List<bool> list = [];
    for (int i = 0; i < building.rooms.length; i++) {
      list.add(false);
    }
    List<String> finalroomlist = [];
    List<String> finalansweroptionslist = [];
    controllerList.add(TextEditingController());
    controllerList.add(TextEditingController());
    addQuestionDialog = StatefulBuilder(
      builder: (context, setState) {
        void _submitRoom() async {
          for (int i = 0; i < building.rooms.length; i++) {
            if (list[i] == true) {
              finalroomlist.add(building.rooms[i].id.toString());
            }
          }
          for (int j = 0; j < controllerList.length; j++) {
            finalansweroptionslist.add(controllerList[j].text.toString());
          }
          APIResponse<Question> apiResponse = await _restService.postQuestion(
              finalroomlist,
              textEditingController.text.trim().toString(),
              finalansweroptionslist);
          if (apiResponse.error == false) {
            SnackBarError.showErrorSnackBar(
                "Question ${apiResponse.data.value} added", scaffoldKey);
            Navigator.of(context).pop(true);
          } else {
            SnackBarError.showErrorSnackBar(
                apiResponse.errorMessage, scaffoldKey);
            Navigator.of(context).pop(false);
          }
        }

        bool submitEnabled1 = true;
        bool submitEnabled2 = controllerList.length >= 3;

        bool submitEnabled3 = (textEditingController.text.trim() != "") &&
            (list.contains(true)) &&
            controllerList.any((item) => item.text != "") &&
            textEditingController.text.length >= 3;

        void _removeAnsweroption() {
          setState(() {
            controllerList.removeLast();
          });
        }

        void _addAnsweroption() {
          setState(() {
            controllerList.add(TextEditingController());
          });
        }

        void updateSelectedRoomsListRemove(int index) async {
          setState(() {
            list[index] = false;
          });
        }

        void updateSelectedRoomsList(int index) async {
          setState(() {
            list[index] = !list[index];
          });
        }

        return SimpleDialog(
          title: Text("Add Question"),
          children: <Widget>[
            TextFormField(
              controller: textEditingController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: 'Question title'),
            ),
            Container(
              height: 100,
              width: double.maxFinite,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: controllerList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: TextFormField(
                          onChanged: (_) => setState(() {}),
                          controller: controllerList[index],
                          decoration:
                              InputDecoration(labelText: 'Answeroption'),
                        ),
                      ),
                    );
                  }),
            ),
            Container(
              height: 100,
              width: double.maxFinite,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: building.rooms.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        updateSelectedRoomsList(index);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        color: list[index] == true
                            ? Colors.grey[300]
                            : Colors.white,
                        child: ListTile(
                          title: Text(building.rooms[index].name),
                        ),
                      ),
                    );
                  }),
            ),
            RaisedButton(
              color: submitEnabled3 ? Colors.green : Colors.red,
              child: Text("Submit"),
              onPressed: () => submitEnabled3 ? _submitRoom() : null,
            ),
            RaisedButton(
              color: submitEnabled1 ? Colors.green : Colors.red,
              child: Text("Add new answeroption"),
              onPressed: () => submitEnabled1 ? _addAnsweroption() : null,
            ),
            RaisedButton(
              color: submitEnabled2 ? Colors.green : Colors.red,
              child: Text("Remove latest answeroption"),
              onPressed: () => submitEnabled2 ? _removeAnsweroption() : null,
            ),
          ],
        );
      },
    );
  }

  StatefulBuilder get dialog => addQuestionDialog;
}
