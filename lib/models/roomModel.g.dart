// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roomModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomModel _$RoomModelFromJson(Map<String, dynamic> json) {
  return RoomModel(
    json['_id'] as String,
    json['name'] as String,
    building: json['building'] == null ? null : BuildingModel.fromJson(json['building']),
  );
}

Map<String, dynamic> _$RoomModelToJson(RoomModel instance) => <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      "building": instance.building
    };
