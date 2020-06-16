// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedbackQuestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedbackQuestion _$FeedbackQuestionFromJson(Map<String, dynamic> json) {
  return FeedbackQuestion(
    json['_id'] as String,
    json['value'] as String,
    (json['roomIds'] as List)?.map((e) => e as String)?.toList(),
    json['isActive'] as bool,
    (json['answerOptions'] as List)
        ?.map((e) => e == null ? null : AnswerOption.fromJson(e))
        ?.toList(),
    (json['usersAnswered'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$FeedbackQuestionToJson(FeedbackQuestion instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'value': instance.value,
      'roomIds': instance.roomIds,
      'isActive': instance.isActive,
      'answerOptions':
          instance.answerOptions?.map((e) => e?.toJson())?.toList(),
      'usersAnswered': instance.usersAnswered,
    };
