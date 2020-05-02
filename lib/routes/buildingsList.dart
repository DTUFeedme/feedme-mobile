import 'package:climify/models/api_response.dart';
import 'package:climify/models/beacon.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:direct_select/direct_select.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class BuildingsList extends StatefulWidget {
  @override
  _BuildingsListState createState() => _BuildingsListState();
}

class _BuildingsListState extends State<BuildingsList> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BluetoothServices _bluetooth = BluetoothServices();
  RestService _restService = RestService();
  List<BuildingModel> _buildings = [];
  int _visibleIndex = 0;
  BuildingModel _selectedBuilding;
  Tuple2<String,String> _selectedBeacon;
  List<Tuple2<String,String>> _beaconList = [];
  int scaned = 0;

  @override
  void initState() {
    super.initState();
    _getBuildings();
    _selectedBuilding = (_buildings.length > 0) ? _buildings[0] : null;
    _getBLEDevicesList();
    _selectedBeacon = (_beaconList.length > 0) ? _beaconList[0] : null;
  }

  List<DropdownMenuItem<BuildingModel>> buildDropdownMenuItems1(
      List<BuildingModel> buildings) {
    List<DropdownMenuItem<BuildingModel>> items = List();
    for (BuildingModel building in buildings) {
      items.add(
        DropdownMenuItem(
          value: building,
          child: Text(building.name),
        ),
      );
    }
    return items;
  }

    List<DropdownMenuItem<Tuple2<String,String>>> buildDropdownMenuItems2(
      List<Tuple2<String,String>> beacons) {
    List<DropdownMenuItem<Tuple2<String,String>>> items = List();
    for (Tuple2<String,String> beacon in beacons) {
      items.add(
        DropdownMenuItem(
          value: beacon,
          child: Text(beacon.item1),
        ),
      );
    }
    return items;
  }

  void _changeWindow(int index) {
    setState(() {
      _visibleIndex = index;
    });
  }

  Future<void> _getBuildings() async {
    await Future.delayed(Duration.zero);
    String token = Provider.of<GlobalState>(context).globalState['token'];
    APIResponse<List<BuildingModel>> buildingsResponse =
        await _restService.getBuildingsWithAdminRights(token);
        print(token);
    if (buildingsResponse.error) return;
    setState(() {
      _buildings = buildingsResponse.data;
    });
  }

  void _focusBuilding(BuildingModel building) {
    Provider.of<GlobalState>(context).updateBuilding(building);
    Navigator.of(context).pushNamed("buildingManager");
  }

  void _getBLEDevicesList() async{
    if (!await _bluetooth.isOn) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", _scaffoldKey);
      return;
    }
    _scan();

  }

  void _scan() async {
    if (await _bluetooth.isOn == false) return;
    List<ScanResult> scanResults =
      await _bluetooth.scanForDevices(4000);
    scanResults.forEach((result) {
    scaned++;
    String beaconName = _bluetooth.getBeaconName(result);
    String beaconId = result.advertisementData.serviceUuids[0];
    if (beaconName != "") {
      Tuple2<String,String> item = new Tuple2<String,String>(beaconName,beaconId);
      _beaconList.add(item);
    }
    });
  }

  void _createBecon() async {
    if (_selectedBeacon == null || _selectedBuilding == null) return;
    String _token = Provider.of<GlobalState>(context).globalState['token'];
    APIResponse<bool> apiResponse =
      await _restService.addBeacon(_token,_selectedBeacon,_selectedBuilding);
    if (apiResponse.data == true) {
      setState(() {
        _selectedBuilding = null;
        _selectedBeacon = null;
        _changeWindow(0);
      });
    } else {
      SnackBarError.showErrorSnackBar(apiResponse.errorMessage, _scaffoldKey);
    }
  }

  onChangeDropdownItem1(BuildingModel selectedBuilding) {
    setState(() {
      _selectedBuilding = selectedBuilding;
    });
  }

  onChangeDropdownItem2(Tuple2<String,String> selectedBeacon) {
    setState(() {
      _selectedBeacon = selectedBeacon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Administration",
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_open),
            title: Text("Buildings"),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), title: Text("Add beacon"))
        ],
        onTap: (int index) => _changeWindow(index),
        currentIndex: _visibleIndex,
      ),
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Visibility(
              visible: _visibleIndex == 0,
              child: Container(
                child: ListView.builder(
                  itemCount: _buildings.length,
                  itemBuilder: (context, index) =>
                      _buildingRow(_buildings[index]),
                ),
              ),
            ),
            Visibility(
              visible: _visibleIndex == 1,
              child: Column(
                children: <Widget>[
                  Text("Select building"),
                  SizedBox(
                    height: 20.0,
                  ),
                  DropdownButton(
                    value: _selectedBuilding,
                    items: buildDropdownMenuItems1(_buildings),
                    onChanged: onChangeDropdownItem1,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text("Selected: ${_selectedBuilding?.name}"),
                  Text("Choose beacon device"),
                  SizedBox(
                    height: 20.0,
                  ),
                  DropdownButton(
                    value: _selectedBeacon,
                    items: buildDropdownMenuItems2(_beaconList),
                    onChanged: onChangeDropdownItem2,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text("Selected: ${_selectedBeacon?.item1}"),
                  SizedBox(
                    height: 20.0,
                  ),
                  RaisedButton(
                    child: Text(
                      "Create Beacon",
                    ),
                    onPressed: () => _createBecon(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buildings"),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: _buildings.length,
          itemBuilder: (context, index) => _buildingRow(_buildings[index]),
        ),
      ),
    );
  }
*/
  Widget _buildingRow(BuildingModel building) {
    return InkWell(
      onTap: () => _focusBuilding(building),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(building.name),
        ),
      ),
    );
  }
}
