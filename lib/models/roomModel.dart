import 'package:climify/models/buildingModel.dart';
import 'package:json_annotation/json_annotation.dart';

part 'roomModel.g.dart';

@JsonSerializable()
class RoomModel {
  @JsonKey(name: '_id')
  String id;
  String name;
  String building;
  int certainty;

  RoomModel(this.id, this.name, {this.building, this.certainty});

  factory RoomModel.fromJson(json) => _$RoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomModelToJson(this);
}
