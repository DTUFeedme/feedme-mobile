import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/globalState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildingManager extends StatefulWidget {
  @override
  _BuildingManagerState createState() => _BuildingManagerState();
}

class _BuildingManagerState extends State<BuildingManager> {
  BuildingModel _building = BuildingModel('', '', []);
  String _token = "";

  @override
  void initState() {
    super.initState();
    _getBuildings();
  }

  void _getBuildings() async {
    await Future.delayed(Duration.zero);
    setState(() {
      _token = Provider.of<GlobalState>(context).globalState['token'];
      _building = Provider.of<GlobalState>(context).globalState['building'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Text(
          _building.name,
        ),
      ),
    );
  }
}
