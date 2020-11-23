import 'package:json_annotation/json_annotation.dart';

part 'beaconModel.g.dart';

@JsonSerializable()
class BeaconModel {
  String name;
  int rssi;

  BeaconModel(
    this.name,
    this.rssi,
  );

  factory BeaconModel.fromJson(json) => _$BeaconModelFromJson(json);
  Map<String, dynamic> toJson() => _$BeaconModelToJson(this);

  @override
  String toString() {
    return 'BeaconModel{name: $name, rssi: $rssi}';
  }
}
