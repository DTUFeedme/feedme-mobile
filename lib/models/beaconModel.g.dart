// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beaconModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeaconModel _$BeaconModelFromJson(Map<String, dynamic> json) {
  return BeaconModel(
    json['name'] as String,
    json['rssi'] as int,
  );
}

Map<String, dynamic> _$BeaconModelToJson(BeaconModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'rssi': instance.rssi,
    };
