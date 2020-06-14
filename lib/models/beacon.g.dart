// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beacon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Beacon _$BeaconFromJson(Map<String, dynamic> json) {
  return Beacon(
    json['_id'] as String,
    json['name'] as String,
    json['building'] == null ? null : BuildingModel.fromJson(json['building']),
    json['uuid'] as String,
  );
}

Map<String, dynamic> _$BeaconToJson(Beacon instance) => <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'building': instance.building?.toJson(),
      'uuid': instance.uuid,
    };
