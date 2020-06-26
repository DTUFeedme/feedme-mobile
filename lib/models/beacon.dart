import 'package:json_annotation/json_annotation.dart';
import 'package:climify/models/buildingModel.dart';

part 'beacon.g.dart';

@JsonSerializable(explicitToJson: true)
class Beacon {
  @JsonKey(name: '_id')
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

  static Beacon fromJson(json) => _$BeaconFromJson(json);
  Map<String, dynamic> toJson() => _$BeaconToJson(this);
}
