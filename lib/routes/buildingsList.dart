import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/services/rest_service.dart';
import 'package:direct_select/direct_select.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildingsList extends StatefulWidget {
  @override
  _BuildingsListState createState() => _BuildingsListState();
}

class _BuildingsListState extends State<BuildingsList> {
  RestService _restService = RestService();
  List<BuildingModel> _buildings = [];
  int _visibleIndex = 0;
  List<DropdownMenuItem<BuildingModel>> _dropdownMenuItems = [];
  BuildingModel _selectedBuilding;

  @override
  void initState() {
    super.initState();
    _getBuildings();
  }

  List<DropdownMenuItem<BuildingModel>> buildDropdownMenuItems(
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
    if (buildingsResponse.error) return;
    setState(() {
      _buildings = buildingsResponse.data;
    });
  }

  void _focusBuilding(BuildingModel building) {
    Provider.of<GlobalState>(context).updateBuilding(building);
    Navigator.of(context).pushNamed("buildingManager");
  }

  onChangeDropdownItem(BuildingModel selectedBuilding) {
    setState(() {
      _selectedBuilding = selectedBuilding;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    value: (_dropdownMenuItems.length != 0)
                        ? _dropdownMenuItems[0].value
                        : null,
                    items: buildDropdownMenuItems(_buildings),
                    onChanged: onChangeDropdownItem,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text('Selected: ${_selectedBuilding?.name}')
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
