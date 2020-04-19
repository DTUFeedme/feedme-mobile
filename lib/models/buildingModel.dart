import 'package:climify/models/roomModel.dart';

class BuildingModel {
  String id;
  String name;
  List<RoomModel> rooms;

  BuildingModel(
    this.id,
    this.name,
    this.rooms,
  );
}
