// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) {
  return Question(
    (json['rooms'] as List)
        ?.map((e) => e == null ? null : RoomModel.fromJson(e))
        ?.toList(),
    json['value'] as String,
    (json['answerOptions'] as List)
        ?.map((e) => e == null ? null : AnswerOption.fromJson(e))
        ?.toList(),
  );
}

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'rooms': instance.rooms?.map((e) => e?.toJson())?.toList(),
      'value': instance.value,
      'answerOptions':
          instance.answerOptions?.map((e) => e?.toJson())?.toList(),
    };
