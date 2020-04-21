import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/services/rest_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildingsList extends StatefulWidget {
  @override
  _BuildingsListState createState() => _BuildingsListState();
}

class _BuildingsListState extends State<BuildingsList> {
  RestService _restService = RestService();
  List<BuildingModel> _buildings = [];

  @override
  void initState() {
    super.initState();
    _getBuildings();
  }

  void _getBuildings() async {
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

  Widget _buildingRow(BuildingModel building) {
    List<Widget> columnChildren = [];
    columnChildren.add(
      Text(building.name),
    );
    columnChildren.add(
      Padding(
        padding: EdgeInsets.symmetric(
          vertical: 8,
        ),
      ),
    );
    columnChildren.addAll(
      building.rooms.map((room) {
        return Text(room.name);
      }).toList(),
    );
    return InkWell(
      onTap: () => _focusBuilding(building),
      child: Column(
        children: columnChildren,
      ),
    );
  }
}
