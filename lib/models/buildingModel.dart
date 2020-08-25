import 'package:json_annotation/json_annotation.dart';
import 'package:climify/models/roomModel.dart';

part 'buildingModel.g.dart';

@JsonSerializable(explicitToJson: true)
class BuildingModel {
  @JsonKey(name: '_id')
  String id;
  String name;
  List<RoomModel> rooms;

  BuildingModel(
    this.id,
    this.name,
    this.rooms,
  );

  factory BuildingModel.fromJson(json) => _$BuildingModelFromJson(json);
  Map<String, dynamic> toJson() => _$BuildingModelToJson(this);

  @override
  String toString() {
    return 'BuildingModel{id: $id, name: $name, rooms: $rooms}';
  }
}
