// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buildingModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuildingModel _$BuildingModelFromJson(Map<String, dynamic> json) {
  return BuildingModel(
    json['_id'] as String,
    json['name'] as String,
    (json['rooms'] as List)
        ?.map((e) => e == null ? null : RoomModel.fromJson(e))
        ?.toList(),
  );
}

Map<String, dynamic> _$BuildingModelToJson(BuildingModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'rooms': instance.rooms?.map((e) => e?.toJson())?.toList(),
    };
