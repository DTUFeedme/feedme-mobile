import 'package:json_annotation/json_annotation.dart';

part 'roomModel.g.dart';

@JsonSerializable()
class RoomModel {
  @JsonKey(name: '_id')
  String id;
  String name;
  String building;

  RoomModel(this.id, this.name, {this.building});

  factory RoomModel.fromJson(json) => _$RoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomModelToJson(this);
}
