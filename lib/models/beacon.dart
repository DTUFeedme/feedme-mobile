import 'package:climify/models/buildingModel.dart';

class Beacon {
  String id;
  String name;
  BuildingModel building;
  String uuid;

  Beacon(
    this.id,
    this.name,
    this.building,
    this.uuid,
  );
}
