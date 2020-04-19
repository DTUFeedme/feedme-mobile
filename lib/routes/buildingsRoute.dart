import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/userData.dart';
import 'package:climify/services/rest_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildingsPage extends StatefulWidget {
  @override
  _BuildingsPageState createState() => _BuildingsPageState();
}

class _BuildingsPageState extends State<BuildingsPage> {
  RestService _restService = RestService();
  List<BuildingModel> _buildings = [];

  @override
  void initState() {
    super.initState();
    _getBuildings();
  }

  void _getBuildings() async {
    await Future.delayed(Duration.zero);
    String token = Provider.of<UserData>(context).userData['token'];
    APIResponse<List<BuildingModel>> buildingsResponse =
        await _restService.getBuildingsWithAdminRights(token);
    if (buildingsResponse.error) return;
    setState(() {
      _buildings = buildingsResponse.data;
    });
    print(_buildings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test"),
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
    columnChildren.add(Text(building.name));
    columnChildren
        .addAll(building.rooms.map((room) => Text(room.name)).toList());
    return Column(
      children: columnChildren,
    );
  }
}
