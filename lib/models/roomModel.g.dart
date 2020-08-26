// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roomModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomModel _$RoomModelFromJson(Map<String, dynamic> json) {
  return RoomModel(
    json['_id'] as String,
    json['name'] as String,
    building: json['building'] as String,
    certainty: json['certainty'] as int,
  );
}

Map<String, dynamic> _$RoomModelToJson(RoomModel instance) => <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'building': instance.building,
      'certainty': instance.certainty,
    };
