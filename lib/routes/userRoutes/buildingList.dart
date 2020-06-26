import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/listButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class BuildingList extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Future gettingRoom;

  const BuildingList({
    Key key,
    @required this.scaffoldKey,
    @required this.gettingRoom,
  }) : super(key: key);

  @override
  BuildingListState createState() => BuildingListState();
}

class BuildingListState extends State<BuildingList> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  BluetoothServices _bluetooth;
  RestService _restService;
  List<BuildingModel> _buildings;
  String buildingId = "";

  @override
  void initState() {
    super.initState();
    _restService = RestService(context);
    _bluetooth = BluetoothServices(context);
    _scaffoldKey = widget.scaffoldKey;
    getBuildings();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> getBuildings() async {
    await Future.delayed(Duration.zero);
    await widget.gettingRoom;
    String token = Provider.of<GlobalState>(context).globalState['token'];
    APIResponse<List<BuildingModel>> buildingsResponse =
        await _restService.getBuildingsWithAdminRights(token);
    if (buildingsResponse.error) return;
    setState(() {
      _buildings = buildingsResponse.data;
    });
  }

  void _focusBuilding(BuildingModel building) {
    Provider.of<GlobalState>(context).updateBuilding(building);
    Navigator.of(context)
        .pushNamed("buildingManager")
        .then((value) => getBuildings());
  }

  void _showDeleteBuildingDialog(BuildingModel building) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm deletion"),
          content: Text("Really delete ${building.name}?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text("Confirm"),
              onPressed: () async {
                await _deleteBuilding(building);
                Navigator.of(context).pop();
                getBuildings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBuilding(BuildingModel building) async {
    String token = Provider.of<GlobalState>(context).globalState['token'];
    APIResponse<String> _deleteBuildingResponse =
        await _restService.deleteBuilding(token, building);
    if (!_deleteBuildingResponse.error) {
      SnackBarError.showErrorSnackBar(
          _deleteBuildingResponse.data, _scaffoldKey);
    } else {
      SnackBarError.showErrorSnackBar("Failed deleting building", _scaffoldKey);
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RefreshIndicator(
        onRefresh: () => getBuildings(),
        child: Container(
          child: _buildings == null
              ? CircularProgressIndicator(
                  value: null,
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  itemCount: _buildings.length,
                  itemBuilder: (_, index) => ListButton(
                    onTap: () => _focusBuilding(_buildings[index]),
                    onLongPress: () =>
                        _showDeleteBuildingDialog(_buildings[index]),
                    child: Text(
                      _buildings[index].name,
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
